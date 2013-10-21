# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.views.front import FrontView
import pytest


class TestScoreboardView(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_team, dbsession, pyramid_request):
        self.make_team = make_team
        self.dbsession = dbsession
        self.view = FrontView(pyramid_request)
        self.request = pyramid_request

    def test_scoreboard_inactive_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        ret = self.view.scoreboard()
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0][0] is t1
