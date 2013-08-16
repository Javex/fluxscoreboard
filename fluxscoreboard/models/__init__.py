# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from pyramid.security import Allow
from sqlalchemy import event
from sqlalchemy.ext.declarative.api import declarative_base, declared_attr
from sqlalchemy.orm.scoping import scoped_session
from sqlalchemy.orm.session import sessionmaker
from zope.sqlalchemy import ZopeTransactionExtension  # @UnresolvedImport


DBSession = scoped_session(sessionmaker())
"""Database session factory. Returns the current threadlocal session."""


class Base(object):

    @declared_attr
    def __tablename__(cls):  # @NoSelf
        return cls.__name__.lower()

    __table_args__ = {'mysql_engine': 'InnoDB',
                      'mysql_charset': 'utf8'}

Base = declarative_base(cls=Base)
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


from fluxscoreboard.models.challenge import Challenge, Submission, Category
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team
