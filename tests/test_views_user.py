# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from .test_models_team import team
from fluxscoreboard.forms.front import LoginForm
from fluxscoreboard.views.front import UserView
from tests import skip
import pytest
import transaction


@pytest.fixture
def user_view(pyramid_request):
    view = UserView(pyramid_request)
    return view


@skip
def test_login_empty(team, user_view):
    print(user_view.request.POST)
    res = user_view.login()
    assert "form" in res
    form = res["form"]
    assert isinstance(form, LoginForm)
    assert form.email.data is None
    assert form.password.data is None


# #@pytest.mark.integration
@skip
def test_login(team, testapp, dbsession):
    login_data = {'email': team.email, 'password': team._real_password}
    dbsession.add(team)
    transaction.commit()
    resp = testapp.get('/login')
    assert resp.status_int == 200

    resp = testapp.post('/login', login_data)
    assert resp.status_int == 302

    resp = resp.follow()
    assert resp.status_int == 200
    assert "You have been logged in." in resp.body

    dbsession.delete(team)
    transaction.commit()


# @pytest.mark.integration
@skip
def test_login_failed_password(team, testapp, dbsession):
    login_data = {'email': team.email, 'password': team._real_password + '0'}
    dbsession.add(team)
    transaction.commit()
    resp = testapp.get('/login')
    assert resp.status_int == 200

    resp = testapp.post('/login', login_data)
    assert resp.status_int == 200
    assert "Login failed." in resp.body

    dbsession.delete(team)
    transaction.commit()


# @pytest.mark.integration
@skip
def test_login_failed_inactive(team, testapp, dbsession):
    login_data = {'email': team.email, 'password': team._real_password}
    team.active = False
    dbsession.add(team)
    transaction.commit()
    resp = testapp.get('/login')
    assert resp.status_int == 200

    resp = testapp.post('/login', login_data)
    assert resp.status_int == 200
    assert "Login failed." in resp.body

    dbsession.delete(team)
    transaction.commit()


# @pytest.mark.integration
@skip
def test_login_failed_invalid_team(team, testapp, dbsession):
    login_data = {'email': team.email, 'password': team._real_password}
    resp = testapp.get('/login')
    assert resp.status_int == 200

    resp = testapp.post('/login', login_data)
    assert resp.status_int == 200
    assert "Login failed." in resp.body


# @pytest.mark.integration
@skip
def test_login_not_logged_in(team, testapp, dbsession):
    login_data = {'email': team.email, 'password': team._real_password}
    dbsession.add(team)
    transaction.commit()
    resp = testapp.post('/login', login_data)

    resp = testapp.get('/login')
    assert resp.status_int == 302
    resp = resp.follow()
    assert resp.status_int == 302
    resp = resp.follow()
    assert resp.status_int == 200
    assert "Doh! You are already logged in." in resp.body

    dbsession.delete(team)
    transaction.commit()


# @pytest.mark.integration
@skip
def test_register(testapp, dbsession):
    resp = testapp.get('/register')
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