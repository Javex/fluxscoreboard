# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from tests.template import TemplateTestBase
from fluxscoreboard.forms.front import RegisterForm
from webob.multidict import MultiDict
import pytest


class TestRegister(TemplateTestBase):
    name = "register.mako"

    @pytest.fixture(autouse=True)
    def _make_form_data(self, pyramid_request, countries):
        data = MultiDict({'name': 'test123',
                          'email': 'test@example.com',
                          'email_repeat': 'test@example.com',
                          'password': '123456789',
                          'password_repeat': '123456789',
                          'country': countries[0].id,
                          'timezone': 'UTC',
                          'submit': '1'})
        self.data = data

    def form(self, **kw):
        ip = self.request.client_addr
        self.data.update(kw)
        form = RegisterForm(self.data, csrf_context=self.request,
                            captcha={'ip_address': ip})
        form.validate()
        return form

    def test_body(self):
        out = self.render(form=self.form())
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_name(self):
        out = self.render(form=self.form(name='asd'))
        assert "alert-danger" in out
