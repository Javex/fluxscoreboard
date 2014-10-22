import logging
import fluxscoreboard
import fluxscoreboard.views.front
import sqlalchemy
import sqlalchemy.orm
import pyramid
import wtforms

log = logging.getLogger(__name__)
allow_multiple = False


class ProtocolForm(fluxscoreboard.forms.CSRFForm):
    flag = wtforms.fields.simple.TextField("Flag")
    submit = wtforms.fields.simple.SubmitField("Submit")


class Protocol(fluxscoreboard.models.Base):
    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)
    name = sqlalchemy.Column(sqlalchemy.Unicode, nullable=False)
    flag = sqlalchemy.Column(sqlalchemy.Unicode, nullable=False)


class ProtocolsTeam(fluxscoreboard.models.Base):
    __tablename__ = 'protocols_team'
    team_id = sqlalchemy.Column(
        sqlalchemy.ForeignKey('team.id'), primary_key=True)
    protocol_id = sqlalchemy.Column(
        sqlalchemy.ForeignKey('protocol.id'), primary_key=True)

    team = sqlalchemy.orm.relationship("Team", backref='protocols')
    protocol = sqlalchemy.orm.relationship("Protocol")


class ProtocolView(fluxscoreboard.views.front.BaseView):

    @pyramid.view.view_config(
        route_name='dynamic_protocols', request_method='POST')
    def submit_flag(self):
        try:
            challenge_id = int(self.request.matchdict["id"])
            challenge = (
                fluxscoreboard.models.DBSession.query(
                    fluxscoreboard.models.Challenge).
                filter(fluxscoreboard.models.Challenge.id == challenge_id).
                one())
        except (ValueError, sqlalchemy.orm.exc.NoResultFound):
            raise pyramid.httpexceptions.HTTPNotFound
        if (self.request.settings.archive_mode or
                self.request.settings.ctf_ended or
                self.request.settings.submission_disabled or
                not challenge.online):
            raise pyramid.httpexceptions.HTTPNotFound
        form = ProtocolForm(self.request.POST, csrf_context=self.request)
        redir = self.request.route_url('challenge', id=challenge.id)
        if form.validate():
            prot = (fluxscoreboard.models.DBSession.query(Protocol).
                    filter(sqlalchemy.or_(
                        Protocol.flag == form.flag.data,
                        Protocol.flag == 'flag{%s}' % form.flag.data)
                        ).first())
            if prot:
                # correct!
                try:
                    subm = ProtocolsTeam(team_id=self.request.team.id,
                                         protocol_id=prot.id)
                    fluxscoreboard.models.DBSession.add(subm)
                    fluxscoreboard.models.DBSession.flush()
                    self.request.session.flash("Correct!", queue='success')
                except sqlalchemy.exc.IntegrityError:
                    self.request.session.flash('You already submitted that '
                                               'flag!', queue='error')
                    raise pyramid.httpexceptions.HTTPFound(location=redir)
            else:
                # wrong!
                self.request.session.flash("Wrong!", queue='error')
        return pyramid.httpexceptions.HTTPFound(location=redir)


def activate(config, settings):
    config.add_route('dynamic_protocols', '/protocols/{id}')


def render(challenge, request):
    protocols = fluxscoreboard.models.DBSession.query(Protocol)
    data = {
        'challenge': challenge,
        'protocols': protocols,
        'form': ProtocolForm(request.POST, csrf_context=request)
    }
    return pyramid.renderers.render('dynamic/protocols.mako', data, request)


def get_points(team):
    prot_cnt = fluxscoreboard.models.DBSession.query(Protocol).count()
    return len(team.protocols) * 5 if team else 0, prot_cnt * 5


def get_points_query(cls_=None):
    if cls_ is None:
        cls_ = fluxscoreboard.models.Team
    query = (sqlalchemy.select([sqlalchemy.func.count('*') * 5]).
             where(ProtocolsTeam.team_id == cls_.id).
             correlate(cls_))
    return query


def is_solved(team):
    prot_cnt = fluxscoreboard.models.DBSession.query(Protocol).count()
    return len(team.protocols) == prot_cnt


def in_progress_query(team):
    query = sqlalchemy.exists().where(ProtocolsTeam.team_id == team.id)
    return query


def solved_count_query():
    team_count = (sqlalchemy.select(
        [sqlalchemy.func.count(ProtocolsTeam.team_id)]
        ).
        where(ProtocolsTeam.team_id == fluxscoreboard.models.Team.id).
        as_scalar())
    prot_count = (sqlalchemy.select([sqlalchemy.func.count(Protocol.id)]).
                  as_scalar())
    query = (fluxscoreboard.models.DBSession.query(
        sqlalchemy.func.count(fluxscoreboard.models.Team.id)).
        filter(team_count == prot_count).
        correlate(fluxscoreboard.models.Challenge))
    return query


def title():
    return "Protocols (%s)" % __name__


def install(connection):
    protocols = {
        'FINGER': 'flag{f1nger_me_baby...scnr}',
        'GOPHER': 'flag{ever_heard_of_g0pher?}',
        'IRC': 'flag{internetrelaaaaaychat}',
        'NNTP': 'flag{Not_aNother_sTupid_Protocol}',
        'POP3': 'flag{once_pop3d_never_stop3d}',
        'SMTP': 'flag{deliver_that_yourself_:-P}',
        'TFTP': 'flag{tftp_as_a_service}',
    }
    data = []
    for prot, flag in protocols.items():
        data.append({'name': unicode(prot), 'flag': unicode(flag)})
    connection.execute(Protocol.__table__.insert().values(data))
