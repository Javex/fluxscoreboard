# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from pyramid.security import Allow, Everyone
from sqlalchemy import event
from sqlalchemy.ext.declarative.api import declarative_base, declared_attr
from sqlalchemy.orm.scoping import scoped_session
from sqlalchemy.orm.session import sessionmaker
from zope.sqlalchemy import register as zope_sa_register


DBSession = scoped_session(sessionmaker())
"""Database session factory. Returns the current threadlocal session."""
zope_sa_register(DBSession)


class BaseCFG(object):
    """
    Class that contains custom configuration for a
    :func:`sqlalchemy.ext.declarative.declarative_base` to be used with the
    ORM. It automatically figures out a tablename (thus no need to set
    ``__tablename__``).
    """

    @declared_attr
    def __tablename__(cls):  # @NoSelf
        return cls.__name__.lower()

    def __str__(self):
        return unicode(self).encode("utf-8")

Base = declarative_base(cls=BaseCFG)
"""Base class for all ORM classes. Uses :class:`BaseCFG` configuration."""


class RootFactory(object):
    """Skeleton for simple ACL permission protection."""

    def __init__(self, request):
        self.request = request

    def __acl__(self):
        from .settings import CTF_BEFORE, CTF_STARTED, CTF_ARCHIVE, CTF_ENDED
        permission_map = {
            CTF_BEFORE: [
                ('group:team', ['teams', 'logged_in']),
                (Everyone, ['teams', 'login', 'register']),
            ],
            CTF_STARTED: [
                ('group:team', ['scoreboard', 'challenges', 'logged_in']),
                (Everyone, ['scoreboard', 'login']),
            ],
            CTF_ENDED: [
                ('group:team', ['scoreboard', 'challenges', 'logged_in']),
                (Everyone, ['scoreboard', 'login']),
            ],
            CTF_ARCHIVE: [
                (Everyone, ['scoreboard', 'challenges']),
            ],
        }

        acl = []
        ctf_state = self.request.settings.ctf_state
        for principal, permissions in permission_map[ctf_state]:
            acl.append((Allow, principal, permissions))
        if self.request.session.get('test-login'):
            acl.append((Allow, principal, permission_map[CTF_STARTED][0][1]))
        return acl


from fluxscoreboard.models.challenge import Challenge, Submission, Category
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team, TeamIP
from fluxscoreboard.models.settings import Settings
