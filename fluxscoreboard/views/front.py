# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms.front import (LoginForm, RegisterForm, ProfileForm,
    SolutionSubmitForm, SolutionSubmitListForm, ForgotPasswordForm,
    ResetPasswordForm)
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import (Challenge, Submission,
    check_submission)
from fluxscoreboard.models.news import get_published_news
from fluxscoreboard.models.team import (Team, login, get_team_solved_subquery,
    get_number_solved_subquery, get_team, register_team, confirm_registration,
    password_reminder, check_password_reset_token, get_leading_team)
from fluxscoreboard.util import (not_logged_in, random_token, tz_str, now,
    display_design)
from pyramid.decorator import reify
from pyramid.httpexceptions import HTTPFound, HTTPForbidden
from pyramid.security import remember, authenticated_userid, forget
from pyramid.view import (view_config, forbidden_view_config,
    notfound_view_config)
from pytz import utc
from sqlalchemy.orm import subqueryload, joinedload
from sqlalchemy.sql.expression import desc
import functools
import logging

# TODO: Reduce requests per second on CSS and JS


log = logging.getLogger(__name__)


logged_in_view = functools.partial(view_config, permission='view')
"""
This decorator is to be used on all views that are only allowed for logged
in users. It has the exact same interface as :class:`pyramid.view.view_config`
except that its permission is already set.
"""


class BaseView(object):
    """
    A base class for all other frontpage views. If you build a frontend view
    class, derive from this. You can access the current logged in team from
    the :data:`team` property. A list of menu items will be present in
    :data:`menu`, which returns different items based on whether the user is
    logged in.
    """

    _logged_in_menu = [  # ('news', "Announcements"),
                      ('scoreboard', "Scoreboard"),
                      ('challenges', "Challenges"),
                      ('submit', "Submit"),
                      ('profile', "Profile"),
                      ('logout', "Logout"),
                      ]
    _logged_out_menu = [('login', "Login"),
                       ('register', "Register"),
                       ]

    def __init__(self, request):
        self.request = request
        self.orb_count = None

    @reify
    def team(self):
        """
        Retrieve the current team. Can be called multiple teams without
        overhead.
        """
        return get_team(self.request)

    @reify
    def menu(self):
        """
        Get the current menu items as a list of tuples ``(view_name, title)``.
        """
        max_len = max([len(self._logged_in_menu), len(self._logged_out_menu)])
        if authenticated_userid(self.request):
            menu = list(self._logged_in_menu)
        else:
            menu = list(self._logged_out_menu)
        if display_design(self.request):
            while len(menu) < max_len:
                menu.append((None, None))
        return menu

    @reify
    def title(self):
        """
        From the menu get a title for the page.
        """
        for name, title in self.menu:
            if not name:
                continue
            if self.request.path_url.startswith(self.request.route_url(name)):
                return title
        else:
            return ""

    @reify
    def team_count(self):
        return DBSession().query(Team).filter(Team.active).count()

    @reify
    def leading_team(self):
        return get_leading_team()

    @reify
    def announcements(self):
        return get_published_news()

    @reify
    def seconds_until_end(self):
        end = self.request.settings.ctf_end_date
        countdown = int((end - now()).total_seconds())
        if countdown <= 0:
            return 0
        else:
            return countdown

    @reify
    def ctf_progress(self):
        end = self.request.settings.ctf_end_date
        start = self.request.settings.ctf_start_date
        total_time = (end - start).total_seconds()
        already_passed = (now() - start).total_seconds()
        progress = already_passed / total_time
        if progress >= 1:
            return 1
        elif progress < 0:
            return 0
        else:
            return progress


class SpecialView(BaseView):
    """
    Contains special views, i.e. pages for status codes like 404 and 403.
    """
    @forbidden_view_config()
    def forbidden(self):
        """
        A forbidden view that only returns a 403 if the user isn't logged in
        otherwise just redirect to login.
        """
        if authenticated_userid(self.request):
            return HTTPForbidden()
        return HTTPFound(location=self.request.route_url('login'))

    @notfound_view_config(renderer='404.mako')
    def notfound(self):
        """
        Renders a 404 view that integrates with the page. The attached template
        is ``404.mako``.
        """
        return {}


