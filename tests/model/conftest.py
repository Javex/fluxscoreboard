# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
import pytest
from fluxscoreboard.models import Challenge, MassMail, Team


@pytest.fixture
def challenge():
    return Challenge()


@pytest.fixture
def all_challenges(make_challenge):
    return [make_challenge(),
            make_challenge(manual=True),
            make_challenge(online=True),
            make_challenge(online=True, manual=True),
            make_challenge(dynamic=True),
            make_challenge(dynamic=True, online=True)]


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


@pytest.fixture
def make_challenge():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("title", "Challenge%d" % count[0])
        count[0] += 1
        return Challenge(**kwargs)
    return _make


@pytest.fixture
def make_massmail():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("subject", "Test%d" % count[0])
        kwargs.setdefault("message", "TestMsg%d" % count[0])
        kwargs.setdefault("recipients", ["test%d@example.com" % count[0]])
        kwargs.setdefault("from_", "from%d@example.com" % count[0])
        count[0] += 1
        return MassMail(**kwargs)
    return _make
