# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, Unicode, UnicodeText


def get_all_countries():
    """
    Get a query that fetches a list of all countries from the database.
    """
    # TODO: Make query instead of list
    return DBSession().query(Country).all()


class Country(Base):
    """
    A country in the database. Basically only a name for different locations
    of teams.
    """
    __tablename__ = 'country'
    id = Column(Integer, primary_key=True)
    name = Column(UnicodeText)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name
