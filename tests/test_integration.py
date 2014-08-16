# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Settings
from fluxscoreboard.views.front import UserView
from fluxscoreboard.util import now
from datetime import timedelta
import pytest


pytestmark = pytest.mark.integration


@pytest.fixture
def user_view(pyramid_request):
    view = UserView(pyramid_request)
    return view


@pytest.fixture
def ctf_started(dbsettings, dbsession):
    dbsettings.ctf_start_date = now() - timedelta(1)
    dbsettings.ctf_end_date = now() + timedelta(1)


@pytest.fixture
def ctf_ended(dbsettings):
    dbsettings.ctf_start_date = now() - timedelta(2)
    dbsettings.ctf_end_date = now() - timedelta(1)


@pytest.fixture
def ctf_before(dbsettings):
    dbsettings.ctf_start_date = now() + timedelta(1)
    dbsettings.ctf_end_date = now() + timedelta(2)


@pytest.fixture
def ctf_archive(dbsettings, ctf_ended):
    dbsettings.archive_mode = True


class BaseIntegrationTest(object):

    @pytest.fixture(autouse=True)
    def _prepare_app(self, testapp, dbsession, countries):
        self.app = testapp
        self.dbsession = dbsession

    def _login(self, team):
        # Determine state of CTF
        settings = self.dbsession.query(Settings).one()
        if settings.ctf_start_date > now():
            msg = "You are now logged in."
        else:
            msg = "You have been logged in."

        resp = self.app.get('/login')
        form = resp.form
        form['email'].value = team.email
        form['password'].value = team._real_password
        resp = form.submit()
        assert resp.status_int == 302
        resp = resp.follow().follow()
        assert resp.status_int == 200
        assert msg in resp.body
        return resp


@pytest.mark.usefixtures("ctf_started")
class TestDuringCTF(BaseIntegrationTest):

    def test_register_closed_after_start(self):
        resp = self.app.get('/register')
        assert resp.status_int == 302

    def test_login_not_logged_in(self, make_team):
        team = make_team(active=True)
        self.dbsession.add(team)
        self.dbsession.flush()
        resp = self.app.get('/login')
        form = resp.form
        form['email'] = team.email
        form['password'] = team._real_password
        resp = form.submit()
        while resp.status_int == 302:
            resp = resp.follow()
        assert resp.status_int == 200
        assert "You have been logged in." in resp.body

        resp = self.app.get('/login')
        while resp.status_int == 302:
            resp = resp.follow()
        assert resp.status_int == 200
        assert "Doh! You are already logged in." in resp.body

        self.dbsession.delete(team)

    def test_login(self, make_team):
        team = make_team(active=True)
        self.dbsession.add(team)
        self.dbsession.flush()
        resp = self.app.get('/login')
        assert resp.status_int == 200

        form = resp.form
        form['email'].value = team.email
        form['password'].value = team._real_password
        resp = form.submit()
        assert resp.status_int == 302

        resp = resp.follow().follow()
        assert resp.status_int == 200
        assert "You have been logged in." in resp.body

        self.dbsession.delete(team)

    def test_login_failed_password(self, make_team):
        team = make_team(active=True)
        self.dbsession.add(team)
        resp = self.app.get('/login')
        assert resp.status_int == 200

        form = resp.form
        form['email'].value = team.email
        form['password'].value = team._real_password + '0'
        resp = form.submit()
        assert resp.status_int == 200
        assert "Login failed." in resp.body

        self.dbsession.delete(team)

    def test_login_failed_inactive(self, make_team):
        team = make_team(active=False)
        self.dbsession.add(team)
        resp = self.app.get('/login')
        assert resp.status_int == 200

        form = resp.form
        form['email'].value = team.email
        form['password'].value = team._real_password
        resp = form.submit()
        assert resp.status_int == 200
        assert "Login failed." in resp.body

        self.dbsession.delete(team)

    def test_login_failed_team_doesnt_exist(self, make_team):
        team = make_team()
        resp = self.app.get('/login')
        assert resp.status_int == 200

        form = resp.form
        form['email'].value = team.email
        form['password'].value = team._real_password
        resp = form.submit()
        assert resp.status_int == 200
        assert "Login failed." in resp.body

    def test_register_confirm_disabled(self):
        resp = self.app.get('/confirm/foo')
        assert resp.status_int == 302


@pytest.mark.usefixtures("ctf_archive")
class TestCTFArchive(BaseIntegrationTest):

    def test_register_closed(self):
        resp = self.app.get('/register')
        assert resp.status_int == 302

    def test_register_confirm_disabled(self):
        resp = self.app.get('/confirm/foo')
        assert resp.status_int == 302


@pytest.mark.usefixtures("ctf_before")
class TestBeforeCTF(BaseIntegrationTest):

    @pytest.mark.usefixtures("countries", "remove_captcha")
    def test_register(self):
        resp = self.app.get('/register')
        assert resp.status_int == 200
        form = resp.form
        form['name'] = 'team1'
        form['email'] = 'test@example.com'
        form['email_repeat'] = 'test@example.com'
        form['password'] = '12345678'
        form['password_repeat'] = '12345678'
        assert form['country'].value
        form['timezone'] = 'Europe/Berlin'
        resp = form.submit()
        assert resp.status_int == 302

        resp = resp.follow()
        assert resp.status_int == 200
        assert "Your team was registered." in resp.body

    def test_confirm_registration(self, make_team):
        t = make_team(active=False)
        self.dbsession.add(t)
        self.dbsession.flush()
        resp = self.app.get('/confirm/%s' % t.token)
        assert resp.status_int == 302
        resp = resp.follow()
        assert "Your account is active" in resp.body.decode("utf-8")

    def test_confirm_registration_invalid(self):
        resp = self.app.get('/confirm/foo')
        assert resp.status_int == 302
        resp = resp.follow()
        assert "Invalid token" in resp.body.decode("utf-8")

    def test_profile(self, make_team):
        team = make_team(active=True)
        self.dbsession.add(team)
        self.dbsession.flush()
        resp = self._login(team)
        resp = resp.goto('/profile')
        assert resp.status_int == 200
        assert team.email in resp.body.decode("utf-8")
        assert "Edit Your Team" in resp.body.decode("utf-8")

        form = resp.form
        form["email"].value = team.email + "A"
        resp = form.submit()

        assert resp.status_int == 302
        resp = resp.follow()
        assert resp.status_int == 200
        assert "Your profile has been updated" in resp.body.decode("utf-8")

    def test_teams(self):
        resp = self.app.get('/teams')
        assert resp.status_int == 200
        assert "No teams have registered" in resp.body

    def test_teams_list(self, make_team):
        t = make_team(active=True)
        t2 = make_team(active=False)
        self.dbsession.add_all([t, t2])
        resp = self.app.get('/teams')
        assert t.name in resp.body.decode("utf-8")
        assert t2.name not in resp.body.decode("utf-8")
