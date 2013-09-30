# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.install import create_country_list
from fluxscoreboard.models import DBSession, Base
from fluxscoreboard.models.country import Country
from pyramid import testing
from webob.multidict import MultiDict
import logging
import pytest
import transaction


log = logging.getLogger(__name__)


@pytest.fixture
def dbsession(request):
    sess = DBSession()
    t = transaction.begin()

    def _rollback():
        t.abort()
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


@pytest.fixture(scope="function")
def countries(request):
    log.debug("Creating country list...")
    create_country_list(DBSession())
    log.debug("Country list created...")

    def _remove():
        log.debug("Removing country list...")
        DBSession().query(Country).delete()
        log.debug("Country list remove...")
    request.addfinalizer(_remove)
