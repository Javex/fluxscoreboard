# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.challenge import (Submission, Challenge, Category,
    get_online_challenges)
from fluxscoreboard.models.types import Timezone
from fluxscoreboard.util import bcrypt_split, encrypt_pw, random_token, now
from pyramid.decorator import reify
from pyramid.events import subscriber, NewRequest
from pyramid.renderers import render
from pyramid.threadlocal import get_current_request
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from pytz import utc
from sqlalchemy import event
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import relationship, subqueryload, joinedload, backref
from sqlalchemy.orm.attributes import NO_VALUE
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm.util import aliased
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql.expression import func, desc, bindparam, not_
from sqlalchemy.types import Integer, Unicode, Boolean
import logging
import random
import string
import transaction
import uuid


log = logging.getLogger(__name__)


TEAM_NAME_MAX_LENGTH = 255
TEAM_MAIL_MAX_LENGTH = 255
TEAM_PASSWORD_MAX_LENGTH = 60


TEAM_GROUPS = ['group:team']
"""Groups are just fixed: If a team is logged in it belongs to these groups."""


def groupfinder(userid, request):
    """
    Check if there is a team logged in, and if it is, return the default
    :data:`TEAM_GROUPS`.
    """
    if request.team:
        return TEAM_GROUPS


def get_all_teams():
    """
    Get a query that returns a list of all teams.
    """
    return DBSession.query(Team)


def get_active_teams():
    """
    Get a query that returns a list of all active teams.
    """
    return DBSession.query(Team).filter(Team.active == True)


def get_team_solved_subquery(team_id):
    """
    Get a query that searches for a submission from a team for a given
    challenge. The challenge is supposed to come from an outer query.

    Example usage:
        .. code-block:: python

            team_solved_subquery = get_team_solved_subquery(team_id)
            challenge_query = (DBSession.query(Challenge,
                                               team_solved_subquery))

    In this example we query for a list of all challenges and additionally
    fetch whether the currenttly logged in team has solved it.
    """
    # This subquery basically searches for whether the current team has
    # solved the corresponding challenge. The correlate statement is
    # a SQLAlchemy statement that tells it to use the **outer** challenge
    # column.
    if team_id:
        team_solved_subquery = (DBSession.query(Submission).
                                filter(Submission.team_id == team_id).
                                filter(Challenge.id ==
                                       Submission.challenge_id).
                                correlate(Challenge).
                                exists().
                                label("has_solved"))
    else:
        team_solved_subquery = bindparam("has_solved", 0)
    return team_solved_subquery


def get_number_solved_subquery():
    """
    Get a subquery that returns how many teams have solved a challenge.

    Example usage:

        .. code-block:: python

            number_of_solved_subquery = get_number_solved_subquery()
            challenge_query = (DBSession.query(Challenge,
                                               number_of_solved_subquery)

    Here we query for a list of all challenges and additionally fetch the
    number of times it has been solved. This subquery will use the outer
    challenge to correlate on, so make sure to provide one or this query
    makes no sense.
    """
    return (DBSession.query(func.count('*')).
            filter(Challenge.id == Submission.challenge_id).
            correlate(Challenge).
            label("solved_count"))


def get_team(request):
    """
    Get the currently logged in team. Returns None if the team is invalid (e.g.
    inactive) or noone is logged in or if the scoreboard is in archive mode.
    """
    team_id = request.unauthenticated_userid
    if team_id is None:
        return None
    if not request.settings.archive_mode:
        try:
            team = (DBSession.query(Team).
                    filter(Team.id == team_id).
                    filter(Team.active == True).one())
            return team
        except NoResultFound:
            return None
    else:
        if team_id:
            request.session.invalidate()
        return None


