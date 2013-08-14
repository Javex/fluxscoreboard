# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime
from pyramid.security import authenticated_userid
from pyramid.threadlocal import get_current_request
from sqlalchemy.orm import relationship, backref, joinedload
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.sql.expression import not_
from sqlalchemy.types import Integer, Unicode, Boolean, UnicodeText


bonus_map = {0: (3, 'first'),
             1: (2, 'second'),
             2: (1, 'third'),
             }
"""
Maps an index of previous solved count to bonus points and a ranking string.
"""


def get_all_challenges():
    """
    Return a query that gets **all** challenges.
    """
    return DBSession().query(Challenge)


def get_online_challenges():
    """
    Return a query that gets only those challenges that are online.
    """
    return (DBSession().query(Challenge).
            filter(Challenge.published == True))


def get_unsolved_challenges():
    """
    Return a query that produces a list of all unsolved challenges for a given
    team.
    """
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


def get_submissions():
    """
    Creates a query to **eagerly** load all submissions. That is, all teams
    and challenges that are attached to the submissions are fetched with them.
    """
    return (DBSession().query(Submission).
            options(joinedload('challenge')).
            options(joinedload('team')))


def get_all_categories():
    return DBSession().query(Category)


def check_submission(challenge, solution, team_id, settings):
    """
    Check a solution for a challenge submitted by a team and add it to the
    database if it was correct.

    Args:
        ``challenge``: An instance of :class:`Challenge`, the challenge to
        check the solution for.

        ``solution``: A string, the proposed solution for the challenge.

        ``team_id``: An integer, the team's id which submitted the solution.

    Returns:
        A tuple of ``(result, msg)``. ``result`` indicates whether the solution
        was accpeted (and added to the database) or not. The message returns
        a string with either a result (if ``result == False``) or a
        congratulations message.
    """
    dbsession = DBSession()

    if settings["submission_disabled"]:
        return False, "Submission is currently disabled"

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
    """See :data:`manual_challenge_points`."""

    def __str__(self):
        return unicode(self).encode('utf-8')

    def __unicode__(self):
        return "evaluated"

    def __repr__(self):
        return "<ManualChallengePoints instance>"


manual_challenge_points = ManualChallengePoints()
"""A static value that is returned instead of an actual number of points."""


class Challenge(Base):
    """
    A challenge in the system.

    Attributes:
        ``id``: The primary key column.

        ``title``: Title of the challenge.

        ``text``: A description of the challenge.

        ``solution``: The challenge's solution

        ``points``: How many points the challenge is worth.

        ``published``: Whether the challenge is online.

        ``manual``: If the points for this challenge are awareded manually.
    """
    # TODO: change ``published`` to ``online``.
    __tablename__ = 'challenge'
    id = Column(Integer, primary_key=True)
    title = Column(Unicode(255))
    text = Column(UnicodeText)
    solution = Column(Unicode(255))
    _points = Column('points', Integer, default=0)
    published = Column(Boolean, default=False)
    manual = Column(Boolean, default=False)
    category_id = Column(Integer, ForeignKey('category.id'))

    category = relationship("Category", backref="challenges", lazy="joined")

    def __init__(self, *args, **kwargs):
        if kwargs.get("manual", False) and kwargs.get("points", 0):
            raise ValueError("A manual challenge cannot have points!")
        Base.__init__(self, *args, **kwargs)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.title

    @property
    def points(self):
        """
        The points of a challenge which is either the value assigned to it or,
        if the challenge is manual, the :data:`manual_challenge_points`
        object to indicate that the points are manually assigned.
        """
        if self.manual:
            return manual_challenge_points
        else:
            return self._points

    @points.setter
    def points(self, points):
        self._points = points


class Category(Base):
    """
    A category for challenges.

    Attributes:
        ``id``: Primary key of category.

        ``name``: Name of the category.

        ``challenges``: List of challenges in that category.
    """
    __tablename__ = 'category'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(255))

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name


class Submission(Base):
    """
    A single submission. Each entry means that this team has solved the
    corresponding challenge, i.e. there is no ``solved`` flag: The existence
    of the entry states that.

    Attributes:
        ``team_id``: Foreign primary key column of the team.

        ``challenge_id``: Foreign primary key column of the challenge.

        ``timestamp``: A UTC-aware :class:`datetime.datetime` object. If
        setting always only pass either a timezone-aware object or a naive UTC
        datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``bonus``: How many bonus points were awared.

        ``team``: Direct access to the team who solved this challenge.

        ``challenge``: Direct access to the challenge.
    """
    __tablename__ = 'submission'
    team_id = Column(Integer, ForeignKey('team.id'), primary_key=True)
    challenge_id = Column(Integer, ForeignKey('challenge.id'),
                          primary_key=True)
    timestamp = Column(TZDateTime,
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
        # TODO: remove
        return self.challenge.points + self.bonus
