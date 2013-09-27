# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.challenge import Challenge
from fluxscoreboard.models.team import Team
from fluxscoreboard.util import random_str
import pytest


@pytest.fixture
def challenge():
    return Challenge()


@pytest.fixture
def all_challenges():
    return [Challenge(),
            Challenge(manual=True),
            Challenge(online=True),
            Challenge(online=True, manual=True),
            Challenge(dynamic=True),
            Challenge(dynamic=True, online=True)]


@pytest.fixture
def make_team():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("name", "Team%d" % count[0])
        kwargs.setdefault("password", "Password%d" % count[0])
        kwargs.setdefault("email", "team%d@example.com" % count[0])
        kwargs.setdefault("country_id", 1)
        count[0] += 1
        return Team(**kwargs)
    return _make