def register_team(form, request):
    """
    Create a new team from a form and send a confirmation email.

    Args:
        ``form``: A filled out :class:`fluxscoreboard.forms.front.RegisterForm`.

        ``request``: The corresponding request.

    Returns:
        The :class:`Team` that was created.
    """
    team = Team(name=form.name.data,
                email=form.email.data,
                password=form.password.data,
                country=form.country.data,
                timezone=form.timezone.data,
                size=form.size.data,
                )
    DBSession.add(team)
    mailer = get_mailer(request)
    year = now().year
    message = Message(subject="Your hack.lu %s CTF Registration" % year,
                      recipients=[team.email],
                      html=render('mail_register.mako',
                                  {'team': team, 'year': year},
                                  request=request,
                                  )
                      )
    mailer.send(message)
    return team


def confirm_registration(token):
    """
    For a token, check the database for the corresponding team and activate it
    if found.

    Args:
        ``token``: The token that was sent to the user (a string)

    Returns:
        Either ``True`` or ``False`` depending on whether the confirmation was
        successful.
    """
    if token is None:
        return False
    try:
        team = DBSession.query(Team).filter(Team.token == token).one()
    except NoResultFound:
        return False
    team.active = True
    team.token = None
    return True


def login(email, password):
    """
    Check a combination of credentials for validaity and either return a
    reason why it failed or return the logged in team.

    Args:
        ``email``: The email address of the team.

        ``password``: The corresponding password.

    Returns:
        A three-tuple of ``(result, message, team)``. ``result`` indicates
        whether the login was successful or not. In case of failure ``msg``
        contains a reason why it failed so it can be logged (but **not**
        printed - we don't want to give any angle to an attacker). If the
        login was successful, ``msg`` is ``None``. Finally, if the login
        succeeded, ``team`` contains the found instance of :class:`Team`. If
        login failed, ``team`` is ``None``.
    """
    try:
        team = (DBSession.
                query(Team).
                filter(Team.email == email).
                one())
    except NoResultFound:
        return False, "Team not found", None
    if not team.validate_password(password):
        return False, "Invalid password", None
    if not team.active:
        return False, "Team not activated yet", None
    return True, None, team


def password_reminder(email, request):
    """
    For an email address, find the corresponding team and send a password
    reset token. If no team is found send an email that no user was found for
    this address.
    """
    mailer = get_mailer(request)
    team = DBSession.query(Team).filter(Team.email == email).first()
    if team:
        # send mail with reset token
        team.reset_token = random_token()
        html = render('mail_password_reset_valid.mako', {'team': team},
                      request=request)
        recipients = [team.email]
    else:
        # send mail with information that no team was found for that address.
        html = render('mail_password_reset_invalid.mako', {'email': email},
                      request=request)
        recipients = [email]
    year = now().year
    message = Message(subject="Password Reset for hack.lu CTF %s" % year,
                      recipients=recipients,
                      html=html,
                      )
    mailer.send(message)
    return team


def check_password_reset_token(token):
    """
    Check if an entered password reset token actually exists in the database.
    """
    team = (DBSession.query(Team).
            filter(Team.reset_token == token).first())
    return team


def get_team_by_ref(ref_id):
    return (DBSession.query(Team).
            filter(Team.ref_token == ref_id).one())


def ref_token():
    """
    Create a ``ref`` token (a random string of 15 letters or digits) for usage
    with the ref feature.
    """
    keyspace = string.letters + string.digits
    return "".join(random.choice(keyspace) for __ in xrange(15))


