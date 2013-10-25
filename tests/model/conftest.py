# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.challenge import Challenge
import pytest
from sqlalchemy.exc import IntegrityError


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


@pytest.fixture(scope="session")
def nullable_exc(dbsession):
    dialect = dbsession.bind.dialect.name
    if dialect == "mysql":
        return Exception
    elif dialect == "postgresql":
        return IntegrityError
