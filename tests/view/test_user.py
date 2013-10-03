# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.forms.front import LoginForm
from fluxscoreboard.views.front import UserView
from pyramid.security import authenticated_userid
import pytest


@pytest.mark.usefixtures("config")
class TestUserView(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_team, dbsession, pyramid_request, login_team):
        self.login = login_team
        self.make_team = make_team
        self.dbsession = dbsession
        self.request = pyramid_request
        self.view = UserView(self.request)

    def _create_team(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        return t

    def test_logout(self):
        t = self._create_team()
        self.login(t.id)
        print(self.request.session)
        assert authenticated_userid(self.request) == t.id
        ret = self.view.logout()
        assert ret.code == 302
        assert not authenticated_userid(self.request)
        flash_msgs = self.request.session.peek_flash()
        assert len(flash_msgs)
        assert flash_msgs[0] == "You have been logged out."

    def test_login_get(self):
        ret = self.view.login()
        assert isinstance(ret, dict)
        assert "form" in ret
        assert isinstance(ret["form"], LoginForm)