class FrontView(BaseView):
    """
    All views that are part of the actual page, i.e. the scoreboard and
    anything surrounding it. Most views in here **must** be protected by
    :class:`logged_in_view` and not the usual
    :class:`pyramid.view.view_config`. Some exceptions may exist, such as the
    :meth:`ref` view.
    """

    @logged_in_view(route_name='home')
    def home(self):
        """
        A view for the page root which just redirects to the ``scoreboard``
        view.
        """
        return HTTPFound(location=self.request.route_url('scoreboard'))

    @logged_in_view(route_name='challenges', renderer='challenges.mako')
    def challenges(self):
        """
        A list of all challenges similar to the scoreboard view in a table.
        It has a very complex query that gets all challennges together with
        a boolean of whether the current team has solved it, and the number
        of times this challenge was solved overall. This list of tuples
        ``(challenge, team_solved, number_solved_total)`` is then given to the
        template and rendered.
        """
        dbsession = DBSession()
        team_id = authenticated_userid(self.request)
        team_solved_subquery = get_team_solved_subquery(team_id)
        number_of_solved_subquery = get_number_solved_subquery()
        challenges = (dbsession.query(Challenge,
                                           team_solved_subquery.exists(),
                                           number_of_solved_subquery).
                      filter(Challenge.published).
                      outerjoin(Submission).
                      group_by(Challenge.id))
        return {'challenges': challenges}

    @logged_in_view(route_name='challenge', renderer='challenge.mako')
    def challenge(self):
        """
        A view of a single challenge. The query is very similar to that of
        :meth:`challenges` with the limitation that only one challenge is
        fetched. Additionally, this page displays a form to enter the solution
        of that challenge and fetches a list of announcements for the
        challenge.
        """
        challenge_id = int(self.request.matchdict["id"])
        team_id = authenticated_userid(self.request)
        dbsession = DBSession()
        team_solved_subquery = get_team_solved_subquery(team_id)
        challenge, is_solved = (dbsession.query(Challenge,
                                                team_solved_subquery.exists()).
                                 filter(Challenge.id == challenge_id).
                                 filter(Challenge.published).
                                 options(subqueryload('announcements')).one())
        form = SolutionSubmitForm(self.request.POST, csrf_context=self.request)
        retparams = {'challenge': challenge,
                     'form': form,
                     'is_solved': is_solved,
                     }
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            is_solved, msg = check_submission(challenge,
                                           form.solution.data,
                                           team_id,
                                           self.request.settings,
                                           )
            self.request.session.flash(msg,
                                       'success' if is_solved else 'error')
            return HTTPFound(location=self.request.route_url('challenge',
                                                             id=challenge.id)
                             )
        return retparams

    @logged_in_view(route_name='scoreboard', renderer='scoreboard.mako')
    def scoreboard(self):
        """
        The central most interesting view. This contains a list of all teams
        with their points, sorted with the highest points on top. The most
        complex part of the query is the query that calculates the sum of
        points right in the SQL.
        """
        dbsession = DBSession()
        # Finally build the complete query. The as_scalar tells SQLAlchemy to
        # use this as a single value (i.e. take the first coulmn)
        teams = (dbsession.query(Team, Team.score, Team.rank).
                 filter(Team.active).
                 options(subqueryload('submissions'),
                         joinedload('submissions.challenge')).
                 order_by(desc("score")))
        challenges = (dbsession.query(Challenge).filter(Challenge.published))
        return {'teams': teams,
                'challenges': challenges}

    @logged_in_view(route_name='news', renderer='announcements.mako')
    def news(self):
        """
        Just a list of all announcements that are currently published, ordered
        by publication date, the most recent first.
        """
        return {'announcements': self.announcements}

    @logged_in_view(route_name='submit', renderer='submit.mako')
    def submit_solution(self):
        """
        A special form that, in addition to the form provided by
        :meth:`challenge`, allows a user to submit solutions for a challenge.
        The difference here is that the challenge is chosen from a select list.
        Otherwise it is basically the same and boils down to the same logic.
        """
        form = SolutionSubmitListForm(self.request.params,
                                      csrf_context=self.request)
        team_id = authenticated_userid(self.request)
        retparams = {'form': form}
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            is_solved, msg = check_submission(form.challenge.data,
                                              form.solution.data,
                                              team_id,
                                              self.request.settings,
                                              )
            self.request.session.flash(msg,
                                       'success' if is_solved else 'error')
            return HTTPFound(
                location=self.request.route_url(
                    'submit',
                    _query={'challenge': form.challenge.data.id},
                    ),
            )
        return retparams


