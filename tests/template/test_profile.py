# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.util import now
from fluxscoreboard.forms.front import ProfileForm
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
from mock import MagicMock
import pytest
import re


class TestProfile(TemplateTestBase):
    name = "profile.mako"

    def _form(self, *args, **kw):
        kw.setdefault("obj", self.request.team)
        return ProfileForm(*args, **kw)

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team()
        dbsession.add(pyramid_request.team)
        dbsession.flush()

    def _make_form_data(self):
        team = self.request.team
        data = MultiDict({'email': team.email,
                          'country': str(team.country.id),
                          'timezone': str(team.timezone),
                          'submit': 'Save',
                          })
        return data

    def render(self, *args, **kw):
        kw.setdefault('form', self.form())
        kw.setdefault('team', self.request.team)
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = unicode(self.render())
        assert "alert" not in out
        assert "alert-danger" not in out
        assert "Edit Your Team" in out
