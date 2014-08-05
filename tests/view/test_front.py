# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import SolutionSubmitForm
from fluxscoreboard.models.challenge import Submission
from fluxscoreboard.models.news import News
from fluxscoreboard.util import now
from fluxscoreboard.views.front import FrontView
from pyramid.httpexceptions import HTTPFound
from webob.multidict import MultiDict
import pytest
from tests.view import BaseViewTest


class TestScoreboardView(BaseViewTest):

    view_class = FrontView

    @pytest.mark.usefixtures("config", "ctf_state")
    def test_home(self):
        ret = self.view.home()
        assert isinstance(ret, HTTPFound)

    def test_challenges(self):
        c1 = self.make_challenge(online=True, published=True)
        c2 = self.make_challenge(online=False, published=True)
        self.dbsession.add_all([c1, c2])
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 2
        assert challenges[0] == (c1, False, 0)
        assert challenges[1] == (c2, False, 0)

    def test_challenges_solved_count(self):
        c1 = self.make_challenge(published=True)
        t1 = self.make_team()
        self.dbsession.add_all([c1, t1])
        Submission(challenge=c1, team=t1)
        ret = self.view.challenges()
        assert len(ret) == 1
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] == (c1, False, 1)

    def test_challenges_team_solved(self):
        c1 = self.make_challenge(published=True)
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
        c = self.make_challenge(published=True)
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
        c = self.make_challenge(published=True)
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
        c = self.make_challenge(solution="Test", online=True, published=True)
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
        c = self.make_challenge(solution="Test", online=True, published=True)
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
        c = self.make_challenge(points=100, published=True)
        self.dbsession.add_all([t1, t2, c])
        Submission(challenge=c, team=t1)
        ret = self.view.scoreboard()
        assert len(ret) == 2
        teams = list(ret["teams"])
        assert len(teams) == 2
        assert teams[0] == (t1, 100, 1)
        assert teams[1] == (t2, 0, 2)
        challenges = list(ret["challenges"])
        assert len(challenges) == 1
        assert challenges[0] is c

    def test_scoreboard_inactive_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        ret = self.view.scoreboard()
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0][0] is t1

    def test_teams(self):
        t1 = self.make_team(active=True)
        self.dbsession.add(t1)
        ret = self.view.teams()
        assert len(ret) == 1
        teams = list(ret["teams"])
        assert len(teams) == 1
        assert teams[0] is t1

    def test_teams_inactive(self):
        t1 = self.make_team(active=False)
        self.dbsession.add(t1)
        ret = self.view.teams()
        assert len(ret) == 1
        teams = list(ret["teams"])
        assert len(teams) == 0

    def test_news(self):
        n1 = News(published=False)
        n2 = News(published=True)
        self.dbsession.add_all([n1, n2])
        ret = self.view.news()
        assert len(ret) == 1
        news = list(ret["announcements"])
        assert len(news) == 1
        assert news[0] is n2

    def test_submit_solution(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        self.dbsession.add(c)
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.team = t
        self.login(t.id)
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                      solution="Test", challenge=str(c.id))
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.submit_solution()
        assert len(self.request.session.peek_flash('success')) == 1
        assert len(self.request.session.peek_flash('error')) == 0
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 1

    def test_submit_solution_wrong(self):
        token = self.request.session.get_csrf_token()
        c = self.make_challenge(solution="Test", online=True, published=True)
        self.dbsession.add(c)
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.team = t
        self.login(t.id)
        self.request.POST = MultiDict(submit="submit", csrf_token=token,
                                      solution="Test1", challenge=str(c.id))
        self.request.method = "POST"
        self.settings.ctf_end_date = now() + timedelta(1)
        ret = self.view.submit_solution()
        assert len(self.request.session.peek_flash('success')) == 0
        assert len(self.request.session.peek_flash('error')) == 1
        assert isinstance(ret, HTTPFound)
        assert self.dbsession.query(Submission).count() == 0

    def test_verify_token(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        self.settings.ctf_end_date = now() + timedelta(1)
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        assert t.challenge_token
        self.request.matchdict['token'] = t.challenge_token
        ret = self.view.verify_token()
        assert ret.body == '1'

    def test_verify_token_inactive_team(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        self.settings.ctf_end_date = now() + timedelta(1)
        t = self.make_team(active=False)
        self.dbsession.add(t)
        self.dbsession.flush()
        assert t.challenge_token
        self.request.matchdict['token'] = t.challenge_token
        ret = self.view.verify_token()
        assert ret.body == '0'

    def test_verify_token_archive(self):
        self.settings.archive_mode = True
        self.request.matchdict["token"] = "foo"
        assert self.view.verify_token().body == '1'

    def test_verify_token_before_start(self):
        self.settings.ctf_start_date = now() + timedelta(1)
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.request.matchdict['token'] = t.challenge_token
        assert t.challenge_token
        assert self.view.verify_token().body == '0'
