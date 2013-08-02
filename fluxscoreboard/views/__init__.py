# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import RegisterForm, LoginForm
from fluxscoreboard.forms_admin import NewsForm, ChallengeForm, TeamForm, \
    SubmissionForm, MassMailForm
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import Challenge, Submission
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team, get_all_teams, get_active_teams
from fluxscoreboard.util import encrypt_pw
from pyramid.httpexceptions import HTTPFound
from pyramid.renderers import render
from pyramid.security import remember, authenticated_userid, forget
from pyramid.view import view_config
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from sqlalchemy.orm.exc import NoResultFound
from webob.multidict import MultiDict
import logging
from webhelpers.paginate import PageURL, Page, PageURL_WebOb
from sqlalchemy.orm import joinedload


log = logging.getLogger(__name__)


class BaseView(object):

    _logged_in_menu = [('news', "Announcements"),
                      ('scoreboard', "Scoreboard"),
                      ('challenges', "Challenges"),
                      ('submit', "Submit"),
                      ('logout', "Logout"),
                      ]
    _logged_out_menu = [('login', "Login"),
                       ('register', "Register"),
                       ]

    def __init__(self, request):
        self.request = request

    @property
    def menu(self):
        if authenticated_userid(self.request):
            return self._logged_in_menu
        else:
            return self._logged_out_menu

    @view_config(route_name='challenges', renderer='challenges.mako')
    def challenges(self):
        pass

    @view_config(route_name='challenge', renderer='challenge.mako')
    def challenge(self):
        pass

    @view_config(route_name='scoreboard', renderer='scoreboard.mako')
    def scoreboard(self):
        pass

    @view_config(route_name='news', renderer='announcements.mako')
    def news(self):
        announcements = (DBSession().query(News).
                         filter(News.published == True).all())
        return {'announcements': announcements}

    @view_config(route_name='submit', renderer='submit.mako')
    def submit_solution(self):
        pass

    @view_config(route_name='logout')
    def logout(self):
        headers = forget(self.request)
        self.request.session.invalidate()
        self.request.session.flash("You have been logged out.")
        return HTTPFound(location=self.request.route_url('login'),
                         headers=headers)

    @view_config(route_name='login', renderer='login.mako')
    def login(self):
        form = LoginForm(self.request.POST)
        if self.request.method == 'POST':
            if not form.validate():
                return {'form': form}
            try:
                team = (DBSession().
                        query(Team).
                        filter(Team.email == form.email.data).
                        one())
                if not team.active:
                    raise ValueError("Team not activated yet")
                team.validate_password(form.password.data)
            except (NoResultFound, ValueError) as e:
                self.request.session.flash("Login failed.")
                log.info("Failed login attempt for team %(team_email)s "
                         "with IP Address %(ip_address) and reason "
                         "%(message)s" %
                         {'team_email': team.email,
                          'ip_address': self.request.client_addr,
                          'message': e.message,
                          }
                         )
            self.request.session.invalidate()
            headers = remember(self.request, team.id)
            self.request.session.flash("You have been logged in.")
            return HTTPFound(location=self.request.route_url('news'),
                                 headers=headers)
        return {'form': form}

    @view_config(route_name='register', renderer='register.mako')
    def register(self):
        form = RegisterForm(self.request.POST)
        if self.request.method == 'POST':
            if not form.validate():
                return {'form': form}
            team = Team(name=form.name.data,
                        email=form.email.data,
                        password=form.password.data,
                        country=form.country.data,
                        )
            DBSession().add(team)
            mailer = get_mailer(self.request)
            message = Message(subject="Your hack.lu 2013 CTF Registration",
                              recipients=[team.email],
                              html=render('mail_register.mako',
                                          {'team': team},
                                          request=self.request,
                                          )
                              )
            mailer.send(message)
            self.request.session.flash("Your team was registered. Please "
                                       "verify it by clicking on the "
                                       "verification link that was sent to %s"
                                       % team.email)
            return HTTPFound(location=self.request.route_url('login'))
        return {'form': form}

    @view_config(route_name='confirm')
    def confirm_registration(self):
        token = self.request.matchdict.get('token', None)
        if token is None:
            self.request.session.flash("Invalid token")
            raise HTTPFound(location=self.request.route_url('login'))
        try:
            team = DBSession().query(Team).filter(Team.token == token).one()
        except NoResultFound:
            self.request.session.flash("Invalid token")
            raise HTTPFound(location=self.request.route_url('login'))
        team.active = True
        self.request.session.flash("Your account is active, you may now log "
                                   "in.")
        return HTTPFound(location=self.request.route_url('login'))


