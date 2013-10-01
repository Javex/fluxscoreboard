# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import init_routes, main
from fluxscoreboard.install import create_country_list
from fluxscoreboard.models import DBSession, Base
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.settings import Settings
from paste.deploy.loadwsgi import appconfig  # @UnresolvedImport
from pyramid import testing
from pyramid.paster import setup_logging
from pyramid.tests.test_security import _registerAuthenticationPolicy
from pyramid_mailer import get_mailer
from webob.multidict import MultiDict
from webtest.app import TestApp
import logging
import os
import pytest
import transaction
ROOT_PATH = os.path.dirname(__file__)
CONF = os.path.join(ROOT_PATH, 'pytest.ini')
setup_logging(CONF + '#loggers')
log = logging.getLogger(__name__)


@pytest.fixture(scope="session")
def testapp(settings):
    return TestApp(main(None, **settings))


@pytest.fixture(scope="session")
def database(request, testapp):
    dbsession = DBSession()
    Base.metadata.create_all(bind=dbsession.connection())
    if not dbsession.query(Settings).all():
        dbsession.add(Settings())

    def _drop():
        Base.metadata.drop_all(bind=dbsession.connection())
    request.addfinalizer(_drop)


@pytest.fixture
def dbsession(request, database):
    sess = DBSession()
    t = transaction.begin()

    def _rollback():
        t.abort()
    request.addfinalizer(_rollback)
    return sess


@pytest.fixture(scope="session", autouse=True)
def _countries(request, database):
    ret = create_country_list(DBSession())
    transaction.commit()

    def _remove():
        DBSession().query(Country).delete()
        transaction.commit()
    request.addfinalizer(_remove)
    return ret


@pytest.fixture
def countries(_countries, dbsession):
    if _countries:
        dbsession.add_all(_countries)
        return _countries
    else:
        return dbsession.query(Country).all()


@pytest.fixture
def config(settings, pyramid_request, request):
    cfg = testing.setUp(request=pyramid_request, settings=settings)
    init_routes(cfg)
    cfg.scan('fluxscoreboard.views')

    def teardown():
        testing.tearDown()
    request.addfinalizer(teardown)
    return cfg


@pytest.fixture
def pyramid_request():
    r = testing.DummyRequest(params=MultiDict())
    r.client_addr = None
    return r


@pytest.fixture(scope="session")
def settings():
    return appconfig('config:' + CONF)


@pytest.fixture
def mailer(pyramid_request, config):
    config.include("pyramid_mailer.testing")
    return get_mailer(pyramid_request)


@pytest.fixture
def login_team(pyramid_request):

    def _login(team_id):
        _registerAuthenticationPolicy(pyramid_request.registry, team_id)
    return _login
