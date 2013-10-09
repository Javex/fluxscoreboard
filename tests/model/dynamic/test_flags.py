# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.dynamic_challenges.flags import (flag_list,
    points_query, title, get_location, install, GeoIP, FlagView)
from fluxscoreboard.models.team import Team
from sqlalchemy.exc import OperationalError, IntegrityError
import logging
import pytest


log = logging.getLogger(__name__)


@pytest.fixture
def location(dbsession, request):
    ccode = request.param
    start, end = (dbsession.query(GeoIP.ip_range_start, GeoIP.ip_range_start).
                  filter(GeoIP.country_code == ccode)[0])
    return ccode, [start, (start + end) / 2, end]
    """country_code = label('code', GeoIP.country_code.distinct())
    country = alias(dbsession.query(country_code).subquery(), 'country')
    ip_subq = (dbsession.query(GeoIP.ip_range_start).
               filter(country.c.code == GeoIP.country_code).
               limit(1).
               as_scalar())
    q = dbsession.query(country.c.code, ip_subq)
    raise NotImplementedError"""


@pytest.fixture(scope="session")
def geoip_db(request):
    sess = DBSession()
    with sess.bind.begin() as conn:
        install(conn, False)

    def _remove():
        sess.query(GeoIP).delete()
    request.addfinalizer(_remove)


@pytest.fixture
def flag_view(pyramid_request):
    return FlagView(pyramid_request)


@pytest.fixture
def make_geoip():
    avail_flags = list(flag_list)
    count = [0]

    def _make(**kwargs):
        if "country_code" not in kwargs:
            kwargs["country_code"] = avail_flags.pop()
        kwargs.setdefault("ip_range_start", 0)
        kwargs.setdefault("ip_range_end", 0xFFFFFF)
        count[0] += 1
        return GeoIP(**kwargs)
    return _make


class TestFlagView(object):

    def test_ref(self, dbsession, flag_view, make_team, geoip_db):
        t = make_team()
        dbsession.add(t)
        dbsession.flush()
        flag_view.request.client_addr = "1.0.32.0"
        flag_view.request.matchdict["ref_id"] = t.ref_token
        ret = flag_view.ref()
        assert ret["success"]
        assert ret["msg"] == "Location successfully registered."
        assert ret["location"] == "cn"

        ret = flag_view.ref()
        print(ret)
        assert ret["success"]
        assert ret["msg"] == "Location already registered."
        assert ret["location"] == "cn"

    def test_ref_no_loc(self, dbsession, flag_view, make_team):
        t = make_team()
        dbsession.add(t)
        dbsession.flush()
        flag_view.request.client_addr = "127.0.0.1"
        flag_view.request.matchdict["ref_id"] = t.ref_token
        ret = flag_view.ref()
        assert not ret["success"]
        assert ret["msg"] == ("No location found. Try a different IP from "
                              "that range.")
        assert "location" not in ret


class TestTeamFlag(object):

    def test_team(self, make_team, make_teamflag):
        t = make_team()
        flag = make_teamflag()
        t.team_flags.append(flag)
        assert flag.team == t

    def test_init(self, make_teamflag):
        f = make_teamflag()
        assert f.flag == "zw"
        assert f.team is None
        assert f.team_id is None

    def test_nullables(self, make_teamflag, dbsession, make_team, nullable_exc):
        f = make_teamflag()
        trans = dbsession.begin_nested()
        dbsession.add(f)
        with pytest.raises(nullable_exc):
            dbsession.flush()
        trans.rollback()

        f = make_teamflag(team=make_team())
        trans = dbsession.begin_nested()
        dbsession.add(f)
        dbsession.flush()
        trans.rollback()


def test_points_query(dbsession, make_team, make_teamflag):
    t = make_team()
    dbsession.add(t)
    make_teamflag(t)
    subq = points_query()
    query = dbsession.query(subq)
    assert query.count() == 1
    assert query.first()[0] == 1


def test_points_query_multiple_flags(dbsession, make_team, make_teamflag):
    t = make_team()
    dbsession.add(t)
    [make_teamflag(t) for _ in range(10)]
    subq = points_query()
    query = dbsession.query(subq)
    assert query.count() == 1
    assert query.first()[0] == 10


def test_points_query_multiple_teams(dbsession, make_team, make_teamflag):
    t1 = make_team()
    t2 = make_team()
    dbsession.add_all([t1, t2])
    [make_teamflag(t1) for _ in range(10)]
    [make_teamflag(t2) for _ in range(7)]
    subq = points_query()
    query = dbsession.query(subq).select_from(Team).group_by(Team.id)
    assert query.count() == 2
    assert query[0][0] == 10
    assert query[1][0] == 7


def test_title():
    assert "Geolocation Flags" in title()


@pytest.mark.usefixtures("geoip_db")
def test_available_country_codes(dbsession):
    q = dbsession.query(GeoIP.country_code.distinct())
    assert q.count() == 222
    all_codes = set(item for item, in q)
    assert all_codes == set(flag_list)


@pytest.mark.usefixtures("geoip_db")
def test_get_location(dbsession):
    assert get_location("1.0.32.0") == "cn"
    assert get_location("62.122.232.0") == "pl"


class TestGeoIP(object):

    def test_nullables(self, dbsession, make_geoip, nullable_exc):
        null_ip = GeoIP.ip_int('127.0.0.1')
        g = make_geoip(ip_range_start=null_ip,
                       ip_range_end=null_ip)
        trans = dbsession.begin_nested()
        dbsession.add(g)
        dbsession.flush()
        trans.rollback()

        for param in ["ip_range_start", "ip_range_end"]:
            g = make_geoip()
            with pytest.raises(AssertionError):
                setattr(g, param, None)

        g = make_geoip()
        g.country_code = None
        dbsession.flush()
        t = dbsession.begin_nested()
        dbsession.add(g)
        with pytest.raises(nullable_exc):
            dbsession.flush()
        t.rollback()

    def test_ip_int(self):
        assert GeoIP.ip_int('127.0.0.1') == 2130706433
        assert GeoIP.ip_int("255.255.255.255") == 4294967295
        assert GeoIP.ip_int("0.0.0.0") == 0

    def test_ip_str(self):
        assert GeoIP.ip_str(2130706433L) == '127.0.0.1'
        assert GeoIP.ip_str(0xFFFFFFFF) == "255.255.255.255"
        assert GeoIP.ip_str(0) == "0.0.0.0"

    def test_check_ip_range(self, make_geoip):
        g = make_geoip()
        assert g.check_ip_range(None, 0xFFFFFFFF) == 0xFFFFFFFF
        assert g.check_ip_range(None, 0) == 0
        assert g.check_ip_range(None, 10) == 10
        for val in [-10, -1, 0xFFFFFFFF + 1]:
            with pytest.raises(AssertionError):
                g.check_ip_range(None, val)
