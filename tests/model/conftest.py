# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.challenge import Challenge
import pytest


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