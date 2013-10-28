# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.models.challenge import Submission
from fluxscoreboard.models.news import News
from fluxscoreboard.util import now
from fluxscoreboard.views.front import BaseView
from tests.view import BaseViewTest


class TestBaseView(BaseViewTest):

    view_class = BaseView

    def test_team(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.request.team = t
        assert self.view.team is t

    def test_team_none(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        assert self.view.team is None

    def test_team_count(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        assert self.view.team_count == 1

    def test_leading_team(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=True)
        t3 = self.make_team(active=False)
        c = self.make_challenge(points=100)
        self.dbsession.add_all([t1, t2, t3, c])
        Submission(team=t1, challenge=c)
        Submission(team=t3, challenge=c, bonus=1)
        assert self.view.leading_team is t1

    def test_announcements(self):
        n1 = News(published=False)
        n2 = News(published=True)
        self.dbsession.add_all([n1, n2])
        ret = list(self.view.announcements)
        assert len(ret) == 1
        assert ret[0] == n2

    def test_announcements_with_challenge(self):
        c = self.make_challenge(published=True)
        self.dbsession.add(c)
        n = News(published=True, challenge=c)
        ret = list(self.view.announcements)
        assert len(ret) == 1
        assert ret[0] == n

    def test_seconds_until_end(self):
        self.settings.ctf_end_date = now() + timedelta(0, 2)
        assert self.view.seconds_until_end == 1

    def test_seconds_until_end_days(self):
        self.settings.ctf_end_date = now() + timedelta(2)
        assert self.view.seconds_until_end == 172799