class UserView(BaseView):
    """
    This view is used for everything user- (or in our case team-) related. It
    contains stuff like registration, login and confirmation. It depends on the
    purpose of the view whether to make it a :class:`logged_in_view` or a
    :class:`pyramid.view.view_config`.
    """

    @logged_in_view(route_name='logout')
    def logout(self):
        """
        A simple view that logs out the user and redirects to the login page.
        """
        headers = forget(self.request)
        is_test_login = self.request.session.get("test-login", False)
        self.request.session.invalidate()
        if is_test_login:
            self.request.session.flash("Welcome back, you are no longer "
                                       "logged in.")
            return HTTPFound(location=self.request.route_url('admin_teams'),
                             headers=headers)
        else:
            self.request.session.flash("You have been logged out.")
            return HTTPFound(location=self.request.route_url('login'),
                             headers=headers)

    @view_config(route_name='login', renderer='login.mako')
    @not_logged_in("Doh! You are already logged in.")
    def login(self):
        """
        A view that logs in the user. Displays a login form and in case of a
        ``POST`` request, handles the login by checking whether it is valid.
        If it is, the user is logged in and redirected to the frontpage.
        """
        form = LoginForm(self.request.POST, csrf_context=self.request)
        retparams = {'form': form,
                     }
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            login_success, msg, team = login(form.email.data,
                                             form.password.data)
            if not login_success:
                self.request.session.flash("Login failed.", 'error')
                log.warn("Failed login attempt for team '%(team_email)s' "
                         "with IP Address '%(ip_address)s' and reason "
                         "'%(message)s'" %
                         {'team_email': form.email.data,
                          'ip_address': self.request.client_addr,
                          'message': msg,
                          }
                         )
                return retparams
            ctf_start = self.request.settings.ctf_start_date
            ctf_started = self.request.settings.ctf_started
            if not ctf_started:
                self.request.session.flash("Your login was successful, but "
                                           "the CTF has not started yet. "
                                           "Please come back at "
                                           "%s (%s), i.e. %s UTC."
                                           % (tz_str(ctf_start, team.timezone),
                                              team.timezone,
                                              tz_str(ctf_start, utc)))
                return HTTPFound(location=self.request.route_url('login'))
            # Start a new session due to new permissions
            self.request.session.invalidate()
            headers = remember(self.request, team.id)
            self.request.session.flash("You have been logged in.", 'success')
            return HTTPFound(location=self.request.route_url('home'),
                                 headers=headers)
        return retparams

    @view_config(route_name='register', renderer='register.mako')
    @not_logged_in("You are logged in. Why register again?")
    def register(self):
        """
        Display and handle registration of new teams.
        """
        ip = self.request.client_addr
        form = RegisterForm(self.request.POST, csrf_context=self.request,
                            captcha={'ip_address': ip})
        if self.request.method == 'POST':
            if not form.validate():
                return {'form': form}
            team = register_team(form, self.request)
            self.request.session.flash("Your team was registered. Please "
                                       "verify it by clicking on the "
                                       "verification link that was sent to %s"
                                       % team.email)
            return HTTPFound(location=self.request.route_url('login'))
        return {'form': form}

    @view_config(route_name='confirm')
    @not_logged_in("Erm... Your account is active since you are already "
                   "logged in. WTF?")
    def confirm_registration(self):
        """
        After a registration has been made, the team recieves a confirmation
        mail with a token. With this token the team activates its account by
        visitng this view. It fetches the team corresponding to the token and
        activates it.
        """
        # TODO: Its probably a better idea if the token contained the userid
        token = self.request.matchdict.get('token', None)
        if not confirm_registration(token):
            self.request.session.flash("Invalid token")
            raise HTTPFound(location=self.request.route_url('login'))
        else:
            self.request.session.flash("Your account is active, you may now "
                                       "log in.")
            return HTTPFound(location=self.request.route_url('login'))

    @logged_in_view(route_name='profile', renderer='profile.mako')
    def profile(self):
        """
        Here a team can alter their profile, i.e. change their email, password,
        location or timezone. The team name is fixed and can only be changed
        by administrators.
        """
        form = ProfileForm(self.request.POST, self.team,
                           csrf_context=self.request)
        retparams = {'form': form,
                     'team': self.team,
                     }
        redirect = HTTPFound(location=self.request.route_url('profile'))
        if self.request.method == 'POST':
            if form.cancel.data:
                self.request.session.flash("Edit aborted")
                return redirect
            if not form.validate():
                return retparams
            if form.avatar.data is not None and form.avatar.data != '':
                # Handle new avatar
                if not self.team.avatar_filename:
                    self.team.avatar_filename = random_token() + ".png"
                fpath = ("fluxscoreboard/static/images/avatars/%s"
                         % self.team.avatar_filename)
                form.avatar.image.save(fpath)
            form.populate_obj(self.team)
            self.request.session.flash('Your profile has been updated')
            return redirect
        return retparams

    @view_config(route_name='reset-password-start',
                 renderer='reset_password_start.mako')
    def reset_password_start(self):
        # TODO: The token should probably contain the userid here as well
        form = ForgotPasswordForm(self.request.POST, csrf_context=self.request)
        retparams = {'form': form}
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            password_reminder(form.email.data, self.request)
            self.request.session.flash("An email has been sent to the "
                                       "provided address with further "
                                       "information.")
            return HTTPFound(
                location=self.request.route_url('reset-password-start')
            )
        return retparams

    @view_config(route_name='reset-password', renderer='reset_password.mako')
    def reset_password(self):
        form = ResetPasswordForm(self.request.POST, csrf_context=self.request)
        redirect = HTTPFound(location=self.request.route_url('login'))
        token = self.request.matchdict["token"]
        retparams = {'form': form, 'token': token}
        team = check_password_reset_token(token)
        if not team:
            self.request.session.flash("Reset failed.")
            raise redirect
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            team.reset_token = None
            team.password = form.password.data
            self.request.session.flash("Your password has been reset.")
            return redirect
        return retparams
