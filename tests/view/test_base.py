# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta, datetime
from fluxscoreboard.models.challenge import Submission
from fluxscoreboard.models.news import News
from fluxscoreboard.util import now
from fluxscoreboard.views.front import BaseView
from fluxscoreboard.models.settings import CTF_BEFORE, CTF_STARTED, CTF_ARCHIVE
from tests.view import BaseViewTest
from pyramid.security import forget
from mock import MagicMock, patch
import pytest


class TestBaseView(BaseViewTest):

    view_class = BaseView

    def test_current_state_before_nologin(self):
        assert self.view.current_state == (CTF_BEFORE, False)

    def test_current_state_before_login(self):
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.login(t.id)
        assert self.view.current_state == (CTF_BEFORE, True)

    def test_current_state_started_nologin(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        assert self.view.current_state == (CTF_STARTED, False)

    def test_current_state_started_login(self):
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.login(t.id)
        self.settings.ctf_start_date = now() - timedelta(1)
        assert self.view.current_state == (CTF_STARTED, True)

    def test_current_state_archive_nologin(self):
        self.settings.archive_mode = True
        assert self.view.current_state == (CTF_ARCHIVE, False)

    def test_current_state_archive_login(self):
        t = self.make_team(active=True)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.login(t.id)
        self.settings.archive_mode = True
        assert self.view.current_state == (CTF_ARCHIVE, False)

    def test_menu_fixed_length(self):
        self.request.matched_route = MagicMock(return_value='/foo')
        with patch('fluxscoreboard.views.front.display_design') as m:
            m.return_value = True
            assert len(self.view.menu) == 5

    def test_menu(self):
        self.request.matched_route = MagicMock(return_value='/foo')
        for k, v in self.view.menu:
            assert isinstance(k, unicode)
            assert isinstance(v, unicode)

    def test_team_count(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=False)
        self.dbsession.add_all([t1, t2])
        assert self.view.team_count == 1

    def test_announcements(self):
        n1 = News(published=False, timestamp=datetime.utcnow() - timedelta(0, 1))
        n2 = News(published=True, timestamp=datetime.utcnow() - timedelta(0, 1))
        self.dbsession.add_all([n1, n2])
        ret = list(self.view.announcements)
        assert len(ret) == 1
        assert ret[0] == n2

    def test_announcements_with_challenge(self):
        c = self.make_challenge(published=True)
        self.dbsession.add(c)
        n = News(published=True, challenge=c, timestamp=datetime.utcnow() - timedelta(0, 1))
        ret = list(self.view.announcements)
        assert len(ret) == 1
        assert ret[0] == n

    def test_seconds_until_end(self):
        self.settings.ctf_end_date = now() + timedelta(0, 2)
        assert self.view.seconds_until_end == 1

    def test_seconds_until_end_days(self):
        self.settings.ctf_end_date = now() + timedelta(2)
        assert self.view.seconds_until_end == 172799

    def test_seconds_until_end_archive(self):
        self.settings.archive_mode = True
        with pytest.raises(ValueError):
            self.view.seconds_until_end

    def test_ctf_progress_archive(self):
        self.settings.archive_mode = True
        assert self.view.ctf_progress == 1

    def test_ctf_progress_over_1(self):
        self.settings.ctf_end_date = now() - timedelta(1)
        self.settings.ctf_start_date = now() - timedelta(2)
        assert self.view.ctf_progress == 1

    def test_ctf_progress_negative(self):
        self.settings.ctf_end_date = now() + timedelta(2)
        self.settings.ctf_start_date = now() + timedelta(1)
        assert self.view.ctf_progress == 0

    def test_ctf_progress_normal(self):
        self.settings.ctf_start_date = now() - timedelta(1)
        self.settings.ctf_end_date = now() + timedelta(1)
        assert round(self.view.ctf_progress, 1) == 0.5
