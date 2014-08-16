# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.util import now
from fluxscoreboard.models import Submission
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
from mock import MagicMock
import pytest
import re


class TestChallenges(TemplateTestBase):
    name = "challenges.mako"

    @pytest.fixture(autouse=True)
    def _create_challenge(self, make_challenge, make_category, make_news,
                          dbsession):
        self.challenge = make_challenge(title="ChallengeFoo",
                                        online=True)
        self.challenge.category = make_category(name="CategoryFoo")
        self.challenge.announcements.append(make_news(message="FooAnn",
                                                      published=True))
        dbsession.add(self.challenge)
        dbsession.flush()
        self.challenges = [(self.challenge, False, 1337)]

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team()
        dbsession.add(pyramid_request.team)
        dbsession.flush()

    def _make_form_data(self):
        data = MultiDict({'solution': 'Foo',
                          })
        return data

    def render(self, *args, **kw):
        kw.setdefault('challenges', self.challenges)
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render()
        assert "ChallengeFoo" in out
        assert "1337" in out
        assert "CategoryFoo" in out
        assert "online" in out
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_no_category(self):
        self.challenge.category = None
        out = self.render()
        assert "<em>None</em>" in out

    def test_dynamic(self):
        self.challenge.points = 1338
        self.challenge.dynamic = True
        out = self.render()
        assert "1338" not in out

    def test_manual(self):
        self.challenge.manual = True
        out = self.render()
        assert "<em>evaluated</em>" in out

    def test_no_points(self):
        out = self.render()
        assert re.search(r'<td>\s+-\s+</td>', out)

    def test_dynamic_solved_count(self):
        self.challenge.dynamic = True
        out = self.render()
        assert re.search(r'<td>\s+-\s+</td>\s+<td>\s+-\s+</td>', out)

    def test_challenge_offline(self):
        self.challenge.online = False
        out = self.render()
        assert "offline" in out
