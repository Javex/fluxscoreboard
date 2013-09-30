# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models.team import get_team, groupfinder, TEAM_GROUPS, \
    get_all_teams, Team, get_active_teams
from . import logged_in, pyramid_request, config, \
    auth_pol
from .fixture import dbsession
import pytest


def create_team():
    t = Team(name="Test",
             password="Test123",
             email="test@example.com",
             country_id=1,
             active=True,
             timezone="Europe/Berlin",
             )
    return t


@pytest.fixture(scope="function")
def team():
    t = create_team()
    t._real_password = "Test123"
    return t


@pytest.fixture
def inactive_team():
    team = create_team()
    team.email = 'inactive@example.com'
    team.active = False
    return team


@pytest.fixture
def local_team():
    team = create_team()
    team.email = 'local@example.com'
    team.local = True
    return team


@pytest.fixture
def inactive_local_team():
    team = create_team()
    team.email = 'inactive-local@example.com'
    team.active = False
    team.local = True
    return team


@pytest.fixture
def all_teams(dbsession, request, team, inactive_team, local_team,
              inactive_local_team):
    teams = [team, inactive_team, local_team, inactive_local_team]
    dbsession.add_all(teams)

    def delete():
        for team in teams:
            dbsession.delete(team)
    request.addfinalizer(delete)
    return teams


@pytest.fixture
def active_teams(dbsession, request, team, local_team):
    teams = [team, local_team]
    dbsession.add_all(teams)

    def delete():
        for team in teams:
            dbsession.delete(team)
    request.addfinalizer(delete)
    return teams


def test_get_team(logged_in, pyramid_request, team):
    t = get_team(pyramid_request)
    assert t is team
    assert pyramid_request.team is t


def test_get_team_none(auth_pol, pyramid_request):
    t = get_team(pyramid_request)
    assert t is None
    assert pyramid_request.team is None


def test_groupfinder(logged_in, pyramid_request):
    assert groupfinder(None, pyramid_request) == TEAM_GROUPS


def test_groupfinder_none(pyramid_request, auth_pol):
    assert groupfinder(None, pyramid_request) is None


def test_get_all_teams(dbsession, all_teams):
    teams = list(get_all_teams())
    print(teams)
    assert len(teams) == len(all_teams)
    for team in teams:
        assert team in all_teams


def test_get_active_teams(dbsession, active_teams):
    teams = list(get_active_teams())
    assert len(teams) == len(active_teams)
    for team in teams:
        assert team in active_teams


@pytest.mark.skip
def get_team_solved_subquery(dbsession, team_id):
    assert 0
