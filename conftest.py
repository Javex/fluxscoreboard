# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import init_routes, main
from fluxscoreboard.install import create_country_list
from fluxscoreboard.forms.front import RegisterForm
from fluxscoreboard.models import DBSession, Base, dynamic_challenges
from fluxscoreboard.models.challenge import Challenge, Category
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.news import MassMail, News
from fluxscoreboard.models.settings import (CTF_BEFORE, CTF_STARTED,
    CTF_ARCHIVE, Settings)
from fluxscoreboard.models.team import Team
from fluxscoreboard.views.front import BaseView
from fluxscoreboard.util import now
from datetime import timedelta
from paste.deploy.loadwsgi import appconfig  # @UnresolvedImport
from pyramid import testing
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.interfaces import IAuthenticationPolicy
from pyramid.paster import setup_logging
from pyramid.security import remember
from pyramid.tests.test_security import DummyAuthenticationPolicy
from pyramid_beaker import BeakerSessionFactoryConfig
from pyramid_mailer import get_mailer
from sqlalchemy.orm.session import make_transient
from webob.multidict import MultiDict
from webtest.app import TestApp
from mock import MagicMock
import Queue
import logging
import os
import pytest
import sys
import transaction
ROOT_PATH = os.path.dirname(__file__)
CONF = os.path.join(ROOT_PATH, 'cfg', 'test.ini')
setup_logging(CONF + '#loggers')
log = logging.getLogger(__name__)


@pytest.fixture(scope="session")
def testapp(settings):
    environ = {
        'REMOTE_ADDR': b'127.0.0.1'
    }
    return TestApp(main(None, **settings), environ)


@pytest.fixture(scope="session")
def database(request, testapp):
    dbsession = DBSession()
    Base.metadata.create_all(bind=dbsession.connection())
    if not dbsession.query(Settings).all():
        dbsession.add(Settings())

    def _drop():
        conn = dbsession.connection()
        Base.metadata.drop_all(bind=conn)
        # TODO: Why do we have to use this literally?
        # If fixed test against MySQL *and* Postgres!
        conn.execute("COMMIT")
    request.addfinalizer(_drop)


@pytest.fixture
def dbsession(request, database):
    sess = DBSession()
    log.debug("Using session %s" % sess)
    t = transaction.begin()

    def _rollback():
        t.abort()
    request.addfinalizer(_rollback)
    return sess


@pytest.fixture
def dbsettings(request, pyramid_request, dbsession, config):
    old_settings = dbsession.query(Settings).one()
    dbsession.delete(old_settings)
    settings = Settings()
    dbsession.add(settings)
    dbsession.flush()
    pyramid_request.settings = settings

    def _restore():
        dbsession.delete(settings)
        make_transient(old_settings)
        dbsession.add(old_settings)
        dbsession.flush()
    request.addfinalizer(_restore)
    return settings


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
    dbsession.add_all(_countries)
    return _countries


@pytest.fixture
def config(settings, pyramid_request, request):
    cfg = testing.setUp(request=pyramid_request, settings=settings)
    cfg.add_static_view('static', 'fluxscoreboard:static',
                           cache_max_age=3600)
    init_routes(cfg, settings)
    cfg.scan('fluxscoreboard.views')
    cfg.include('pyramid_mako')

    def teardown():
        testing.tearDown()
    request.addfinalizer(teardown)
    return cfg


@pytest.fixture
def session_factory():
    return BeakerSessionFactoryConfig()


@pytest.fixture
def pyramid_request(session_factory, request):
    r = testing.DummyRequest(params=MultiDict())
    r.client_addr = "127.0.0.1"
    r.session = session_factory(r)

    def clean_flash():
        r.session.pop_flash()
    request.addfinalizer(clean_flash)
    return r


@pytest.fixture
def matched_route(pyramid_request):
    class A(object):
            pass
    pyramid_request.matched_route = A()
    pyramid_request.matched_route.name = "something"


@pytest.fixture(scope="session")
def settings():
    cfg = appconfig('config:' + CONF)
    cache_dir = os.path.join(os.path.dirname(__file__), 'tests', 'template',
                             'cache')
    cfg["mako.module_directory"] = os.path.abspath(cache_dir)
    return cfg


