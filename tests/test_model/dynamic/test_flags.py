# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from .. import make_team
from ...fixture import dbsession
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.dynamic_challenges.flags import flag_list, TeamFlag, \
    points_query, title, get_location, install, GeoIP
from fluxscoreboard.models.team import Team
from sqlalchemy.orm.util import aliased
from sqlalchemy.sql.expression import alias, label
from webhelpers.constants import country_codes
import logging
import pytest


log = logging.getLogger(__name__)


@pytest.fixture
def make_teamflag():
    avail_flags = list(flag_list)

    def _make(team):
        return TeamFlag(team=team, flag=avail_flags.pop())
    return _make


def _get_ip_location_pair():
    raise NotImplementedError


@pytest.fixture
def location():
    raise NotImplementedError


"""@pytest.fixture(scope="module")
def geoip_db(request):
    sess = DBSession()
    install(sess.connection(), with_update=False)

    def _empty_db():
        sess.query(GeoIP).delete()
    request.addfinalizer(_empty_db)"""


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
    log.debug("Starting...")
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
    log.debug("Finishing...")


def test_title():
    assert "Geolocation Flags" in title()


# @pytest.mark.usefixtures("geoip_db")
def test_get_location(dbsession):
    country_code = label('code', GeoIP.country_code.distinct())
    country = alias(dbsession.query(country_code).subquery(), 'country')
    ip_subq = (dbsession.query(GeoIP.ip_range_start).
               filter(country.c.code == GeoIP.country_code).
               as_scalar())
    q = dbsession.query(country.c.code, ip_subq)
    print(q, len(q.all()))
    raise NotImplementedError
    ip, loc_short = location
    assert get_location(ip) == loc_short
