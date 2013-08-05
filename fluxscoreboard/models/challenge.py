# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from pyramid.security import authenticated_userid
from pyramid.threadlocal import get_current_request
from pytz import utc
from sqlalchemy.orm import relationship, backref
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.sql.expression import not_
from sqlalchemy.types import Integer, Unicode, Boolean, DateTime, UnicodeText


bonus_map = {0: (3, 'first'),
             1: (2, 'second'),
             2: (1, 'third'),
             }


def get_all_challenges():
    return DBSession().query(Challenge)


def get_online_challenges():
    return (DBSession().query(Challenge).
            filter(Challenge.published == True))


def get_unsolved_challenges():
    """Return a list of all unsolved challenges for a given team."""
    from fluxscoreboard.models.team import get_team_solved_subquery
    request = get_current_request()
    team_id = authenticated_userid(request)
    dbsession = DBSession()
    team_solved_subquery = get_team_solved_subquery(dbsession, team_id)
    online = get_online_challenges()
    return (online.filter(not_(team_solved_subquery.exists())))


def get_solvable_challenges():
    """
    Return a list of challenges that the current team can solve right now. It
    returns a list of challenges that are
    - online
    - unsolved by the current team
    - not manual (i.e. solvable by entering a solution)
    """
    unsolved = get_unsolved_challenges()
    return unsolved.filter(Challenge.manual == False)


def check_submission(challenge, solution, team_id):
    dbsession = DBSession()

    # TODO: Check if submission is disabled

    if not challenge.published:
        return False, "Challenge is offline."

    if challenge.solution != solution:
        return False, "Solution incorrect."

    if challenge.manual:
        return False, "Credits for this challenge will be given manually."

    submissions = (dbsession.query(Submission.team_id).
                   filter(Submission.challenge_id == challenge.id).
                   all())

    if team_id in submissions:
        return False, "Already solved."

    solved_count = len(submissions)
    bonus, place_msg = bonus_map.get(solved_count, (0, None))
    if place_msg is not None:
        msg = 'Congratulations: You solved this challenge as %s!' % place_msg
    else:
        msg = 'Congratulations: That was the correct solution!'

    submission = Submission(bonus=bonus)
    submission.team_id = team_id
    submission.challenge_id = challenge.id
    dbsession.add(submission)
    return True, msg


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

    @points.setter
    def points(self, points):
        self._points = points


class Submission(Base):
    __tablename__ = 'submission'
    team_id = Column(Integer, ForeignKey('team.id'), primary_key=True)
    challenge_id = Column(Integer, ForeignKey('challenge.id'),
                          primary_key=True)
    _timestamp = Column('timestamp', DateTime,
                        nullable=False,
                        default=datetime.utcnow
                        )
    bonus = Column(Integer, default=0, nullable=False)

    team = relationship("Team",
                             backref=backref("submissions",
                                             cascade="all, delete-orphan")
                             )
    challenge = relationship("Challenge",
                             backref=backref("submissions",
                                             cascade="all, delete-orphan")
                             )

    def __init__(self, *args, **kwargs):
        if "timestamp" not in kwargs:
            self.timestamp = datetime.utcnow()

    @property
    def points(self):
        return self.challenge.points + self.bonus

    @property
    def timestamp(self):
        return utc.localize(self._timestamp)

    @timestamp.setter
    def timestamp(self, dt):
        if dt.tzinfo is None:
            dt = utc.localize(dt)
        self._timestamp = dt.astimezone(utc)
