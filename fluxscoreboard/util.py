# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from functools import wraps
import bcrypt
import random
import string
from pyramid.security import authenticated_userid
from pyramid.httpexceptions import HTTPFound
from pyramid.events import NewResponse, subscriber


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
    logged in. They will be redirected to the frontpage.

    Usage:
        .. code-block:: python

            @view_config(...)
            @not_logged_in
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