class AdminView(object):

    _menu = [('admin_news', 'Announcements'),
             ('admin_challenges', 'Challenges'),
             ('admin_teams', 'Teams'),
             ('admin_submissions', 'Submissions'),
             ('admin_massmail', 'Mass Mail'),
             ]

    def __init__(self, request):
        self.request = request

    @property
    def menu(self):
        return self._menu

    @view_config(route_name='admin', renderer='admin.mako')
    def admin(self):
        return {}

    def _admin_list(self, route_name, FormClass, DatabaseClass, title):
        dbsession = DBSession()
        items_query = dbsession.query(DatabaseClass)
        item_id = self.request.matchdict.get('id', None)
        if item_id is None:
            form = FormClass(self.request.POST)
        else:
            db_item = (dbsession.query(DatabaseClass).
                       filter(DatabaseClass.id == item_id).one())
            form = FormClass(self.request.POST, db_item)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(items_query, page=current_page, url=page_url,
                    items_per_page=5, item_count=items_query.count())
        retparams = {'items': page.items,
                     'form': form,
                     'is_new': not bool(form.id.data),
                     'page': page}
        if self.request.method == 'POST':
            if form.submit.data:
                if not form.validate():
                    return retparams
                if not form.id.data:
                    db_item = DatabaseClass()
                    dbsession.add(db_item)
                    self.request.session.flash("%s added!" % title)
                else:
                    db_item = (dbsession.query(DatabaseClass).
                               filter(DatabaseClass.id == form.id.data).one())
                    self.request.session.flash("%s edited!" % title)
                form.populate_obj(db_item)
            return HTTPFound(location=self.request.route_url(route_name))
        return retparams

    def _admin_delete(self, route_name, DatabaseClass, title, title_plural):
        item_id = self.request.matchdict["id"]
        dbsession = DBSession()
        delete_query = (dbsession.query(DatabaseClass).
                        filter(DatabaseClass.id == item_id))
        rows_deleted = delete_query.delete()
        if rows_deleted == 0:
            self.request.session.flash("The %s to be deleted was "
                                       "not found!" % title.lower(),
                                       "error"
                                       )
        elif rows_deleted > 1:
            log.error("Deleted multiple %s with query %s"
                      % (title_plural.lower(), delete_query))
            raise ValueError("Multiple %s were found and deleted. "
                             "This should not be possible!"
                             % title_plural.lower())
        else:
            self.request.session.flash("%s deleted!" % title)
        return HTTPFound(location=self.request.route_url(route_name))

    def _admin_toggle_status(self, route_name, DatabaseClass, title='',
                             status_types={False: False, True: True},
                             status_variable_name='published',
                             status_messages={False: 'Unpublished %(title)s',
                                              True: 'Published %(title)s'}):
        item_id = self.request.matchdict["id"]
        dbsession = DBSession()
        inverse_status_types = {}
        for key, value in status_types.items():
            inverse_status_types[value] = key
        item = (dbsession.query(DatabaseClass).
                filter(DatabaseClass.id == item_id).one())
        status = inverse_status_types[getattr(item, status_variable_name)]
        setattr(item, status_variable_name, status_types[not status])
        self.request.session.flash(status_messages[not status]
                                   % {'title': title.lower()})
        return HTTPFound(location=self.request.route_url(route_name))

    @view_config(route_name='admin_news', renderer='admin_news.mako')
    @view_config(route_name='admin_news_edit', renderer='admin_news.mako')
    def news(self):
        return self._admin_list('admin_news', NewsForm, News, "Announcement")

    @view_config(route_name='admin_news_delete')
    def news_delete(self):
        return self._admin_delete('admin_news', News,
                                  "Announcement", "Announcements")

    @view_config(route_name='admin_news_toggle_status')
    def news_toggle_status(self):
        return self._admin_toggle_status('admin_news', News, "Announcement")

    @view_config(route_name='admin_challenges',
                 renderer='admin_challenges.mako')
    @view_config(route_name='admin_challenges_edit',
                 renderer='admin_challenges.mako')
    def challenges(self):
        return self._admin_list('admin_challenges', ChallengeForm,
                                Challenge, "Challenge")

    @view_config(route_name='admin_challenges_delete')
    def challenge_delete(self):
        return self._admin_delete('admin_challenges', Challenge,
                                  "Challenge", "Challenges")

    @view_config(route_name='admin_challenges_toggle_status')
    def challenge_toggle_status(self):
        return self._admin_toggle_status('admin_challenges', Challenge,
                                         "Challenge")

    @view_config(route_name='admin_teams',
                 renderer='admin_teams.mako')
    @view_config(route_name='admin_teams_edit',
                 renderer='admin_teams.mako')
    def teams(self):
        return self._admin_list('admin_teams', TeamForm, Team, "Team")

    @view_config(route_name='admin_teams_delete')
    def team_delete(self):
        return self._admin_delete('admin_teams', Team, "Team", "Teams")

    @view_config(route_name='admin_teams_activate')
    def team_activate(self):
        return self._admin_toggle_status('admin_teams', Team, "Team",
                                         {True: True, False: False},
                                         'active',
                                         {False: 'Deactivated %(title)s',
                                          True: 'Activated %(title)s'}
                                         )

    @view_config(route_name='admin_teams_toggle_local')
    def team_toggle_local(self):
        return self._admin_toggle_status(
            'admin_teams', Team, status_types={True: True, False: False},
            status_variable_name='local',
            status_messages={False: 'Set team as a remote team',
                             True: 'Set team as a local team'}
            )

    @view_config(route_name='admin_submissions',
                 renderer='admin_submissions.mako')
    @view_config(route_name='admin_submissions_edit',
                 renderer='admin_submissions.mako')
    def submissions(self):
        dbsession = DBSession()
        submissions_query = (dbsession.query(Submission).
                             options(joinedload('challenge')).
                             options(joinedload('team')))
        challenge_id = self.request.matchdict.get('cid', None)
        team_id = self.request.matchdict.get('tid', None)
        if challenge_id is None or team_id is None:
            form = SubmissionForm(self.request.POST)
        else:
            db_item = (dbsession.query(Submission).
                       filter(Submission.team_id == team_id).
                       filter(Submission.challenge_id == challenge_id).
                       one())
            form = SubmissionForm(self.request.POST, db_item)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(submissions_query, page=current_page, url=page_url,
                    items_per_page=5, item_count=submissions_query.count())
        retparams = {'items': page.items,
                     'form': form,
                     'is_new': True,
                     'page': page}
        if self.request.method == 'POST':
            if form.submit.data:
                if not form.validate():
                    return retparams

                try:
                    db_item = (dbsession.query(Submission).
                               filter(Submission.challenge_id ==
                                      form.challenge.data.id).
                               filter(Submission.team_id == form.team.data.id).
                               one())
                    is_new = False
                    self.request.session.flash("Submission edited!")
                except NoResultFound:
                    db_item = Submission()
                    dbsession.add(db_item)
                    is_new = True
                    self.request.session.flash("Submission added!")
                form.populate_obj(db_item)
                retparams["is_new"] = is_new
            return HTTPFound(
                location=self.request.route_url('admin_submissions')
                )
        return retparams

    @view_config(route_name='admin_submissions_delete')
    def sbumissions_delete(self):
        team_id = self.request.matchdict["tid"]
        challenge_id = self.request.matchdict["cid"]
        dbsession = DBSession()
        delete_query = (dbsession.query(Submission).
                        filter(Submission.challenge_id == challenge_id).
                        filter(Submission.team_id == team_id))
        rows_deleted = delete_query.delete()
        if rows_deleted == 0:
            self.request.session.flash("The Submission to be deleted was "
                                       "not found!",
                                       "error"
                                       )
        elif rows_deleted > 1:
            log.error("Deleted multiple Submissions with query %s"
                      % delete_query)
            raise ValueError("Multiple Submissions were found and deleted. "
                             "This should not be possible!")
        else:
            self.request.session.flash("Submission deleted!")
        return HTTPFound(location=self.request.route_url('admin_submissions'))

    @view_config(route_name='admin_massmail',
                 renderer='admin_massmail.mako')
    def massmail(self):
        dbsession = DBSession()
        form = MassMailForm(self.request.POST)
        if not form.from_.data:
            settings = self.request.registry.settings
            form.from_.data = settings["mail.default_sender"]
        mail_query = dbsession.query(MassMail)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(mail_query, page=current_page, url=page_url,
                    items_per_page=5, item_count=mail_query.count())
        retparams = {'form': form,
                     'items': page.items,
                     'page': page}
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            teams = get_active_teams()
            # Create a record to keep track of all sent mails
            mail_record = MassMail()
            form.populate_obj(mail_record)
            recipients = [team.email for team in teams]
            mail_record.recipients = recipients
            mailer = get_mailer(self.request)
            message = Message(subject=mail_record.subject,
                              bcc=mail_record.recipients,
                              body=mail_record.message,
                              sender=mail_record.from_,
                              )
            dbsession.add(mail_record)
            mailer.send(message)
            self.request.session.flash("Mass mail sent to all %d active users"
                                       % len(recipients))
            return HTTPFound(location=self.request.route_url('admin_massmail'))
        return retparams

    @view_config(route_name='admin_massmail_single',
                 renderer='admin_massmail_single.mako')
    def massmail_single(self):
        id_ = self.request.matchdict["id"]
        dbsession = DBSession()
        mail = dbsession.query(MassMail).filter(MassMail.id == id_).one()
        return {'mail': mail}
