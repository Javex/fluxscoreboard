# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from tests.template import TemplateTestBase
from fluxscoreboard.models import Submission
from mock import MagicMock
import pytest
import re


class TestTeams(TemplateTestBase):
    name = "teams.mako"

    @pytest.fixture(autouse=True)
    def _create_challenge(self, make_challenge, make_category, make_news,
                          dbsession):
        self.challenge = make_challenge(title="TitleFoo",
                                        online=True)
        dbsession.add(self.challenge)
        dbsession.flush()
        self.challenges = [self.challenge]

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team()
        dbsession.add(pyramid_request.team)
        dbsession.flush()
        self.team = pyramid_request.team
        self.teams = [pyramid_request.team]

    def render(self, *args, **kw):
        kw.setdefault('teams', self.teams)
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render()
        assert "alert" not in out.text
        assert "alert-danger" not in out.text
        assert "TitleFoo" not in out.text
        assert "<td>1338</td>" not in unicode(out)
        assert out.find("td", class_='avatar')
        assert self.team.name in out.text
        assert str(self.team.country) in out.text
        assert '<td>1337</td>' not in unicode(out)

    def test_no_teams(self):
        self.teams = []
        out = unicode(self.render())
        assert "No teams have registered" in out

    def test_avatar(self):
        self.team.avatar_filename = 'foo.jpg'
        out = unicode(self.render())
        assert 'foo.jpg' in out
