# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard import util
from fluxscoreboard.util import (display_design, encrypt_pw, bcrypt_split,
    random_token, nl2br, random_str, tz_str, not_logged_in,
    add_header_x_frame_options, add_header_x_xss_protection, add_header_hsts,
    add_header_csp, is_admin_path)
from pytz import utc, timezone
import pytest


@pytest.fixture(params=['login', 'register', 'reset-password-start',
                        'reset-password', 'confirm'])
def public_route(request):
    return request.param


@pytest.fixture(params=[(add_header_x_frame_options, 'X-Frame-Options', True),
                        (add_header_x_xss_protection, 'X-XSS-Protection', True),
                        (add_header_hsts, 'Strict-Transport-Security', True),
                        (add_header_csp, 'Content-Security-Policy', False)])
def header(request):
    return request.param


@pytest.mark.usefixtures("database", "matched_route")
class TestDisplayDesign(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request, dbsettings):
        self.request = pyramid_request
        self.request.path = "/start"
        self.settings = pyramid_request.settings
        self.settings.ctf_start_date = utc.localize(datetime.utcnow() +
                                                    timedelta(1))

    def test_else(self):
        assert not self.request.settings.ctf_started
        assert display_design(self.request)

    def test_admin(self):
        self.request.path = "/admin/something"
        assert not display_design(self.request)

    def test_ctf_started(self):
        self.settings.ctf_start_date = datetime(2012, 1, 1, tzinfo=utc)
        assert display_design(self.request)

    def test_no_route(self):
        self.request.matched_route = None
        assert not display_design(self.request)

    def test_public_route(self, public_route):
        self.request.matched_route.name = public_route
        assert not display_design(self.request)


class Test_is_admin_path(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request, settings, request):
        self.request = pyramid_request
        self.request.registry.settings = settings
        self.settings = self.request.registry.settings
        old_subdirectory = settings.get("subdirectory")

        def _restore():
            if old_subdirectory is None:
                if "subdirectory" in settings:
                    del settings["subdirectory"]
            else:
                settings["subdirectory"] = old_subdirectory
        request.addfinalizer(_restore)

    def test_no_admin_no_subdir(self):
        assert "subdirectory" not in self.settings
        self.request.path = "/some/non/admin/path"
        assert not is_admin_path(self.request)

    def test_no_admin_subdir(self):
        self.settings["subdirectory"] = "abc"
        self.request.path = "/abc/some/non/admin/path"
        assert not is_admin_path(self.request)

        self.request.path = "/abc/no/admin"
        assert not is_admin_path(self.request)

        self.request.path = "/some/non/admin/path"
        with pytest.raises(ValueError):
            is_admin_path(self.request)

    def test_admin_no_subdir(self):
        assert "subdirectory" not in self.settings
        self.request.path = "/admin"
        assert is_admin_path(self.request)

        self.request.path = "/admin/path"
        assert is_admin_path(self.request)

    def test_admin_subdir(self):
        self.settings["subdirectory"] = "abc"
        self.request.path = "/abc/admin"
        assert is_admin_path(self.request)

        self.request.path = "/admin/path"
        with pytest.raises(ValueError):
            is_admin_path(self.request)


def test_now():
    now_before = utc.localize(datetime.utcnow())
    now_ = util.now()
    now_after = utc.localize(datetime.utcnow())
    assert now_before <= now_
    assert now_after >= now_


def test_encrypt_pw():
    enc = encrypt_pw("Test")
    assert len(enc) == 60
    assert isinstance(enc, unicode)


def test_encrypt_pw_salt():
    salt = "$2a$12$XaT7ovLVr/alrZVNDu/t/e"
    pw = encrypt_pw("Test", salt)
    assert salt in pw


def test_encrypt_pw_no_unicode():
    with pytest.raises(AssertionError):
        encrypt_pw(b"Test")


def test_bcrypt_split():
    ref = "$2a$12$.OlKHnjgnV5S03XFR14wyumeaicEB6oFaqYbOUrvJwEDkY1QImhhG"
    assert bcrypt_split(ref) == ("$2a$12$.OlKHnjgnV5S03XFR14wyu",
                                 "meaicEB6oFaqYbOUrvJwEDkY1QImhhG")


def test_random_token():
    assert len(random_token()) == 64
    assert len(random_token(32)) == 32


def test_nl2br():
    assert nl2br("abc\nabc") == "abc<br />abc"
    assert nl2br("abc\r\nabc") == "abc<br />abc"
    assert nl2br("\n") == "<br />"
    assert nl2br("\n\n\n") == "<br /><br /><br />"
    assert nl2br("\r\n\r\n\r\n") == "<br /><br /><br />"


def test_random_str():
    assert len(random_str(10)) == 10


def test_tz_str():
    dt = datetime(2012, 1, 1, tzinfo=utc)
    tz = timezone("Europe/Berlin")
    assert tz_str(dt, tz) == "2012-01-01 01:00:00"


def test_not_logged_in(pyramid_request):

    class A(object):
        pass

    def _nop(a):
        return 3
    f = not_logged_in(None)(_nop)
    a = A()
    a.request = pyramid_request
    assert f(a) == 3


@pytest.mark.usefixtures("config")
def test_not_logged_in_login(dummy_login, pyramid_request):

    class A(object):
        pass

    def _nop(a):
        pass
    dummy_login(4)
    f = not_logged_in()(_nop)
    a = A()
    a.request = pyramid_request
    ret = f(a)
    assert ret.code == 302
    q = pyramid_request.session.peek_flash()
    assert len(q) == 1
    assert q[0] == ("This action does not make sense if you are already "
                    "logged in!")


@pytest.mark.usefixtures("config")
def test_not_logged_in_msg(dummy_login, pyramid_request):

    class A(object):
        pass

    def _nop(b):
        pass
    dummy_login(5)
    q = pyramid_request.session.peek_flash()
    assert len(q) == 0
    f = not_logged_in("Testmsg")(_nop)
    a = A()
    a.request = pyramid_request
    ret = f(a)
    assert ret.code == 302
    q = pyramid_request.session.peek_flash()
    assert len(q) == 1
    assert q[0] == ("Testmsg")


@pytest.mark.usefixtures("config")
def test_header_defaults(header, pyramid_request):
    class A():
        pass

    event = A()
    event.request = pyramid_request
    event.response = A()
    event.response.headers = {}
    func, key, has_default = header
    func(event)
    if has_default:
        assert key in event.response.headers
    else:
        assert key not in event.response.headers


@pytest.mark.usefixtures("config")
def test_header_already_present(header, pyramid_request):
    class A():
        pass

    event = A()
    event.request = pyramid_request
    event.response = A()
    event.response.headers = {}
    func, key, _ = header
    inst = object()
    event.response.headers[key] = inst
    func(event)
    assert event.response.headers[key] is inst
