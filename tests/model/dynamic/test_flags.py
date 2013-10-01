# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.dynamic_challenges.flags import (flag_list, TeamFlag,
    points_query, title, get_location, install, GeoIP)
from fluxscoreboard.models.team import Team
from sqlalchemy.orm.util import aliased
from sqlalchemy.sql.expression import alias, label
from webhelpers.constants import country_codes
import logging
import pytest
import transaction


log = logging.getLogger(__name__)


@pytest.fixture
def make_teamflag():
    avail_flags = list(flag_list)

    def _make(team):
        return TeamFlag(team=team, flag=avail_flags.pop())
    return _make


@pytest.fixture(params=flag_list)
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


def test_ip_int():
    assert GeoIP.ip_int('127.0.0.1') == 2130706433
    assert GeoIP.ip_int("255.255.255.255") == 4294967295
    assert GeoIP.ip_int("0.0.0.0") == 0


def test_ip_str():
    assert GeoIP.ip_str(2130706433L) == '127.0.0.1'
    assert GeoIP.ip_str(0xFFFFFFFF) == "255.255.255.255"
    assert GeoIP.ip_str(0) == "0.0.0.0"
