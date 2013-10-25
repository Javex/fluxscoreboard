# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import RegisterForm
from fluxscoreboard.util import now
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
import pytest


class TestRegister(TemplateTestBase):
    name = "register.mako"

    @pytest.fixture(autouse=True)
    def _make_form_data(self, countries, dbsettings, pyramid_request):
        data = MultiDict({'name': 'test123',
                          'email': 'test@example.com',
                          'email_repeat': 'test@example.com',
                          'password': '123456789',
                          'password_repeat': '123456789',
                          'country': str(countries[0].id),
                          'timezone': 'UTC',
                          'submit': '1',
                          'csrf_token': pyramid_request.session.get_csrf_token()
                          })
        self.data = data
        self.settings = dbsettings
        pyramid_request.settings.ctf_start_date = now() - timedelta(1)
        pyramid_request.settings.ctf_end_date = now() + timedelta(1)

    def form(self, **kw):
        ip = self.request.client_addr
        self.data.update(kw)
        form = RegisterForm(self.data, csrf_context=self.request,
                            captcha={'ip_address': ip})
        form.validate()
        del form.errors["captcha"]
        print(form.errors, form.data, self.data)
        return form

    def test_body(self):
        out = self.render(form=self.form())
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_name(self):
        out = self.render(form=self.form(name=''))
        assert "alert-danger" in out
