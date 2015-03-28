# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.util import now
from fluxscoreboard.models import Submission
from fluxscoreboard.models.challenge import update_challenge_points, update_playing_teams
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
        self.db = dbsession
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
        out = unicode(self.render())
        assert "ChallengeFoo" in out
        assert "1337" in out
        assert "CategoryFoo" in out
        assert "online" in out
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_no_category(self):
        self.challenge.category = None
        out = unicode(self.render())
        assert "<em>None</em>" in out

    @pytest.mark.skipif(True, reason="Broken")
    def test_dynamic(self):
        self.challenge.base_points = 1338
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = MagicMock()
        self.challenge.module.update_points.return_value = False
        update_playing_teams(self.db.connection())
        update_challenge_points(self.db.connection())
        self.db.flush()
        self.db.expire(self.challenge)
        out = self.render()
        points = out.find("tbody").find("tr").find_all("td")[3]
        assert points.text.strip() == '-'

    def test_manual(self):
        self.challenge.manual = True
        self.challenge.base_points = None
        out = unicode(self.render())
        assert "<em>evaluated</em>" in out

    @pytest.mark.skipif(True, reason="Broken")
    def test_dynamic_solved_count(self):
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = MagicMock()
        self.challenge.module.update_points.return_value = False
        out = unicode(self.render())
        assert re.search(r'<td>\s+-\s+</td>\s+<td>\s+-\s+</td>', out)

    def test_challenge_offline(self):
        self.challenge.online = False
        out = unicode(self.render())
        assert "offline" in out
