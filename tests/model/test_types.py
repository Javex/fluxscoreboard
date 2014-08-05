from __future__ import unicode_literals
import pytest
from datetime import datetime
from fluxscoreboard.models import Base
from fluxscoreboard.models.types import TZDateTime, Timezone, JSONList, Module
from fluxscoreboard.util import now
from sqlalchemy import Column, Integer
from sqlalchemy.exc import StatementError
from pytz import utc, timezone
from mock import MagicMock

class TestType(object):

    def add(self, item):
        self.dbsession.add(item)
        self.dbsession.flush()
        self.dbsession.expire(item)

    @pytest.fixture
    def make_table(self, request, dbsession):
        table_name = request.function.__name__

        def _make(type_):
            cols = {
                'id': Column(Integer, primary_key=True),
                'col': Column(type_),
            }
            MyTable = type(table_name, (Base,), cols)
            Base.metadata.create_all(bind=dbsession.connection())
            return MyTable

        return _make

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_table):
        self.dbsession = dbsession
        self.Table = make_table(self.type_)

class TestTZDateTime(TestType):

    type_ = TZDateTime

    def test_TZDateTime(self):
        date = utc.localize(datetime(2012, 1, 1, 1))
        item = self.Table(col=date)
        self.add(item)
        assert item.col == date

    def test_TZDateTime_none(self):
        item = self.Table()
        self.add(item)
        assert item.col is None

    def test_TZDateTime_no_tzinfo(self):
        date = datetime(2012, 1, 1, 1)
        item = self.Table(col=date)
        self.add(item)
        assert item.col == utc.localize(date)

    def test_TZDateTime_other_tz(self):
        utc_date = utc.localize(datetime(2012, 1, 1, 1))
        date = utc_date.astimezone(timezone("Europe/Berlin"))
        item = self.Table(col=date)
        self.add(item)
        assert item.col == utc_date

class TestTimezone(TestType):

    type_ = Timezone

    def test_Timezone(self):
        tz = timezone("Europe/Berlin")
        item = self.Table(col=tz)
        self.add(item)
        assert item.col == tz

    def test_Timezone_str(self):
        tz = "Europe/Berlin"
        item = self.Table(col=tz)
        self.add(item)
        assert item.col == timezone(tz)

    def test_Timezone_none(self):
        item = self.Table()
        self.add(item)
        assert item.col is None

    def test_Timezone_invalid(self):
        item = self.Table(col="Bla/foo")
        with pytest.raises(StatementError):
            self.add(item)


class TestModule(TestType):

    type_ = Module

    @pytest.fixture(autouse=True)
    def _create_dynamic_challenge(self):
        from fluxscoreboard.models import dynamic_challenges
        self.module = MagicMock()
        dynamic_challenges.registry["test_module"] = self.module

    def test_Module(self):
        item = self.Table(col="test_module")
        self.add(item)
        assert item.col is self.module

    def test_Module_none(self):
        item = self.Table()
        self.add(item)
        assert item.col is None

    def test_Module_empty(self):
        item = self.Table(col='')
        self.add(item)
        assert item.col == ''

    def test_Module_invalid(self):
        item = self.Table(col="does_not_exist")
        self.add(item)
        with pytest.raises(KeyError):
            item.col
