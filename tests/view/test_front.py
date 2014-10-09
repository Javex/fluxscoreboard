# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import SolutionSubmitForm, LoginForm, RegisterForm, ResetPasswordForm, ProfileForm
from fluxscoreboard.models.challenge import Submission, update_challenge_points, update_playing_teams
from fluxscoreboard.models.news import News
from fluxscoreboard.util import now
from fluxscoreboard.views.front import FrontView, UserView
from pyramid.httpexceptions import HTTPFound
from webob.multidict import MultiDict
from tests.view import BaseViewTest
from mock import MagicMock
import pytest
import cgi
import tempfile
import os


class TestScoreboardView(BaseViewTest):

    view_class = FrontView

    @pytest.mark.usefixtures("config", "ctf_state")
    def test_home(self):
        ret = self.view.home()
        assert isinstance(ret, HTTPFound)

    def test_challenges(self):
        c1 = self.make_challenge(online=True, published=True)
        c2 = self.make_challenge(online=False, published=True)
        self.dbsession.add_all([c1, c2])
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 2
        assert challenges[0] == (c1, False, 0)
        assert challenges[1] == (c2, False, 0)

    def test_challenges_solved_count(self):
        c1 = self.make_challenge(published=True)
        t1 = self.make_team()
        self.dbsession.add_all([c1, t1])
        Submission(challenge=c1, team=t1)
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] == (c1, False, 1)

    def test_challenges_team_solved(self):
        c1 = self.make_challenge(published=True)
        t1 = self.make_team()
        self.dbsession.add_all([c1, t1])
        self.dbsession.flush()
        Submission(challenge=c1, team=t1)
        self.login(t1.id)
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] == (c1, True, 1)

    def test_challenge(self):
        c = self.make_challenge(published=True)
        self.dbsession.add(c)
        self.dbsession.flush()
        self.view.request.matchdict["id"] = c.id
        ret = self.view.challenge()
        assert len(ret) == 3
        assert isinstance(ret["form"], SolutionSubmitForm)
        assert not ret["is_solved"]
        challenge = ret["challenge"]
        assert challenge is c

    def test_challenge_solved(self):
        c = self.make_challenge(published=True)
        t = self.make_team()
        self.dbsession.add_all([t, c])
        Submission(challenge=c, team=t)
        self.dbsession.flush()
        self.login(t.id)
        self.view.request.matchdict["id"] = c.id
        ret = self.view.challenge()
        assert len(ret) == 3
        assert isinstance(ret["form"], SolutionSubmitForm)
        assert ret["is_solved"]
        assert ret["challenge"] is c

    def test_challenge_solution_submit(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        self.login(t.id)
        self.request.matchdict["id"] = c.id
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                           solution="Test")
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.challenge()
        assert len(self.request.session.peek_flash('success')) == 1
        assert len(self.request.session.peek_flash('error')) == 0
        assert isinstance(ret, HTTPFound)
        subm = self.dbsession.query(Submission).one()
        assert subm.challenge == c
        assert subm.team == t

    def test_challenge_solution_submit_unsolved(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        self.login(t.id)
        self.request.matchdict["id"] = c.id
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                      solution="Test1")
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.challenge()
        assert len(self.request.session.peek_flash('error')) == 1
        assert len(self.request.session.peek_flash('success')) == 0
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 0

    def test_scoreboard(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=True)
        c = self.make_challenge(base_points=100, published=True)
        self.dbsession.add_all([t1, t2, c])
        self.dbsession.flush()
        update_playing_teams(self.dbsession.connection())
        update_challenge_points(self.dbsession.connection())
        self.dbsession.flush()
        self.dbsession.expire(c)
        Submission(challenge=c, team=t1)
        ret = self.view.scoreboard()
        assert len(ret) == 2
        teams = list(ret["teams"])
        assert len(teams) == 2
        assert teams[0] == (t1, c.points, 1)
        assert teams[1] == (t2, 0, 2)
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] is c

    def test_scoreboard_inactive_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        ret = self.view.scoreboard()
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0][0] is t1

    def test_teams(self):
        t1 = self.make_team(active=True)
        self.dbsession.add(t1)
        ret = self.view.teams()
        assert len(ret) == 1
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0] is t1

    def test_teams_inactive(self):
        t1 = self.make_team(active=False)
        self.dbsession.add(t1)
        ret = self.view.teams()
        assert len(ret) == 1
        teams = list(ret["teams"])
        assert len(teams) == 0

    def test_news(self):
        n1 = News(published=False)
        n2 = News(published=True)
        self.dbsession.add_all([n1, n2])
        ret = self.view.news()
        assert len(ret) == 1
        news = list(ret["announcements"])
        assert len(news) == 1
        assert news[0] is n2

    def test_submit_solution(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        self.dbsession.add(c)
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.team = t
        self.login(t.id)
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                      solution="Test", challenge=str(c.id))
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.submit_solution()
        assert len(self.request.session.peek_flash('success')) == 1
        assert len(self.request.session.peek_flash('error')) == 0
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 1

    def test_submit_solution_wrong(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        self.dbsession.add(c)
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.team = t
        self.login(t.id)
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                      solution="Test1", challenge=str(c.id))
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.submit_solution()
        assert len(self.request.session.peek_flash('success')) == 0
        assert len(self.request.session.peek_flash('error')) == 1
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 0

    def test_verify_token(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        self.settings.ctf_end_date = now() + timedelta(1)
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        assert t.challenge_token
        self.request.matchdict['token'] = t.challenge_token
        ret = self.view.verify_token()
        assert ret.body == '1'

    def test_verify_token_inactive_team(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        self.settings.ctf_end_date = now() + timedelta(1)
        t = self.make_team(active=False)
        self.dbsession.add(t)
        self.dbsession.flush()
        assert t.challenge_token
        self.request.matchdict['token'] = t.challenge_token
        ret = self.view.verify_token()
        assert ret.body == '0'

    def test_verify_token_archive(self):
        self.settings.archive_mode = True
        self.request.matchdict["token"] = "foo"
        assert self.view.verify_token().body == '1'

    def test_verify_token_before_start(self):
        self.settings.ctf_start_date = now() + timedelta(1)
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.matchdict['token'] = t.challenge_token
        assert t.challenge_token
        assert self.view.verify_token().body == '0'


class TestUserViews(BaseViewTest):

    view_class = UserView

    @pytest.fixture
    def ctf_during(self, dbsettings):
        dbsettings.ctf_start_date = now() - timedelta(1)
        dbsettings.ctf_end_date = now() + timedelta(1)

    @pytest.fixture
    def ctf_before(self, dbsettings):
        dbsettings.ctf_start_date = now() + timedelta(1)
        dbsettings.ctf_end_date = now() + timedelta(2)

    @pytest.fixture
    def team(self, dbsession, make_team, pyramid_request):
        team = make_team(active=True)
        dbsession.add(team)
        dbsession.flush()
        pyramid_request.team = team
        return team

    def test_logout(self, team, login_team):
        login_team(team.id)
        resp = self.view.logout()
        flash_msgs = self.request.session.peek_flash()
        assert len(flash_msgs) == 1
        assert "logged out" in flash_msgs[0]
        assert not self.request.authenticated_userid
        assert resp.code == 302
        assert resp.location.endswith("/login")

    def test_logout_test_login(self, team, login_team):
        login_team(team.id)
        self.request.session["test-login"] = True
        resp = self.view.logout()
        flash_msgs = self.request.session.peek_flash()
        assert len(flash_msgs) == 1
        assert "no longer logged in" in flash_msgs[0]
        assert not self.request.authenticated_userid
        assert resp.code == 302
        assert resp.location.endswith("/admin/teams")

    def test_login(self):
        ret = self.view.login()
        assert len(ret) == 1
        form = ret['form']
        assert isinstance(form, LoginForm)
        assert not form.email.data
        assert not form.password.data

    @pytest.mark.usefixtures("ctf_during")
    def test_login_POST(self, team):
        self.request.method = 'POST'
        self.request.POST['email'] = team.email
        self.request.POST['password'] = team._real_password
        ret = self.view.login()
        assert ret.code == 302
        assert ret.location.endswith('/')
        flash_success = self.request.session.peek_flash("success")
        assert len(flash_success) == 1
        assert "You have been logged in" in flash_success[0]

    def test_login_POST_invalid_password(self, team):
        self.request.method = 'POST'
        self.request.POST['email'] = team.email
        self.request.POST['password'] = team._real_password + 'A'
        ret = self.view.login()
        assert len(ret) == 1
        assert not ret["form"].errors
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "failed" in flash[0]

    @pytest.mark.usefixtures("ctf_before")
    def test_login_POST_ctf_not_started(self, team):
        self.request.method = 'POST'
        self.request.POST['email'] = team.email
        self.request.POST['password'] = team._real_password
        ret = self.view.login()
        assert ret.code == 302
        assert ret.location.endswith('/')
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "CTF has not started" in flash[0]

    def test_login_POST_invalid(self):
        self.request.method = 'POST'
        ret = self.view.login()
        assert len(ret) == 1
        assert ret['form'].errors

    def test_register(self):
        ret = self.view.register()
        assert len(ret) == 1
        form = ret["form"]
        assert isinstance(form, RegisterForm)
        assert not form.name.data
        assert not form.email.data

    def test_register_archive(self):
        self.settings.archive_mode = True
        ret = self.view.register()
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "Registration disabled" in flash[0]
        assert ret.code == 302
        assert ret.location.endswith("/")

    def test_register_POST_invalid(self):
        self.request.method = 'POST'
        ret = self.view.register()
        assert len(ret) == 1
        form = ret["form"]
        assert form.errors

    @pytest.mark.usefixtures("mailer")
    def test_register_POST_success(self, countries):
        self.request.method = 'POST'
        data = {
            'name': 'FooBar',
            'email': 'foo@bar.com',
            'email_repeat': 'foo@bar.com',
            'password': 'foo2foo2foo2',
            'password_repeat': 'foo2foo2foo2',
            'country': str(countries[0].id),
            'timezone': 'UTC',
            'submit': "Register",
        }
        self.request.POST.update(data)
        del RegisterForm.captcha
        ret = self.view.register()
        flash = self.request.session.peek_flash()
        assert ret.code == 302
        assert ret.location.endswith("/login")
        assert len(flash) == 1
        assert "team was registered" in flash[0]
        assert data["email"] in flash[0]

    def test_confirm(self, team):
        team.active = False
        self.request.matchdict["token"] = team.token
        ret = self.view.confirm_registration()
        assert ret.code == 302
        assert ret.location.endswith("/login")
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "account is active" in flash[0]

    def test_confirm_archive(self):
        self.settings.archive_mode = True
        ret = self.view.confirm_registration()
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "disabled in archive" in flash[0]
        assert ret.code == 302
        assert ret.location.endswith("/")

    def test_confirm_invalid_token(self):
        self.request.matchdict["token"] = "foo"
        with pytest.raises(HTTPFound):
            self.view.confirm_registration()
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "Invalid token" in flash[0]

    def test_profile(self, team):
        self.request.POST.clear()
        ret = self.view.profile()
        assert len(ret) == 2
        form = ret["form"]
        assert form.email.data == team.email
        assert isinstance(form, ProfileForm)
        assert ret["team"] == team

    def test_profile_cancel(self, team):
        self.request.method = 'POST'
        self.request.POST['cancel'] = 'Cancel'
        ret = self.view.profile()
        assert ret.code == 302
        assert ret.location.endswith("/profile")
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "aborted" in flash[0]

    def test_profile_invalid(self, team):
        self.request.method = 'POST'
        self.request.POST['email'] = ''
        ret = self.view.profile()
        assert len(ret) == 2
        assert ret["form"].errors
        assert ret["team"] == team
        
    def test_profile_avatar_delete(self, team):
        team.avatar_filename = "foobarfoo"
        self.request.method = 'POST'
        self.request.POST['delete-avatar'] = 'Something'
        self.request.POST['email'] = 'something@new.com'
        ret = self.view.profile()
        assert ret.code == 302
        assert ret.location.endswith("/profile")
        assert team.email == self.request.POST['email']
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "updated" in flash[0]

    @pytest.fixture
    def avatar(self, tmpdir, request):
        avatar_path = os.path.join(str(tmpdir), 'foo.png')
        with open(avatar_path, 'w') as f:
            f.write('foo')
        f = open(avatar_path)
        request.addfinalizer(f.close)
        avatar = cgi.FieldStorage()
        avatar.file = f
        avatar.filename = "foo.png"
        return avatar

    def test_profile_avatar_upload(self, team, avatar):
        self.request.method = 'POST'
        self.request.POST['avatar'] = avatar
        self.request.POST['email'] = team.email
        assert not team.avatar_filename
        ret = self.view.profile()
        assert team.avatar_filename
        avatar_path = "fluxscoreboard/static/images/avatars/%s" % team.avatar_filename
        with open(avatar_path) as f:
            assert f.read() == avatar.file.read()
        os.remove(avatar_path)
        assert ret.code == 302
        assert ret.location.endswith("/profile")
        assert team.email == self.request.POST['email']
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "updated" in flash[0]


    def test_reset_password_start(self):
        ret = self.view.reset_password_start()
        assert len(ret) == 1
        form = ret["form"]
        assert not form.email.data
        assert not form.errors

    def test_reset_password_start_archive(self):
        self.settings.archive_mode = True
        ret = self.view.reset_password_start()
        flash = self.request.session.peek_flash('error')
        assert ret.code == 302
        assert ret.location.endswith("/")
        assert len(flash) == 1
        assert "impossible in archive" in flash[0]

    def test_reset_password_start_POST_invalid(self):
        self.request.method = 'POST'
        ret = self.view.reset_password_start()
        assert len(ret) == 1
        assert ret["form"].errors

    @pytest.mark.usefixtures("mailer")
    def test_reset_password_start_POST_success(self):
        self.request.method = 'POST'
        self.request.POST['email'] = 'foo@example.com'
        ret = self.view.reset_password_start()
        assert ret.code == 302
        assert ret.location.endswith("/reset-password")
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "email has been sent" in flash[0]

    def test_reset_password_archive(self):
        self.settings.archive_mode = True
        ret = self.view.reset_password()
        assert ret.code == 302
        assert ret.location.endswith("/")
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "reset impossible" in flash[0]

    def test_reset_password(self, team):
        self.request.matchdict["token"] = team.reset_token
        ret = self.view.reset_password()
        assert len(ret) == 2
        form = ret["form"]
        assert isinstance(form, ResetPasswordForm)
        assert not form.errors
        assert ret["token"] == team.reset_token

    def test_reset_password_invalid_token(self):
        self.request.matchdict["token"] = "foo"
        with pytest.raises(HTTPFound):
            self.view.reset_password()
        flash = self.request.session.peek_flash("error")
        assert len(flash) == 1
        assert "Reset failed" in flash[0]

    def test_reset_password_POST_invalid(self, team):
        self.request.matchdict["token"] = team.reset_token
        self.request.method = 'POST'
        ret = self.view.reset_password()
        assert len(ret) == 2
        assert ret["form"].errors
        assert ret["token"] == team.reset_token

    def test_reset_password_POST_success(self, team):
        previous_pw = team.password
        self.request.matchdict["token"] = team.reset_token
        self.request.method = 'POST'
        self.request.POST['password'] = 'foo2foo2foo2'
        self.request.POST['password_repeat'] = 'foo2foo2foo2'
        ret = self.view.reset_password()
        assert ret.code == 302
        assert ret.location.endswith("/login")
        assert team.reset_token is None
        assert team.password != previous_pw
        flash = self.request.session.peek_flash()
        assert len(flash) == 1
        assert "password has been reset" in flash[0]
