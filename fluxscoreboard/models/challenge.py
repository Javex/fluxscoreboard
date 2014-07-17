# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime
from fluxscoreboard.util import now
from sqlalchemy import event
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
    return DBSession.query(Challenge)


def get_online_challenges():
    """
    Return a query that gets only those challenges that are online.
    """
    return (DBSession.query(Challenge).
            filter(Challenge.online))


def get_unsolved_challenges(team_id):
    """
    Return a query that produces a list of all unsolved challenges for a given
    team.
    """
    from fluxscoreboard.models.team import get_team_solved_subquery
    team_solved_subquery = get_team_solved_subquery(team_id)
    online = get_online_challenges()
    return (online.filter(not_(team_solved_subquery.exists())))


def get_solvable_challenges(team_id):
    """
    Return a list of challenges that the current team can solve right now. It
    returns a list of challenges that are

    - online
    - unsolved by the current team
    - not manual (i.e. solvable by entering a solution)
    """
    unsolved = get_unsolved_challenges(team_id)
    return (unsolved.
            filter(~Challenge.manual).
            filter(~Challenge.dynamic).
            filter(Challenge.published))


def get_submissions():
    """
    Creates a query to **eagerly** load all submissions. That is, all teams
    and challenges that are attached to the submissions are fetched with them.
    """
    return (DBSession.query(Submission).
            options(joinedload('challenge')).
            options(joinedload('team')))


def get_all_categories():
    """Get a list of all available categories."""
    return DBSession.query(Category)


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
    # Perform all checks that filter out invalid submissions
    if settings.submission_disabled:
        return False, "Submission is currently disabled"

    if not challenge.online:
        return False, "Challenge is offline."

    if not settings.archive_mode and now() > settings.ctf_end_date:
        return False, "The CTF is over, no more solutions can be submitted."

    if challenge.manual:
        return False, "Credits for this challenge will be given manually."

    if challenge.dynamic:
        return False, "The challenge is dynamic, no submission possible."

    if challenge.solution != solution:
        return False, "Solution incorrect."

    # After this, the solution is correct and we can return True
    if settings.archive_mode:
        return True, ("Congratulations: That was the correct solution! "
                      "However, since the scoreboard is in archive mode, you "
                      "will not be awarded any points.")

    query = (DBSession.query(Submission.team_id).
             filter(Submission.challenge_id == challenge.id))
    submissions = [id_ for id_, in query]

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
    submission.challenge = challenge
    DBSession.add(submission)
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

        ``online``: Whether the challenge is online.

        ``manual``: If the points for this challenge are awareded manually.

        ``category_id``: ID of the associated category.

        ``category``: Direct access to the :class:`Category`.

        ``author``: A simple string that contains an author (or a list
        thereof).

        ``dynamic``: Whether this challenge is dynamically handled. At the
        default of ``False`` this is just a normal challenge, otherwise, the
        attribute ``module`` must be set.

        ``module_name``: If this challenge is dynamic, it must provide a valid
        dotted python name for a module that provides the interface for
        validation and display. The dotted python name given here will be
        prefixed with ``fluxscoreboard.dynamic_challenges.``

        ``module``: Loads the module from the module name and returns it.

        ``published``: Whether the challenge should be displayed in the
        frontend at all.
    """
    id = Column(Integer, primary_key=True)
    title = Column(Unicode(255), nullable=False)
    text = Column(UnicodeText)
    solution = Column(Unicode(255))
    _points = Column('points', Integer, default=0)
    online = Column(Boolean, default=False, nullable=False)
    manual = Column(Boolean, default=False, nullable=False)
    category_id = Column(Integer, ForeignKey('category.id'))
    author = Column(Unicode(255))
    dynamic = Column(Boolean, default=False, nullable=False)
    module_name = Column(Unicode(255))
    published = Column(Boolean, default=False, nullable=False)

    category = relationship("Category", backref="challenges", lazy="joined")

    def __init__(self, *args, **kwargs):
        if kwargs.get("manual", False) and kwargs.get("points", 0):
            raise ValueError("A manual challenge cannot have points!")
        Base.__init__(self, *args, **kwargs)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.title

    def __repr__(self):
        if self.manual:
            annotation = "manual"
        elif self.dynamic:
            annotation = "dynamic"
        else:
            annotation = "normal"
        additional_info = []
        if self.category:
            additional_info.append("category=%s" % self.category)
        if self.author:
            additional_info.append("author(s)=%s" % self.author)
        if self.module_name:
            additional_info.append("module=%s" % self.module_name)
        if additional_info:
            additional_info = ", " + ", ".join(additional_info)
        else:
            additional_info = ""
        r = ("<Challenge (%s) title=%s, online=%s%s>"
             % (annotation, self.title, self.online, additional_info))
        return r.encode("utf-8")

    @property
    def points(self):
        """
        The points of a challenge which is either the value assigned to it or,
        if the challenge is manual, the :data:`manual_challenge_points`
        object to indicate that the points are manually assigned.
        """
        if self.dynamic:
            raise ValueError("This is a dynamic challenge, its points are "
                             "fetched by calling "
                             "challenge.module.points(team).")
        if self.manual:
            return manual_challenge_points
        else:
            return self._points

    @points.setter
    def points(self, points):
        self._points = points

    @property
    def module(self):
        from . import dynamic_challenges
        return dynamic_challenges.registry.get(self.module_name, None)


@event.listens_for(Challenge, 'before_update')
@event.listens_for(Challenge, 'before_insert')
def assert_not_manual_and_dynamic(mapper, connection, target):
    """
    Makes sure a dynamic challenge is not at the same time manual via an
    event. This should be catched beforehand and reported to the user, this
    is only a safety net.
    """
    challenge = target
    if challenge.manual and challenge.dynamic:
        raise ValueError("Cannot have a manual dynamic challenge!")


class Category(Base):
    """
    A category for challenges.

    Attributes:
        ``id``: Primary key of category.

        ``name``: Name of the category.

        ``challenges``: List of challenges in that category.
    """
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(255), nullable=False)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name

    def __repr__(self):
        r = ("<Category id=%s, name=%s, challenges=%d>"
             % (self.id, self.name, len(self.challenges)))
        return r.encode("utf-8")


class Submission(Base):
    """
    A single submission. Each entry means that this team has solved the
    corresponding challenge, i.e. there is no ``solved`` flag: The existence
    of the entry states that.

    Attributes:
        ``team_id``: Foreign primary key column of the team.

        ``challenge_id``: Foreign primary key column of the challenge.

        ``timestamp``: A UTC-aware :class:`datetime.datetime` object. When
        assigning a value always pass either a timezone-aware object or a
        naive UTC datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``bonus``: How many bonus points were awared.

        ``team``: Direct access to the team who solved this challenge.

        ``challenge``: Direct access to the challenge.
    """
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
        Base.__init__(self, *args, **kwargs)

    def __repr__(self):
        r = ("<Submission challenge=%s, team=%s, bonus=%d, timestamp=%s>"
             % (self.challenge, self.team, self.bonus, self.timestamp))
        return r.encode("utf-8")

    @property
    def points(self):
        # TODO: remove
        return self.challenge.points + self.bonus
