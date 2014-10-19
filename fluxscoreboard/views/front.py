# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms.front import (LoginForm, RegisterForm, ProfileForm,
    SolutionSubmitForm, SolutionSubmitListForm, ForgotPasswordForm,
    ResetPasswordForm)
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import (Challenge, Submission,
    check_submission, Category)
from fluxscoreboard.models.news import get_published_news
from fluxscoreboard.models.team import (Team, login, get_team_solved_subquery,
    get_number_solved_subquery, get_team, register_team, confirm_registration,
    password_reminder, check_password_reset_token, get_active_teams)
from fluxscoreboard.util import (not_logged_in, random_token, tz_str, now,
    display_design)
from fluxscoreboard.models.settings import CTF_BEFORE, CTF_STARTED, CTF_ARCHIVE
from pyramid.decorator import reify
from pyramid.httpexceptions import HTTPFound
from pyramid.security import remember, forget
from pyramid.view import (view_config, forbidden_view_config,
    notfound_view_config)
from pyramid.response import Response
from pytz import utc
from sqlalchemy.orm import subqueryload, joinedload
from sqlalchemy.sql.expression import desc
import logging
import os
from sqlalchemy.orm.exc import NoResultFound


log = logging.getLogger(__name__)


class BaseView(object):
    """
    A base class for all other frontpage views. If you build a frontend view
    class, derive from this. You can access the current logged in team from
    the :data:`team` property. A list of menu items will be present in
    :data:`menu`, which returns different items based on whether the user is
    logged in.
    """

    _menu_item_map = {
        'scoreboard': "Scoreboard",
        'teams': "Teams",
        'challenges': "Challenges",
        'submit': "Submit",
        'profile': "Profile",
        'logout': "Logout",
        'login': "Login",
        'register': "Register",
        }

    # A matrix that gives a list of allowed views per possible state. The three
    # categories are 'before', 'started' and 'archive' with respect to the CTF
    # start and end. The other states represent the login state, meaning that
    # True represents a logged in team, False the opposite.
    _menu_item_matrix = {
        CTF_BEFORE: {
            True: ['teams', 'profile', 'logout'],
            False: ['teams', 'login', 'register'],
        },

        CTF_STARTED: {
            True: ['scoreboard', 'challenges', 'submit', 'profile', 'logout'],
            False: ['scoreboard', 'login'],
        },

        CTF_ARCHIVE: {
            False: ['scoreboard', 'challenges', 'submit'],
        },
    }

    def __init__(self, request):
        self.request = request
        self.orb_count = None

    @reify
    def current_state(self):
        """
        A pair of ``ctf_state, logged_in`` where ``ctf_state`` represents
        the current state as per settings and ``logged_in`` is a boolean that
        shows whether the user is currently logged in to a team.
        """
        # Team logged in?
        logged_in = bool(self.request.authenticated_userid)
        ctf_state = self.request.settings.ctf_state
        if ctf_state == CTF_ARCHIVE:
            logged_in = False
        return ctf_state, logged_in

    @reify
    def menu(self):
        """
        Get the current menu items as a list of tuples ``(view_name, title)``.
        """
        ctf_state, logged_in = self.current_state
        # Fetch the correcnt menu:
        menu = [(k, self._menu_item_map[k])
                for k in self._menu_item_matrix[ctf_state][logged_in]]
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
        return DBSession.query(Team).filter(Team.active).count()

    @reify
    def announcements(self):
        return get_published_news()

    @reify
    def seconds_until_end(self):
        if self.request.settings.archive_mode:
            raise ValueError("CTF is in archive mode. Cannot yield remaining "
                             "seconds")
        end = self.request.settings.ctf_end_date
        countdown = int((end - now()).total_seconds())
        if countdown <= 0:
            return 0
        else:
            return countdown

    @reify
    def ctf_progress(self):
        if self.request.settings.archive_mode:
            return 1
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
        self.request.session.flash('Access not allowed.', 'error')
        return HTTPFound(location=self.request.route_url('home'))

    @notfound_view_config(renderer='404.mako', append_slash=True)
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

    @view_config(route_name='home')
    def home(self):
        """
        A view for the page root which just redirects to the ``scoreboard``
        view.
        """
        target_map = {
            (CTF_BEFORE, True): 'teams',
            (CTF_BEFORE, False): 'login',
            (CTF_STARTED, True): 'scoreboard',
            (CTF_STARTED, False): 'login',
            (CTF_ARCHIVE, False): 'scoreboard',
        }
        target = target_map[self.current_state]
        return HTTPFound(location=self.request.route_url(target))

    @view_config(route_name='challenges', renderer='challenges.mako',
                 permission='challenges')
    def challenges(self):
        """
        A list of all challenges similar to the scoreboard view in a table.
        It has a very complex query that gets all challennges together with
        a boolean of whether the current team has solved it, and the number
        of times this challenge was solved overall. This list of tuples
        ``(challenge, team_solved, number_solved_total)`` is then given to the
        template and rendered.
        """
        team_id = self.request.authenticated_userid
        team_solved_subquery = get_team_solved_subquery(team_id)
        number_of_solved_subquery = get_number_solved_subquery()
        challenges = (DBSession.query(
            Challenge, team_solved_subquery, number_of_solved_subquery).
            options(joinedload("category")).
            filter(Challenge.published).
            order_by(Challenge.id))
        return {'challenges': challenges}

    @view_config(route_name='challenge', renderer='challenge.mako',
                 permission='challenges')
    def challenge(self):
        """
        A view of a single challenge. The query is very similar to that of
        :meth:`challenges` with the limitation that only one challenge is
        fetched. Additionally, this page displays a form to enter the solution
        of that challenge and fetches a list of announcements for the
        challenge.
        """
        challenge_id = int(self.request.matchdict["id"])
        team_id = self.request.authenticated_userid
        team_solved_subquery = get_team_solved_subquery(team_id)
        try:
            challenge, is_solved = (
                DBSession.query(Challenge, team_solved_subquery).
                filter(Challenge.id == challenge_id).
                filter(Challenge.published).one()
            )
        except NoResultFound:
            self.request.session.flash("Challenge not found or published.")
            return HTTPFound(location=self.request.route_url('challenges'))
        form = SolutionSubmitForm(self.request.POST, csrf_context=self.request)
        retparams = {'challenge': challenge,
                     'form': form,
                     'is_solved': is_solved,
                     }
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            is_solved, msg = check_submission(
                challenge, form.solution.data, team_id, self.request.settings)
            self.request.session.flash(msg,
                                       'success' if is_solved else 'error')
            return HTTPFound(location=self.request.route_url('challenge',
                                                             id=challenge.id)
                             )
        return retparams

    @view_config(route_name='scoreboard', renderer='scoreboard.mako',
                 permission='scoreboard')
    def scoreboard(self):
        """
        The central most interesting view. This contains a list of all teams
        with their points, sorted with the highest points on top. The most
        complex part of the query is the query that calculates the sum of
        points right in the SQL.
        """
        def ranked(teams):
            """ Iterator adding ranks to team results. """
            last_score = None
            for index, (team, score) in enumerate(teams, 1):
                if last_score is None or score < last_score:
                    rank = index
                    last_score = score
                base_points = 0
                yield (team, score, rank)
        # Finally build the complete query. The as_scalar tells SQLAlchemy to
        # use this as a single value (i.e. take the first coulmn)
        teams = (DBSession.query(Team, Team.score).
                 filter(Team.active).
                 options(subqueryload('submissions'),
                         joinedload('submissions.challenge')).
                 order_by(desc("score")))
        return {'teams': ranked(teams)}

    @view_config(route_name='teams', renderer='teams.mako', permission='teams')
    def teams(self):
        """
        Only a list of teams.
        """
        return {'teams': list(get_active_teams())}

    @view_config(route_name='news', renderer='announcements.mako',
                 permission='scoreboard')
    def news(self):
        """
        Just a list of all announcements that are currently published, ordered
        by publication date, the most recent first.
        """
        return {'announcements': self.announcements}

    @view_config(route_name='submit', renderer='submit.mako',
                 permission='challenges')
    def submit_solution(self):
        """
        A special form that, in addition to the form provided by
        :meth:`challenge`, allows a user to submit solutions for a challenge.
        The difference here is that the challenge is chosen from a select list.
        Otherwise it is basically the same and boils down to the same logic.
        """
        form = SolutionSubmitListForm(self.request.POST,
                                      csrf_context=self.request)
        team_id = self.request.authenticated_userid
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

    @view_config(route_name='verify_token')
    def verify_token(self):
        token = self.request.matchdict['token']
        if self.request.settings.archive_mode:
            result = '1'
        elif self.request.settings.ctf_state == CTF_BEFORE:
            result = '0'
        else:
            try:
                get_active_teams().filter(Team.challenge_token == token).one()
            except NoResultFound:
                result = '0'
            else:
                result = '1'
        return Response(result)


