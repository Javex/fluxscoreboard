# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.team import groupfinder
from pyramid import testing
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid_beaker import session_factory_from_settings
from webob.multidict import MultiDict
import logging
import pytest
import transaction


log = logging.getLogger(__name__)


@pytest.fixture(scope="function")
def dbsession(request):
    sess = DBSession()
    log.info("Creating savepoint for session %r" % dbsession)
    # savepoint = transaction.savepoint()
    sp = sess.begin_nested()

    def _rollback():
        log.info("Rolling back session %r" % dbsession)
        # savepoint.rollback()
        sp.rollback()
    request.addfinalizer(_rollback)
    return sess


@pytest.fixture
def pyramid_request(settings, request):
    r = testing.DummyRequest(params=MultiDict())
    r.client_addr = None
    config = testing.setUp(request=r, settings=settings)

    def teardown():
        testing.tearDown()
    request.addfinalizer(teardown)
    return r


@pytest.fixture
def settings():
    from conftest import settings as s
    return s
