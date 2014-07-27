# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from sqlalchemy import event
from sqlalchemy.ext.declarative.api import declarative_base, declared_attr
from sqlalchemy.orm.scoping import scoped_session
from sqlalchemy.orm.session import sessionmaker
from zope.sqlalchemy import ZopeTransactionExtension  # @UnresolvedImport


DBSession = scoped_session(sessionmaker())
"""Database session factory. Returns the current threadlocal session."""


class BaseCFG(object):
    """
    Class that contains custom configuration for a
    :func:`sqlalchemy.ext.declarative.declarative_base` to be used with the
    ORM. It automatically figures out a tablename (thus no need to set
    ``__tablename__``) and sets some custom MySQL args (for instance it
    defaults the engine to ``InnoDB`` to have transaction support).
    """

    @declared_attr
    def __tablename__(cls):  # @NoSelf
        return cls.__name__.lower()

    __table_args__ = {'mysql_engine': 'InnoDB',
                      'mysql_charset': 'utf8'}

Base = declarative_base(cls=BaseCFG)
"""Base class for all ORM classes. Uses :class:`BaseCFG` configuration."""


# Set the database session events
"""
ext = ZopeTransactionExtension()
for ev in ["after_begin", "after_attach", "after_flush",
           "after_bulk_update", "after_bulk_delete", "before_commit"]:
    func = getattr(ext, ev)
    event.listen(DBSession, ev, func)
"""
