# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import main
from fluxscoreboard.install import create_country_list
from fluxscoreboard.models import DBSession, Base
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.settings import Settings
from paste.deploy.loadwsgi import appconfig  # @UnresolvedImport
from pyramid.paster import setup_logging
from webtest.app import TestApp
import logging
import os
import pytest
import transaction
ROOT_PATH = os.path.dirname(__file__)
CONF = os.path.join(ROOT_PATH, 'pytest.ini')
settings = appconfig('config:' + CONF)
testapp = TestApp(main(None, **settings))
setup_logging(CONF + '#loggers')
log = logging.getLogger(__name__)


@pytest.fixture(scope="session")
def database(request):
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
def countries(request, database):
    create_country_list(DBSession())
    transaction.commit()

    def _remove():
        DBSession().query(Country).delete()
        transaction.commit()
    request.addfinalizer(_remove)
