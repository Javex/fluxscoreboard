# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from sqlalchemy.orm import relationship
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.types import Integer, Unicode, Enum, Boolean, DateTime, \
    UnicodeText


def get_all_challenges():
    return DBSession().query(Challenge).all()


def get_online_challenges():
    return (DBSession().query(Challenge).
            filter(Challenge.published == True).all())


class ManualChallengePoints(int):

    def __str__(self):
        return unicode(self).encode('utf-8')

    def __unicode__(self):
        return "evaluated"


manual_challenge_points = ManualChallengePoints()
"""A static value that is returned instead of an actual number of points."""


class Challenge(Base):
    __tablename__ = 'challenge'
    id = Column(Integer, primary_key=True)
    title = Column(Unicode(255))
    text = Column(UnicodeText)
    solution = Column(Unicode(255))
    _points = Column('points', Integer)
    published = Column(Boolean, default=False)
    manual = Column(Boolean, default=False)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.title

    @property
    def points(self):
        if self.manual:
            return manual_challenge_points
        else:
            return self._points


class Submission(Base):
    __tablename__ = 'submission'
    team_id = Column(Integer, ForeignKey('team.id'), primary_key=True)
    challenge_id = Column(Integer, ForeignKey('challenge.id'),
                          primary_key=True)
    timestamp = Column(DateTime, nullable=False)
    bonus = Column(Integer, default=0, nullable=False)

    team = relationship("Team")
    challenge = relationship("Challenge")

    def __init__(self, *args, **kwargs):
        if "timestamp" not in kwargs:
            self.timestamp = datetime.utcnow()

    @property
    def points(self):
        return self.challenge.points + self.bonus
