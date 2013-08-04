# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import
from fluxscoreboard.forms import RegisterForm, LoginForm, SolutionSubmitForm
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.news import News
from fluxscoreboard.models.team import Team
from pyramid.httpexceptions import HTTPFound
from pyramid.renderers import render
from pyramid.security import remember, authenticated_userid, forget
from pyramid.view import view_config
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from sqlalchemy.orm.exc import NoResultFound
import logging
import functools
from fluxscoreboard.models.challenge import Challenge, Submission
from sqlalchemy.sql import exists
from sqlalchemy.orm.util import aliased
from sqlalchemy.sql.expression import func, subquery
from sqlalchemy.types import Integer
from sqlalchemy.orm import subqueryload


log = logging.getLogger(__name__)


logged_in_view = functools.partial(view_config, permission='view')


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

    @logged_in_view(route_name='home')
    def home(self):
        return HTTPFound(location=self.request.route_url('news'))

    @logged_in_view(route_name='challenges', renderer='challenges.mako')
    def challenges(self):
        dbsession = DBSession()
        # team_id = authenticated_userid(self.request)
        team_id = 30
        # This subquery basically searches for whether the current team has
        # solved the corresponding challenge. The correlate statement is
        # a SQLAlchemy statement that tells it to use the **outer** challenge
        # column.
        team_solved_subquery = (dbsession.query(Submission).
                                filter(Submission.team_id == team_id).
                                filter(Challenge.id ==
                                       Submission.challenge_id).
                                correlate(Challenge))
        number_of_solved_subquery = func.count(Submission.team_id)
        challenge_query = (dbsession.query(Challenge,
                                           team_solved_subquery.exists(),
                                           number_of_solved_subquery).
                           outerjoin(Submission).
                           group_by(Submission.challenge_id))
        challenges = challenge_query.all()
        log.debug("Challenge count: %d" % len(challenges))
        return {'challenges': challenges}

    @logged_in_view(route_name='challenge', renderer='challenge.mako')
    def challenge(self):
        challenge_id = int(self.request.matchdict["id"])
        team_id = authenticated_userid(self.request)
        dbsession = DBSession()
        challenge = (dbsession.query(Challenge).
                     filter(Challenge.id == challenge_id).
                     options(subqueryload('announcements')).one())
        form = SolutionSubmitForm(self.request.POST)
        retparams = {'challenge': challenge, 'form': form}
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            if challenge.solution == form.solution.data:
                self.request.flash("Yes, that was the correct solution.")
                submission = Submission(team_id=team_id,
                                        challenge_id=challenge_id,
                                        )
        return retparams

    @logged_in_view(route_name='scoreboard', renderer='scoreboard.mako')
    def scoreboard(self):
        dbsession = DBSession()
        # Calculate sum of all points, defalt to 0
        challenge_sum = func.coalesce(func.sum(Challenge._points), 0)
        # Calculate sum of all bonus points, default to 0
        bonus_sum = func.coalesce(func.sum(Submission.bonus), 0)
        # Create a subquery for the sum of the above points. The filters
        # basically join the columns and the correlation is needed to reference
        # the **outer** Team query.
        team_score_subquery = (dbsession.query(challenge_sum + bonus_sum).
                               filter(Challenge.id == Submission.challenge_id).
                               filter(Team.id == Submission.team_id).
                               correlate(Team))
        # Finally build the complete query. The as_scalar tells SQLAlchemy to
        # use this as a single value (i.e. take the first coulmn)
        team_query = dbsession.query(Team, team_score_subquery.as_scalar())
        teams = team_query.all()
        return {'teams': teams}

    @logged_in_view(route_name='news', renderer='announcements.mako')
    def news(self):
        announcements = (DBSession().query(News).
                         filter(News.published == True).all())
        return {'announcements': announcements}

    @logged_in_view(route_name='submit', renderer='submit.mako')
    def submit_solution(self):
        pass

    @logged_in_view(route_name='logout')
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
