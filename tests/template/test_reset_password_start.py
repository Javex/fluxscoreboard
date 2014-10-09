# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.util import now
from fluxscoreboard.forms.front import ForgotPasswordForm
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
from mock import MagicMock
import pytest
import re


class TestResetPasswordStart(TemplateTestBase):
    name = "reset_password_start.mako"
    _form = ForgotPasswordForm    

    def _make_form_data(self):
        team = self.request.team
        data = MultiDict({'email': 'lol@example.com',
                          'submit': 'Send Reset E-Mail',
                          })
        return data

    def render(self, *args, **kw):
        kw.setdefault('form', self.form())
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = unicode(self.render())
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_email_missing(self):
        out = unicode(self.render(form=self.form(email='')))
        assert "alert" in out
        assert "alert-danger" in out
