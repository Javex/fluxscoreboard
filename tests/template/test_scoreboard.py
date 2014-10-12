# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from tests.template import TemplateTestBase
from fluxscoreboard.models import Submission
from mock import MagicMock
import pytest
import re


class TestScoreboard(TemplateTestBase):
    name = "scoreboard.mako"

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
        self.teams = [(pyramid_request.team, 1337, 1338)]

    def render(self, *args, **kw):
        kw.setdefault('teams', self.teams)
        kw.setdefault('challenges', self.challenges)
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render()
        assert "alert" not in out.text
        assert "alert-danger" not in out.text
        assert "TitleFoo" in out.text
        assert "<td>1338</td>" in unicode(out)
        assert out.find("td", class_='avatar')
        assert self.team.name in out.text
        assert str(self.team.country) in out.text
        assert out.find("td", class_="text-danger").string.strip() == "No"
        assert out.find("td", class_="challenge").string.strip() == "-"
        assert '<td>1337</td>' in unicode(out)

    def test_no_challenges(self):
        self.challenges = []
        out = unicode(self.render())
        assert '<td class="challenge">' not in out

    def test_no_teams(self):
        self.teams = []
        out = unicode(self.render())
        assert not re.search(r'<tbody>.*<tr', out, re.DOTALL)

    def test_avatar(self):
        self.team.avatar_filename = 'foo.jpg'
        out = unicode(self.render())
        assert 'foo.jpg' in out

    def test_local(self):
        self.team.local = True
        out = unicode(self.render())
        assert re.search(r'<td class="text-success">\s+Yes\s+</td>', out)

    def test_challenge_dynamic_mock(self, module):
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = module
        module.get_points.return_value = 1337
        out = unicode(self.render())
        assert "1337" in out

    def test_challenge_dynamic(self, dynamic_module):
        _, module = dynamic_module
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = module
        out = unicode(self.render())
        assert isinstance(out, unicode)

    def test_challenge_bonus(self):
        Submission(challenge=self.challenge, team=self.team,
                   additional_pts=321)
        out = unicode(self.render())
        expected_pts = self.challenge.points + 321
        assert unicode(expected_pts) in out
