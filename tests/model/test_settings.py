# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.util import now
from fluxscoreboard.models.settings import (Settings, load_settings,
    CTF_ARCHIVE, CTF_BEFORE, CTF_STARTED, flash_global_announcement)
from pytz import utc
from mock import MagicMock
import pytest


def test_load_settings(dbsettings, dbsession):
    request = MagicMock()
    settings = load_settings(request)
    assert settings is dbsettings


class TestGlobalAnnouncementFlash(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request, dbsettings):
        self.request = pyramid_request
        self.settings = dbsettings
        self.event = MagicMock(request=self.request)

    def test_no_msg(self):
        session = self.request.session
        assert not self.settings.global_announcement
        assert not session.peek_flash('warning')
        flash_global_announcement(self.event)
        assert not session.peek_flash('warning')

    def test_msg(self):
        session = self.request.session
        self.settings.global_announcement = 'FooBar'
        assert not session.peek_flash('warning')
        flash_global_announcement(self.event)
        expected = [self.settings.global_announcement]
        assert session.peek_flash('warning') == expected

    def test_existing_msg(self):
        session = self.request.session
        self.settings.global_announcement = 'FooBar2'
        session.flash('FooBar2', 'warning')
        flash_global_announcement(self.event)
        expected = ['FooBar2']
        assert session.peek_flash('warning') == expected

    def test_persist_other_msgs(self):
        session = self.request.session
        session.flash('OtherMsg', 'warning')
        self.settings.global_announcement = 'FooBar'
        flash_global_announcement(self.event)
        expected = ['OtherMsg', 'FooBar']
        assert session.peek_flash('warning') == expected


class TestSettings(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession):
        self.dbsession = dbsession

    def test_defaults(self):
        s = Settings()
        assert s.submission_disabled is None
        assert s.archive_mode is None

        self.dbsession.add(s)
        self.dbsession.flush()

        assert s.submission_disabled is False
        assert s.archive_mode is False

    def test_ctf_started(self):
        tomorrow = now() + timedelta(1)
        s = Settings(ctf_start_date=tomorrow)
        assert not s.ctf_started
        s = Settings(ctf_start_date=datetime(2012, 1, 1, tzinfo=utc))
        assert s.ctf_started

    def test_ctf_started_none(self):
        s = Settings()
        assert s.ctf_started is False

    def test_ctf_state_archive(self):
        s = Settings(archive_mode=True)
        assert s.ctf_state is CTF_ARCHIVE

    def test_ctf_state_started(self):
        s = Settings(ctf_start_date=datetime(2012, 1, 1, tzinfo=utc))
        assert s.ctf_state is CTF_STARTED

    def test_ctf_state_before(self):
        tomorrow = now() + timedelta(1)
        s = Settings(ctf_start_date=tomorrow)
        assert s.ctf_state is CTF_BEFORE

    def test_ctf_state_default(self):
        s = Settings()
        assert s.ctf_state is CTF_BEFORE
