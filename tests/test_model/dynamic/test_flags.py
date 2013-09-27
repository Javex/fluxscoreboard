# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from .. import make_team
from ...fixture import dbsession
from fluxscoreboard.models.dynamic_challenges.flags import (flag_list, TeamFlag,
    points_query, title, get_location)
from fluxscoreboard.models.team import Team
import pytest


@pytest.fixture
def make_teamflag():
    avail_flags = list(flag_list)

    def _make(team):
        return TeamFlag(team=team, flag=avail_flags.pop())
    return _make


def _get_ip_location_pair():
    raise NotImplementedError


@pytest.fixture(params=[])
def location():
    raise NotImplementedError


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
    print(query.all())
    assert query.count() == 2
    assert query[0][0] == 10
    assert query[1][0] == 7


def test_title():
    assert "Geolocation Flags" in title()


def test_get_location(location, dbsession):
    raise NotImplementedError
    ip, loc_short = location
    assert get_location(ip) == loc_short
