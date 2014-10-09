# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import RegisterForm
from fluxscoreboard.util import now
from tests.template import TemplateTestBase
from webob.multidict import MultiDict


class TestRegister(TemplateTestBase):
    name = "register.mako"
    _form = RegisterForm

    def _make_form_data(self):
        data = MultiDict({'name': 'test123',
                          'email': 'test@example.com',
                          'email_repeat': 'test@example.com',
                          'password': '123456789',
                          'password_repeat': '123456789',
                          'country': str(self.countries[0].id),
                          'timezone': 'UTC',
                          'submit': '1',
                          })
        return data

    def form(self, **kw):
        f = TemplateTestBase.form(self, **kw)
        del f.errors["captcha"]
        return f

    def test_body(self):
        out = unicode(self.render(form=self.form()))
        assert "alert" not in out
        assert "alert-danger" not in out
        assert "CTF starts at" not in out

    def test_name_missing(self):
        out = unicode(self.render(form=self.form(name='')))
        assert "alert-danger" in out

    def test_email_missing(self):
        out = unicode(self.render(form=self.form(email='')))
        assert "alert-danger" in out

    def test_email_repeat_missing(self):
        out = unicode(self.render(form=self.form(email_repeat='')))
        assert "alert-danger" in out

    def test_password_missing(self):
        out = unicode(self.render(form=self.form(password='')))
        assert "alert-danger" in out

    def test_password_repeat_missing(self):
        out = unicode(self.render(form=self.form(password_repeat='')))
        assert "alert-danger" in out

    def test_country_wrong(self):
        out = unicode(self.render(form=self.form(country='1234')))
        assert "alert-danger" in out

    def test_size_wrong(self):
        out = unicode(self.render(form=self.form(size='foobla')))
        assert "alert-danger" in out

    def test_ctf_start_hint(self):
        self.settings.ctf_start_date = now() + timedelta(hours=1)
        out = unicode(self.render(form=self.form()))
        assert "CTF starts at" in out
