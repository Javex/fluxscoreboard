# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import LoginForm
from fluxscoreboard.util import now
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
import pytest


class TestLogin(TemplateTestBase):
    name = "login.mako"
    _form = LoginForm

    def _make_form_data(self):
        data = MultiDict({'email': 'test@example.com',
                          'password': '123456789',
                          'login': 'Login',
                          })
        return data

    def test_body(self):
        out = self.render(form=self.form())
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_email_missing(self):
        out = self.render(form=self.form(email=''))
        assert "alert-danger" in out

    def test_password_missing(self):
        out = self.render(form=self.form(password=''))
        assert "alert-danger" in out
