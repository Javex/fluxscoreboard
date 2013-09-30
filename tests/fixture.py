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
