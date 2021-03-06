# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, UnicodeText


def get_all_countries():
    """
    Get a query that fetches a list of all countries from the database.
    """
    return DBSession.query(Country)


class Country(Base):
    """
    A country in the database. Basically only a name for different locations
    of teams.
    """
    id = Column(Integer, primary_key=True)
    name = Column(UnicodeText)

    def __unicode__(self):
        return self.name
