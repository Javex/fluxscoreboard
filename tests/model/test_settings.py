# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.models.settings import get, Settings, load_settings
from pytz import utc


def test_get(dbsettings):
    assert isinstance(get(), Settings)


def test_load_settings(dbsettings, dbsession):
    class A(object):
        pass
    event = A()
    event.request = A()
    print(dbsession.query(Settings).all())
    load_settings(event)
    assert event.request.settings is dbsettings


class TestSettings(object):

    def test_ctf_started(self):
        tomorrow = utc.localize(datetime.utcnow()) + timedelta(1)
        s = Settings(ctf_start_date=tomorrow)
        assert not s.ctf_started
        s = Settings(ctf_start_date=datetime(2012, 1, 1, tzinfo=utc))
        assert s.ctf_started

    def test_ctf_started_none(self):
        s = Settings()
        assert s.ctf_started is False
