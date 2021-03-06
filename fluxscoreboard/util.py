# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from functools import wraps
from pyramid.events import NewResponse, subscriber
from pyramid.httpexceptions import HTTPFound
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
    - If no route is matched, the default design is loaded (``False``).
    - Otherwise we fall back to not show the design (``False``).

    The conditions are processed in order, i.e. the first match is returned.
    """
    # If the admin backend is loaded, display the default design.
    if is_admin_path(request):
        return False

    # If the login is a test-login, then show the design anyway
    if request.session.get("test-login", False):
        return True

    # If the CTF has started, display the real design.
    if request.settings.ctf_started or request.settings.ctf_ended:
        return True

    # If no route was matched, it's 404 and that is public, too.
    if not request.matched_route:
        return False

    # Safe fallback: No reason to display the real design
    return False


def is_admin_path(request):
    settings = request.registry.settings
    subdir = settings.get("subdirectory", "")
    admin_path = "/admin"
    if subdir:
        subdir = "/" + subdir
        if not request.path.startswith(subdir):
            raise ValueError("Invalid route: subdirectory setting set to %s "
                             "but path does not start with it: %s" %
                             (subdir, request.path))
        admin_path = subdir + admin_path
    return request.path.startswith(admin_path)


def now():
    """
    Return the current timestamp localized to UTC.
    """
    return utc.localize(datetime.utcnow())


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


def tz_str(timestamp, timezone=None):
    """
    Create a localized timestring in a local ``timezone`` from the
    timezone-aware :class:`datetime.datetime` object ``timestamp``.
    """
    if timezone is None:
        timezone = utc
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
            if self_wrap.request.authenticated_userid:
                self_wrap.request.session.flash(self.msg)
                return HTTPFound(location=self_wrap.request.route_url('home'))
            return func(self_wrap, *args, **kwargs)
        return _redirect_if_logged_in