@pytest.fixture
def mailer(pyramid_request, config):
    config.include("pyramid_mailer.testing")
    return get_mailer(pyramid_request)


@pytest.fixture
def login_team(pyramid_request):

    def _login(team_id):
        _registerAuthenticationPolicy(pyramid_request.registry)
        remember(pyramid_request, team_id)
    return _login


@pytest.fixture
def dummy_login(pyramid_request):

    def _login(val):
        _registerAuthenticationPolicy(pyramid_request.registry)
        remember(pyramid_request, val)
    return _login


@pytest.fixture
def make_team(countries):
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("name", "Team%d" % count[0])
        kwargs.setdefault("password", "Password%d" % count[0])
        kwargs.setdefault("email", "team%d@example.com" % count[0])
        kwargs.setdefault("country_id", countries[0].id)
        t = Team(**kwargs)
        t._real_password = "Password%d" % count[0]
        count[0] += 1
        return t
    return _make


@pytest.fixture
def make_challenge():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("title", "Challenge%d" % count[0])
        kwargs.setdefault("text", "ChallengeText%d" % count[0])
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


@pytest.fixture
def make_news():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("message", "Bla<br>foo")
        count[0] += 1
        return News(**kwargs)
    return _make


@pytest.fixture
def make_category():
    count = [0]

    def _make(**kwargs):
        kwargs.setdefault("name", "Category%d" % count[0])
        count[0] += 1
        return Category(**kwargs)
    return _make


@pytest.fixture
def view(pyramid_request):
    return BaseView(pyramid_request)


dummy_module = MagicMock(spec_set=['configuration', 'activate', 'render',
                                   'get_points_query', 'get_points', 'title',
                                   'install'])
dummy_module.configuration = {'allow_multiple': False}
dummy_module.activate.return_value = None
dummy_module.render.return_value = u"Foo<br>Bar"
dummy_module.get_points.return_value = 1
dummy_module.get_points_query.return_value = "1234"
dummy_module.title.return_value = "Some title"
dummy_module.install.return_value = None

@pytest.fixture(params=dynamic_challenges.registry.items() + [(u"testmodule", dummy_module)])
def dynamic_module(request):
    modname, module = request.param
    if modname == u"testmodule":
        dynamic_challenges.registry[modname] = module

        def remove():
            del dynamic_challenges.registry[modname]
        request.addfinalizer(remove)
    return modname, module


@pytest.fixture(params=[(CTF_BEFORE, True),
                        (CTF_BEFORE, False),
                        (CTF_STARTED, True),
                        (CTF_STARTED, False),
                        (CTF_ARCHIVE, False)])
def ctf_state(request, dbsettings, login_team, make_team, dbsession):
    ctf_state, login_state = request.param
    if ctf_state == CTF_BEFORE:
        dbsettings.ctf_start_date = now() + timedelta(1)
        dbsettings.ctf_end_date = now() + timedelta(2)
    elif ctf_state == CTF_STARTED:
        dbsettings.ctf_start_date = now() - timedelta(1)
        dbsettings.ctf_end_date = now() + timedelta(1)
    else:
        dbsettings.ctf_start_date = now() - timedelta(2)
        dbsettings.ctf_end_date = now() - timedelta(1)
        dbsettings.archive_mode = True

    t = make_team()
    dbsession.add(t)
    dbsession.flush()
    if login_state:
        login_team(t.id)
    return ctf_state, login_state, t


@pytest.fixture
def remove_captcha(request):
    if hasattr(RegisterForm, 'captcha'):
        old_field = RegisterForm.captcha
        RegisterForm.captcha = MagicMock()

        def readd_captcha():
            RegisterForm.captcha = old_field
        request.addfinalizer(readd_captcha)


def _registerAuthenticationPolicy(reg):
    policy = SessionAuthenticationPolicy()
    reg.registerUtility(policy, IAuthenticationPolicy)
    assert reg.queryUtility(IAuthenticationPolicy)
    return policy


def _registerDummyAuthenticationPolicy(reg):
    policy = DummyAuthenticationPolicy()
    reg.registerUtility(policy, IAuthenticationPolicy)
    assert reg.queryUtility(IAuthenticationPolicy)
    return policy


class DummyView(object):
    menu = []
