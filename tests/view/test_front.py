# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import SolutionSubmitForm
from fluxscoreboard.models.challenge import Submission
from fluxscoreboard.util import now
from fluxscoreboard.views.front import FrontView
from pyramid.httpexceptions import HTTPFound
from webob.multidict import MultiDict
import pytest
from tests.view import BaseViewTest


class TestScoreboardView(BaseViewTest):

    view_class = FrontView

    @pytest.mark.usefixtures("config")
    def test_home(self):
        ret = self.view.home()
        assert isinstance(ret, HTTPFound)

    def test_challenges(self):
        c1 = self.make_challenge(online=True)
        c2 = self.make_challenge(online=False)
        self.dbsession.add_all([c1, c2])
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 2
        assert challenges[0] == (c1, False, 0)
        assert challenges[1] == (c2, False, 0)

    def test_challenges_solved_count(self):
        c1 = self.make_challenge()
        t1 = self.make_team()
        self.dbsession.add_all([c1, t1])
        Submission(challenge=c1, team=t1)
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] == (c1, False, 1)

    def test_challenges_team_solved(self):
        c1 = self.make_challenge()
        t1 = self.make_team()
        self.dbsession.add_all([c1, t1])
        self.dbsession.flush()
        Submission(challenge=c1, team=t1)
        self.login(t1.id)
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] == (c1, True, 1)

    def test_challenge(self):
        c = self.make_challenge()
        self.dbsession.add(c)
        self.dbsession.flush()
        self.view.request.matchdict["id"] = c.id
        ret = self.view.challenge()
        assert len(ret) == 3
        assert isinstance(ret["form"], SolutionSubmitForm)
        assert not ret["is_solved"]
        challenge = ret["challenge"]
        assert challenge is c

    def test_challenge_solved(self):
        c = self.make_challenge()
        t = self.make_team()
        self.dbsession.add_all([t, c])
        Submission(challenge=c, team=t)
        self.dbsession.flush()
        self.login(t.id)
        self.view.request.matchdict["id"] = c.id
        ret = self.view.challenge()
        assert len(ret) == 3
        assert isinstance(ret["form"], SolutionSubmitForm)
        assert ret["is_solved"]
        assert ret["challenge"] is c

    def test_challenge_solution_submit(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True)
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        self.login(t.id)
        self.request.matchdict["id"] = c.id
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                           solution="Test")
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.challenge()
        assert len(self.request.session.peek_flash('success')) == 1
        assert len(self.request.session.peek_flash('error')) == 0
        assert isinstance(ret, HTTPFound)
        subm = self.dbsession.query(Submission).one()
        assert subm.challenge == c
        assert subm.team == t

    def test_challenge_solution_submit_unsolved(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True)
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        self.login(t.id)
        self.request.matchdict["id"] = c.id
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                           solution="Test1")
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.challenge()
        assert len(self.request.session.peek_flash('error')) == 1
        assert len(self.request.session.peek_flash('success')) == 0
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 0

    def test_scoreboard(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=True)
        c = self.make_challenge(points=100)
        self.dbsession.add_all([t1, t2, c])
        Submission(challenge=c, team=t1)
        ret = self.view.scoreboard()
        assert len(ret) == 1
        teams = list(ret["teams"])
        assert len(teams) == 2
        assert teams[0] == (t1, 100, 1)
        assert teams[1] == (t2, 0, 2)

    def test_scoreboard_inactive_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        ret = self.view.scoreboard()
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0][0] is t1
