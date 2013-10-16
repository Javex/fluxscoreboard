# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import settings
from functools import wraps
from pyramid.events import NewResponse, subscriber
from pyramid.httpexceptions import HTTPFound
from pyramid.security import authenticated_userid
from pytz import utc
import bcrypt
import binascii
import os
import random
import string


def display_design(request):
    """
    A function that returns ``True`` or ``False`` depending on whether the
    actual design should be displayed (``True``) or just a default one
    (``False``).

    This is used to not disclose the real design until the CTF has started.
    The following logic is implemented:

    - The admin backend has the default design (i.e. ``False``).
    - If it is a test-login from the backend, show the design.
    - If the CTF has started, the real design is loaded for the frontpage
      (i.e. ``True``).
    - If no route is matched or a public route is matched, the default design
      is loaded (``False``).
    - Otherwise the real design is loaded (``True``).

    The conditions are processed in order, i.e. the first match is returned.
    """
    # If the admin backend is loaded, display the default design.
    if request.path.startswith('/admin'):
        return False

    # If the login is a test-login, then show the design anyway
    if request.session.get("test-login", False):
        return True

    # If the CTF has started, display the real design.
    if settings.get().ctf_started:
        return True

    # If no route was matched, it's 404 and that is public, too.
    if not request.matched_route:
        return False

    # If the view is something that is public and we did not launch yet
    # we display the default one. This is a list of routes that is public.
    if request.matched_route.name in ['login', 'register',
                                      'reset-password-start', 'reset-password',
                                      'confirm']:
        return False
    else:
        return True


def now():
    """
    Return the current timestamp localized to UTC.
    """
    return utc.localize(datetime.utcnow())


def encrypt_pw(pw, salt=None):
    """
    Encrypt a password (or any string) using bcrypt.

    Generate a salt and hash the given password with it. This string can then
    be stored in the database. Every time a user logs in, it has to be
    regenerated with the same salt.

    Function is deterministic if passing the same salt but random if
    no salt is passed (checking vs. generation)

    Args:
        ``pw``: A string with the password that should be encrypted.

        ``salt``: The salt used for hashing. This is only required if checking
        a password for validity, but not if encrypting a new one. A new
        password will have a fresh seed.

        .. warning::
            If passing in an arbitrary hash for a password that is new (not
            only used for a check) then no salt should be passed.

    Returns:
        The hashed password, complete with the generated (or passed) salt.
    """
    assert isinstance(pw, unicode)
    if salt is None:
        salt = bcrypt.gensalt()
    return unicode(bcrypt.hashpw(pw, salt))


def bcrypt_split(value):
    """
    Split up a bcrypt password into the salt and password part to be used
    with :func:`encrypt_pw`. Returns a tuple of ``(salt, pw)``.
    """
    return value[:29], value[29:]


def random_token(length=64):
    """
    Generate a random token hex-string of ``length`` characters. Due to it
    being encoded hex, its entropy is only half, so if you require a 256 bit
    entropy string, passing in ``64`` as length will yield exactly
    ``64 / 2 * 8 = 256`` bits entropy.
    """
    return binascii.hexlify(os.urandom(length / 2)).decode("ascii")


def nl2br(text):
    """
    Translate newlines into HTML ``<br />`` tags.

    Usage:
        .. code-block:: mako

            <% from fluxscoreboard.util import nl2br %>
            ${some_string | nl2br}
    """
    text = unicode(text)
    text = text.replace("\r\n", "\n")
    text = text.replace("\n", "<br />")
    return text


def random_str(len_, choice=string.ascii_letters):
    return "".join(random.choice(choice) for __ in xrange(len_))


def tz_str(timestamp, timezone):
    """
    Create a localized timestring in a local ``timezone`` from the
    timezone-aware :class:`datetime.datetime` object ``timestamp``.
    """
    return timestamp.astimezone(timezone).strftime('%Y-%m-%d %H:%M:%S')


class not_logged_in(object):
    """
    Decorator for a view that should only be visible to users that are not
    logged in. They will be redirected to the frontpage and a message will be
    shown, that can be specified, but also has a sensible default.

    Usage:
        .. code-block:: python

            @view_config(...)
            @not_logged_in()
            def some_view(request):
                pass
    """

    def __init__(self, msg=None):
        if msg is None:
            msg = ("This action does not make sense if you are already logged "
                   "in!")
        self.msg = msg

    def __call__(self, func):
        @wraps(func)
        def _redirect_if_logged_in(self_wrap, *args, **kwargs):
            if authenticated_userid(self_wrap.request):
                self_wrap.request.session.flash(self.msg)
                return HTTPFound(location=self_wrap.request.route_url('home'))
            return func(self_wrap, *args, **kwargs)
        return _redirect_if_logged_in


@subscriber(NewResponse)
def add_header_x_frame_options(event):
    """
    Subscribe to the :class:`pyramid.events.NewResponse` event and add the
    ``X-Frame-Options: DENY`` header.
    """
    if "X-Frame-Options" not in event.response.headers:
        event.response.headers[b"X-Frame-Options"] = b"DENY"


@subscriber(NewResponse)
def add_header_csp(event):
    """
    Subscribe to the :class:`pyramid.events.NewResponse` event and add the
    ``Content-Security-Policy`` header. The value of that header depends on
    the setting ``csp_headers`` from the application configuration.
    """
    settings = event.request.registry.settings
    # Add CSP header
    csp = settings.get("csp_headers", "").encode("ascii")
    if csp:
        event.response.headers[b"Content-Security-Policy"] = csp


@subscriber(NewResponse)
def add_header_x_xss_protection(event):
    """Add the ``X-XSS-Protection: 0`` header."""
    if "X-XSS-Protection" not in event.response.headers:
        event.response.headers[b"X-XSS-Protection"] = b"0"


@subscriber(NewResponse)
def add_header_hsts(event):
    """
    Add the ``Strict-Transport-Security`` header. Its ``max-age`` setting is
    controlled by the configuration file setting ``hsts.max-age`` which
    defaults to one year (``31536000``)
    """
    settings = event.request.registry.settings
    max_age = settings.get('max-age', b"31536000")
    if "Strict-Transport-Security" not in event.response.headers:
        header_value = b"max-age=%s" % max_age
        event.response.headers[b"Strict-Transport-Security"] = header_value
