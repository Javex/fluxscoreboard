# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import main
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import Challenge, Submission
from fluxscoreboard.models.news import MassMail, News
from fluxscoreboard.models.team import Team
from pyramid import testing
from webob.multidict import MultiDict
from webtest.app import TestApp
import pytest
import logging
from pyramid.tests.test_security import _registerAuthenticationPolicy


log = logging.getLogger(__name__)
skip = pytest.mark.skipif("True")


@pytest.fixture
def auth_pol(pyramid_request):
    _registerAuthenticationPolicy(pyramid_request.registry, '12345')


@pytest.fixture
def logged_in(dbsession, team, request, pyramid_request):
    dbsession.add(team)
    dbsession.flush()
    _registerAuthenticationPolicy(pyramid_request.registry, team.id)

    def _remove():
        dbsession.delete(team)
        dbsession.flush()
    request.addfinalizer(_remove)


def remove_test_data(dbsession):
    for cls in [Challenge, Team, Submission, News, MassMail]:
        rows_deleted = dbsession.query(cls).delete()
        log.debug("Deleted %d rows of testing data from class %s"
                  % (rows_deleted, cls.__name__))


def install_test_data(dbsession):
    install_test_challenges(dbsession)
    dbsession.flush()
    dbsession.commit()


def install_test_challenges(dbsession):
    c = Challenge(title='offline,manual',
                  text='offline,manual:Text',
                  solution='test1',
                  manual=True)
    dbsession.add(c)

    c = Challenge(title='offline,auto',
                  text='offline,auto:Text',
                  solution='test2',
                  points=101)
    dbsession.add(c)

    c = Challenge(title='online,manual',
                  text='online,manual:Text',
                  solution='test3',
                  published=True,
                  manual=True)
    dbsession.add(c)

    c = Challenge(title='online,auto',
                  text='online,auto:Text',
                  solution='test4',
                  points=103,
                  published=True)
    dbsession.add(c)