# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from pyramid.security import Allow
from sqlalchemy import event
from sqlalchemy.ext.declarative.api import declarative_base
from sqlalchemy.orm.scoping import scoped_session
from sqlalchemy.orm.session import sessionmaker
from zope.sqlalchemy import ZopeTransactionExtension  # @UnresolvedImport


DBSession = scoped_session(sessionmaker())
"""Database session factory. Returns the current threadlocal session."""

Base = declarative_base()
"""Base class for all ORM classes."""


# Set the database session events
ext = ZopeTransactionExtension()
for ev in ["after_begin", "after_attach", "after_flush",
           "after_bulk_update", "after_bulk_delete", "before_commit"]:
    func = getattr(ext, ev)
    event.listen(DBSession, ev, func)


class RootFactory(object):
    """Skeleton for simple ACL permission protection."""
    __acl__ = [(Allow, 'group:team', 'view'),
               ]

    def __init__(self, request):
        pass


from fluxscoreboard.models.challenge import Challenge, Submission
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team
