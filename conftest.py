# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import main
from fluxscoreboard.models import DBSession
from paste.deploy.loadwsgi import appconfig
from pyramid.paster import setup_logging
from webtest.app import TestApp
import os


ROOT_PATH = os.path.dirname(__file__)
CONF = os.path.join(ROOT_PATH, 'pytest.ini')
settings = appconfig('config:' + CONF)
testapp = TestApp(main(None, **settings))


def pytest_sessionstart():
    from pytest import config  # @UnresolvedImport

    if not hasattr(config, 'slaveinput'):
        from fluxscoreboard import install
        setup_logging(CONF + '#loggers')
        install.install(settings)


def pytest_sessionfinish():
    from pytest import config  # @UnresolvedImport

    if not hasattr(config, 'slaveinput'):
        from fluxscoreboard.tests import remove_test_data
        remove_test_data(DBSession())