class Team(Base):
    """
    A team represented in the database.

    Attributes:
        ``id``: Primary key

        ``name``: The name of the team.

        ``password``: The password of the team. If setting the password, pass
        it as cleartext. It will automatically be encrypted and stored in the
        database.

        ``email``: E-Mail address of the team. Verified if team is ``active``.

        ``country_id``: Foreign Key specifying the location of the team.

        ``local``: Whether the team is local at the conference.

        ``token``: Token for E-Mail verification.

        ``reset_token``: When requesting a new password, this token is used.

        ``ref_token``: When using the ``ref`` feature, this token is used.

        ``challenge_token``: Unique token for each team they can provide to
            a challenge so this challenge can do rate-limiting or banning or
            whatever it wants to do.

        ``active``: Whether the team's mail address has been verified and the
        team can actively log in.

        ``timezone``: A timezone, specified as a string, like
        ``"Europe/Berlin"`` or something that, when coerced to unicode, turns
        out as a string like this. Must be valid timezone.

        ``acatar_filename``: The filename under which the avatar is stored
        in the ``static/images/avatars`` directory.

        ``size``: The size of the team.

        ``country``: Direct access to the teams
        :class:`fluxscoreboard.models.country.Country` attribute.
    """
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(TEAM_NAME_MAX_LENGTH), nullable=False, unique=True)
    _password = Column('password', Unicode(TEAM_PASSWORD_MAX_LENGTH),
                       nullable=False)
    email = Column(Unicode(TEAM_MAIL_MAX_LENGTH), nullable=False, unique=True)
    country_id = Column(Integer, ForeignKey('country.id'), nullable=False)
    local = Column(Boolean, default=False)
    token = Column(Unicode(64), unique=True, default=random_token)
    reset_token = Column(Unicode(64), unique=True)
    ref_token = Column(Unicode(15), nullable=False, default=ref_token,
                       unique=True)
    challenge_token = Column(Unicode(36), unique=True,
                             default=lambda: unicode(uuid.uuid4()),
                             nullable=False)
    active = Column(Boolean, default=False)
    timezone = Column(Timezone, default=lambda: utc,
                      nullable=False)
    avatar_filename = Column(Unicode(68), unique=True)
    size = Column(Integer)

    ips = association_proxy("team_ips", "ip")

    country = relationship("Country", lazy='joined')

    _score = None

    def __unicode__(self):
        return self.name

    def __repr__(self):
        return (('<Team name=%s, email=%s, local=%s, active=%s>'
                % (self.name, self.email, self.local, self.active)).
                encode("utf-8"))

    def validate_password(self, password):
        """
        Validate the password agains the team. If it matches return ``True``
        else return ``False``.
        """
        salt, __ = bcrypt_split(self.password)
        reference_pw = encrypt_pw(password, salt)
        if self.password != reference_pw:
            return False
        else:
            return True

    @property
    def password(self):
        return self._password

    @password.setter
    def password(self, pw):
        self._password = encrypt_pw(pw)

    def get_category_solved(self, category):
        cat_solved, total = self.stats.get(category, (0, 0))
        if total == 0:
            return 0
        else:
            return float(cat_solved) / total

    def get_overall_stats(self):
        done, total = self.stats["_overall"]
        if total == 0:
            return 0
        else:
            return float(done) / total

    @reify
    def stats(self):
        _stats = {}
        count_query = (DBSession.query(func.count(Challenge.id)).
                       filter(Challenge.category_id == Category.id).
                       filter(~Challenge.dynamic).
                       filter(Challenge.published).
                       correlate(Category))
        submission = (DBSession.query(Submission).
                      filter(Submission.team_id == self.id).
                      filter(Submission.challenge_id == Challenge.id).
                      correlate(Challenge))
        team_count_query = count_query.filter(submission.exists())
        query = DBSession.query(Category.name, count_query.as_scalar(),
                                team_count_query.as_scalar())
        for name, total, team_count in query:
            _stats[name] = (team_count, total)
        overall_stats = [0, 0]
        for team_stat, total in _stats.values():
            overall_stats[0] += team_stat
            overall_stats[1] += total
        _stats["_overall"] = tuple(overall_stats)
        return _stats

    @hybrid_property
    def score(self):
        if self._score is None:
            from fluxscoreboard.models import dynamic_challenges
            challenge_sum = sum(s.challenge.points or 0 for s in self.submissions
                                if s.challenge.published)
            bonus_sum = sum(s.bonus or 0 for s in self.submissions
                            if s.challenge.published)
            dynamic_points = 0
            for module in dynamic_challenges.registry.values():
                dynamic_points += module.get_points(self)
            self._score = challenge_sum + bonus_sum + dynamic_points
        return self._score

    @score.expression
    def score(cls):  # @NoSelf
        from fluxscoreboard.models import dynamic_challenges
        # Calculate sum of all points, defalt to 0
        challenge_sum = func.coalesce(func.sum(Challenge._points), 0)
        # Calculate sum of all bonus points, default to 0
        bonus_sum = func.coalesce(func.sum(Submission.bonus), 0)
        points_col = challenge_sum + bonus_sum
        for module in dynamic_challenges.registry.values():
            points_col += module.get_points_query(cls)
        # Create a subquery for the sum of the above points. The filters
        # basically join the columns and the correlation is needed to reference
        # the **outer** Team query.
        team_score_subquery = (DBSession.query(points_col).
                               filter(Challenge.id == Submission.challenge_id).
                               filter(cls.id == Submission.team_id).
                               filter(~Challenge.dynamic).
                               filter(Challenge.published).
                               correlate(cls))
        return team_score_subquery.label('score')

    @hybrid_property
    def rank(self):
        """
        Return the teams current rank. Can be used as a hybrid property:

        .. code-block:: python

            DBSession.query(Team).order_by(Team.rank)
            # or
            team = Team()
            team.rank

        In both cases the database will be queried so be careful how you use
        it. For equal points the same rank is returned. In general we use a
        `"1224" ranking <http://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_.28.221224.22_ranking.29>`_
        here.
        """
        rank = (DBSession.query(Team).filter(Team.score > self.score).
                order_by(desc(Team.score)).count()) + 1
        return rank

    @rank.expression
    def rank(self):
        inner_team = aliased(Team)
        return (DBSession.query(func.count('*') + 1).
                select_from(inner_team).
                filter(inner_team.score > Team.score).
                order_by(desc(inner_team.score)).
                correlate(Team).
                label('rank'))

    def get_unsolved_challenges(self):
        """
        Return a query that produces a list of all unsolved challenges for a given
        team.
        """
        team_solved_subquery = get_team_solved_subquery(self.id)
        online = get_online_challenges()
        return online.filter(not_(team_solved_subquery))

    def get_solvable_challenges(self):
        """
        Return a list of challenges that the team can solve right now. It
        returns a list of challenges that are

        - online
        - unsolved by the current team
        - not manual or dynamic (i.e. solvable by entering a solution)
        """
        unsolved = self.get_unsolved_challenges()
        return (unsolved.
                filter(~Challenge.manual).
                filter(~Challenge.dynamic).
                filter(Challenge.published))


@event.listens_for(Team._password, 'set')
def log_password_change(target, value, oldvalue, initiator):
    if oldvalue is NO_VALUE:
        return
    request = get_current_request()
    log.warning("Password changed for team with ID %s and name %s from IP "
                "address %s"
                % (target.id, target.name, request.client_addr))


@subscriber(NewRequest)
def register_ip(event):
    if ("test-login" in event.request.session and
            event.request.session["test-login"] or
            event.request.path.startswith('/static')):
        return None
    team_id = event.request.authenticated_userid
    t = transaction.savepoint()
    if not team_id:
        return
    ip = unicode(event.request.client_addr)
    try:
        DBSession.add(TeamIP(team_id=team_id, ip=ip))
        DBSession.flush()
    except IntegrityError:
        t.rollback()


class TeamIP(Base):
    __tablename__ = 'team_ip'
    team_id = Column(Integer, ForeignKey('team.id'), primary_key=True)
    ip = Column(Unicode(15), primary_key=True)

    team = relationship("Team", backref=backref("team_ips",
                                                cascade="all, delete-orphan"))