class UserView(BaseView):
    """
    This view is used for everything user- (or in our case team-) related. It
    contains stuff like registration, login and confirmation. It depends on the
    purpose of the view whether to make it a :class:`logged_in_view` or a
    :class:`pyramid.view.view_config`.
    """

    @view_config(route_name='logout', permission='logged_in')
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

    @view_config(route_name='login', renderer='login.mako', permission='login')
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
            # Start a new session due to new permissions
            self.request.session.invalidate()

            # Check if CTF has started already
            ctf_started = self.request.settings.ctf_started
            if not ctf_started:
                ctf_start = self.request.settings.ctf_start_date
                self.request.session.flash(
                    "You are now logged in. However, the CTF has not started "
                    "yet and thus you cannot see any challenges or the "
                    "scoreboard. The CTF will start at %s (%s), i.e. %s UTC."
                    % (tz_str(ctf_start, team.timezone), team.timezone,
                       tz_str(ctf_start, utc)))
            else:
                self.request.session.flash("You have been logged in.",
                                           'success')
            headers = remember(self.request, team.id)
            return HTTPFound(location=self.request.route_url('home'),
                             headers=headers)
        return retparams

    @view_config(route_name='register', renderer='register.mako',
                 permission='register')
    @not_logged_in("You are logged in. Why register again?")
    def register(self):
        """
        Display and handle registration of new teams.
        """
        if self.request.settings.archive_mode:
            self.request.session.flash(("Registration disabled in archive "
                                        "mode."), 'error')
            return HTTPFound(location=self.request.route_url('home'))
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

    @view_config(route_name='confirm', permission='register')
    @not_logged_in("Erm... Your account is active since you are already "
                   "logged in. WTF?")
    def confirm_registration(self):
        """
        After a registration has been made, the team recieves a confirmation
        mail with a token. With this token the team activates its account by
        visitng this view. It fetches the team corresponding to the token and
        activates it.
        """
        if self.request.settings.archive_mode:
            self.request.session.flash(("Registration disabled in archive "
                                        "mode."), 'error')
            return HTTPFound(location=self.request.route_url('home'))
        token = self.request.matchdict.get('token', None)
        if not confirm_registration(token):
            self.request.session.flash("Invalid token", 'error')
            raise HTTPFound(location=self.request.route_url('login'))
        else:
            self.request.session.flash("Your account is active, you may now "
                                       "log in.")
            return HTTPFound(location=self.request.route_url('login'))

    @view_config(route_name='profile', renderer='profile.mako',
                 permission='logged_in')
    def profile(self):
        """
        Here a team can alter their profile, i.e. change their email, password,
        location or timezone. The team name is fixed and can only be changed
        by administrators.
        """
        form = ProfileForm(self.request.POST, self.request.team,
                           csrf_context=self.request)
        retparams = {'form': form,
                     'team': self.request.team,
                     }
        redirect = HTTPFound(location=self.request.route_url('profile'))
        if self.request.method == 'POST':
            if form.cancel.data:
                self.request.session.flash("Edit aborted")
                return redirect
            if not form.validate():
                return retparams
            if form.avatar.delete:
                avatar_filename = self.request.team.avatar_filename
                try:
                    os.remove(avatar_filename)
                except OSError as e:
                    log.warning("Exception while deleting avatar for team "
                                "'%s' under filename '%s': %s" %
                                (self.request.team.name, avatar_filename, e))
                self.request.team.avatar_filename = None
            elif form.avatar.data is not None and form.avatar.data != '':
                # Handle new avatar
                ext = form.avatar.data.filename.rsplit('.', 1)[-1]
                if ext not in ('gif', 'jpg', 'jpeg', 'bmp', 'png'):
                    self.request.session.flash("Invalid file extension.")
                    return redirect
                self.request.team.avatar_filename = random_token() + "." + ext
                fpath = ("fluxscoreboard/static/images/avatars/%s"
                         % self.request.team.avatar_filename)
                with open(fpath, "w") as out:
                    in_file = form.avatar.data.file
                    in_file.seek(0)
                    while True:
                        data = in_file.read(2 << 16)
                        if not data:
                            break
                        out.write(data)
                    in_file.seek(0)
            form.populate_obj(self.request.team)
            self.request.session.flash('Your profile has been updated')
            return redirect
        return retparams

    @view_config(route_name='reset-password-start',
                 renderer='reset_password_start.mako', permission='login')
    def reset_password_start(self):
        if self.request.settings.archive_mode:
            self.request.session.flash(("Password reset impossible in "
                                        "archive mode."), 'error')
            return HTTPFound(location=self.request.route_url('home'))
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

    @view_config(route_name='reset-password', renderer='reset_password.mako',
                 permission='login')
    def reset_password(self):
        if self.request.settings.archive_mode:
            self.request.session.flash(("Password reset impossible in "
                                        "archive mode."), 'error')
            return HTTPFound(location=self.request.route_url('home'))
        form = ResetPasswordForm(self.request.POST, csrf_context=self.request)
        redirect = HTTPFound(location=self.request.route_url('login'))
        token = self.request.matchdict["token"]
        retparams = {'form': form, 'token': token}
        team = check_password_reset_token(token)
        if not team:
            self.request.session.flash("Reset failed.", 'error')
            raise redirect
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            team.reset_token = None
            team.password = form.password.data
            self.request.session.flash("Your password has been reset.")
            return redirect
        return retparams
