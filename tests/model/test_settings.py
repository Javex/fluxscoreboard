# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.util import now
from fluxscoreboard.models.settings import (Settings, load_settings,
    CTF_ARCHIVE, CTF_BEFORE, CTF_STARTED)
from pytz import utc
from mock import MagicMock
import pytest


def test_load_settings(dbsettings, dbsession):
    request = MagicMock()
    settings = load_settings(request)
    assert settings is dbsettings


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
