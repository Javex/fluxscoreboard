# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.util import now
from fluxscoreboard.forms.front import ResetPasswordForm
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
from mock import MagicMock
import pytest
import re


class TestResetPassword(TemplateTestBase):
    name = "reset_password.mako"
    _form = ResetPasswordForm

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team()
        dbsession.add(pyramid_request.team)
        dbsession.flush()

    def _make_form_data(self):
        team = self.request.team
        data = MultiDict({'password': 'foo2foo2foo2',
                          'password_repeat': 'foo2foo2foo2',
                          'submit': 'Set New Password',
                          })
        return data

    def render(self, *args, **kw):
        kw.setdefault('form', self.form())
        kw.setdefault('token', self.request.team.reset_token)
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render()
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_password_missing(self):
        out = self.render(form=self.form(password=''))
        assert "alert" in out
        assert "alert-danger" in out

    def test_password_repeat_missing(self):
        out = self.render(form=self.form(password_repeat=''))
        assert "alert" in out
        assert "alert-danger" in out
