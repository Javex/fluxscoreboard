# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime, Module
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.util import now
from sqlalchemy import event, func, select, exists
from sqlalchemy.orm import relationship, backref, joinedload
from sqlalchemy.schema import Column, ForeignKey, FetchedValue
from sqlalchemy.types import Integer, Unicode, Boolean, UnicodeText, Numeric
from sqlalchemy.sql.expression import cast, case


first_blood_map = {0: (3, 'first'),
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

    if not settings.archive_mode and now() > settings.ctf_end_date:
        return False, "The CTF is over, no more solutions can be submitted."

    if not challenge.online:
        return False, "Challenge is offline."

    if challenge.manual:
        return False, "Credits for this challenge will be given manually."

    if challenge.dynamic:
        return False, "The challenge is dynamic, no submission possible."

    # help faggots
    solution = solution.strip()
    if solution.startswith('flag{'):
        solution = solution[5:-1]

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
    first_blood_pts, place_msg = first_blood_map.get(solved_count, (0, None))
    if place_msg is not None:
        msg = 'Congratulations: You solved this challenge as %s!' % place_msg
    else:
        msg = 'Congratulations: That was the correct solution!'

    submission = Submission(additional_pts=first_blood_pts)
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

        ``module``: If this challenge is dynamic, it must provide a valid
        dotted python name for a module that provides the interface for
        validation and display. The dotted python name given here will be
        prefixed with ``fluxscoreboard.dynamic_challenges.`` from which the
        module will be loaded and made available on using it.

        ``module``: Loads the module from the module name and returns it.

        ``published``: Whether the challenge should be displayed in the
        frontend at all.
    """
    id = Column(Integer, primary_key=True)
    title = Column(Unicode, nullable=False)
    text = Column(UnicodeText)
    solution = Column(Unicode)
    base_points = Column(Integer, nullable=True)
    online = Column(Boolean, default=False, nullable=False)
    manual = Column(Boolean, default=False, nullable=False)
    category_id = Column(Integer, ForeignKey('category.id'))
    author = Column(Unicode)
    dynamic = Column(Boolean, default=False, nullable=False)
    module = Column(Module)
    published = Column(Boolean, default=False, nullable=False)
    has_token = Column(Boolean, default=False, nullable=False)
    _points = Column('points', Integer, FetchedValue(), server_default='0',
                     nullable=False)

    category = relationship("Category", backref="challenges")

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
        if self.module:
            from .dynamic_challenges import registry
            for name, v in registry.items():
                if v == self.module:
                    break
            additional_info.append("module=%s" % name)
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


@event.listens_for(Challenge, 'before_insert')
@event.listens_for(Challenge, 'before_update')
def validate_base_points(mapper, connection, challenge):
    if (not challenge.manual and not challenge.dynamic and
            not challenge.base_points):
        raise ValueError("Challenge must have base points.")
    if challenge.manual and challenge.base_points:
        raise ValueError("Challenge cannot be manual and have points.")
    if challenge.dynamic and challenge.base_points:
        raise ValueError("Challenge cannot be dynamic and have points.")


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


@event.listens_for(Challenge._points, 'set')
def _protect_points_set(target, value, oldvalue, initiator):
    raise AttributeError("Not allowed to set points column!")


class Category(Base):
    """
    A category for challenges.

    Attributes:
        ``id``: Primary key of category.

        ``name``: Name of the category.

        ``challenges``: List of challenges in that category.
    """
    id = Column(Integer, primary_key=True)
    name = Column(Unicode, nullable=False)

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
    additional_pts = Column(Integer, default=0, nullable=False)

    team = relationship("Team",
                        backref=backref("submissions",
                                        cascade="all, delete-orphan")
                        )
    challenge = relationship("Challenge",
                             backref=backref("submissions",
                                             cascade="all, delete-orphan")
                             )

    def __repr__(self):
        r = ("<Submission challenge=%s, team=%s, additional_pts=%d, "
             "timestamp=%s>" % (self.challenge, self.team,
                                self.additional_pts, self.timestamp))
        return r.encode("utf-8")


def update_playing_teams(connection):
    """
    Update the number of playing teams whenever it changes.
    """
    from fluxscoreboard.models.team import Team
    team_playing = exists(select([1]).where(Submission.team_id == Team.id))
    source = (select([func.count('*')]).
              select_from(Team.__table__).
              where(team_playing).
              where(Team.active))
    query = Settings.__table__.update().values(playing_teams=source)
    connection.execute(query)


def update_challenge_points(connection, update_team_count=True):
    if update_team_count:
        update_playing_teams(connection)
    solved_count = (select([cast(func.count('*'), Numeric)]).
                    select_from(Submission.__table__).
                    where(Challenge.id == Submission.challenge_id).
                    correlate(Challenge))
    team_count = select([Settings.playing_teams]).as_scalar()
    team_ratio = 1 - solved_count / team_count
    bonus = case([(team_count != 0, func.round(team_ratio, 1))], else_=1) * 100
    source = select([Challenge.base_points + bonus]).correlate(Challenge)
    query = (Challenge.__table__.update().
             where(~Challenge.manual).
             where(~Challenge.dynamic).
             values(points=source))
    connection.execute(query)
