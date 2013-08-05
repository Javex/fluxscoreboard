# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.challenge import Submission, Challenge
from fluxscoreboard.util import bcrypt_split, encrypt_pw
from pyramid.security import authenticated_userid, unauthenticated_userid
from pytz import utc, timezone, all_timezones
from sqlalchemy.orm import relationship
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql import exists
from sqlalchemy.sql.expression import func
from sqlalchemy.types import Integer, Unicode, Boolean
import binascii
import logging
import os


log = logging.getLogger(__name__)


TEAM_NAME_MAX_LENGTH = 255
TEAM_MAIL_MAX_LENGTH = 255


TEAM_GROUPS = ['group:team']
"""Groups are just fixed: If a team is logged in it belongs to these groups."""


def groupfinder(userid, request):
    """
    Check if there is a team logged in, and if it is, return the default team
    groups.
    """
    if get_team(request):
        return TEAM_GROUPS


def get_all_teams():
    """
    Get a query that returns a list of all teams.
    """
    return DBSession().query(Team)


def get_active_teams():
    """
    Get a query that returns a list of all active teams.
    """
    return DBSession().query(Team).filter(Team.active == True)


def get_team_solved_subquery(dbsession, team_id):
    """
    Get a query that searches for a submission from a team for a given
    challenge. The challenge is supposed to come from an outer query.

    Example usage:
    .. code-block:: python
        team_solved_subquery = get_team_solved_subquery(dbsession, team_id)
        challenge_query = (dbsession.query(Challenge,
                                           team_solved_subquery.exists()))

    In this example we query for a list of all challenges and additionally
    fetch whether the currenttly logged in team has solved it.
    """
    # This subquery basically searches for whether the current team has
    # solved the corresponding challenge. The correlate statement is
    # a SQLAlchemy statement that tells it to use the **outer** challenge
    # column.
    team_solved_subquery = (dbsession.query(Submission).
                            filter(Submission.team_id == team_id).
                            filter(Challenge.id ==
                                   Submission.challenge_id).
                            correlate(Challenge))
    return team_solved_subquery


def get_number_solved_subquery():
    """
    Get a subquery that returns how many teams have solved a challenge.

    Example usage:
    .. code-block:: python
        number_of_solved_subquery = get_number_solved_subquery()
        challenge_query = (dbsession.query(Challenge,
                                           number_of_solved_subquery).
                           outerjoin(Submission).
                           group_by(Submission.challenge_id))

    Here we query for a list of all challenges and additionally fetch the
    number of times it has been solved. This subquery alone is not worth
    much, it needs to be used together with other statements as shown in the
    example.
    """
    return func.count(Submission.team_id)


def get_team(request):
    """
    Get the currently logged in team. Fetches the team from the database
    only once, then stores it in the request.
    """
    if not hasattr(request, 'team'):
        dbsession = DBSession()
        team_id = unauthenticated_userid(request)
        try:
            team = (dbsession.query(Team).
                    filter(Team.id == team_id).
                    filter(Team.active == True).one())
            request.team = team
        except NoResultFound:
            request.team = None
    return request.team


class Team(Base):
    """
    A team represented in the database.

    Attributes:
        ``id``: Primary key

        ``name``: The name of the team.

        ``password``: The password of the team. If setting the password, pass
        it as cleartext. It will automatically be encrypted and stored in the
        database.

        ``email``: E-Mail address of the team. Verified if team is ``active``.

        ``country_id``: Foreign Key specifying the location of the team.

        ``local``: Whether the team is local at the conference.

        ``token``: Token for verification.

        ``active``: Whether the team's mail address has been verified and the
        team can actively log in.

        ``timezone``: A timezone, specified as string, like ``"Europe/Berlin"``
        or something that, when coerced to unicode, turns out as a string
        like this. Must be valid timezone.

        ``country``: Direct access to the teams :class:`models.country.Country`
        attribute.
    """
    __tablename__ = 'team'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(TEAM_NAME_MAX_LENGTH), nullable=False)
    _password = Column('password', Unicode(60), nullable=False)
    email = Column(Unicode(TEAM_MAIL_MAX_LENGTH), nullable=False, unique=True)
    country_id = Column(Integer, ForeignKey('country.id'), nullable=False)
    local = Column(Boolean, default=False)
    token = Column(Unicode(64), nullable=False, unique=True)
    active = Column(Boolean, default=False)
    _timezone = Column('timezone', Unicode(30),
                       default=lambda: unicode(utc.zone),
                       nullable=False)

    country = relationship("Country", lazy='joined')

    def __init__(self, *args, **kwargs):
        if "token" not in kwargs:
            self.token = binascii.hexlify(os.urandom(32)).decode("ascii")
        Base.__init__(self, *args, **kwargs)

    def validate_password(self, password):
        """
        Validate the password agains the team. If it matches return ``True``
        else raise a :exc:`ValueError`.
        """
        salt, __ = bcrypt_split(self.password)
        referenece_pw = encrypt_pw(password, salt)
        if self.password != referenece_pw:
            raise ValueError("Passwords do not match")
        else:
            return True

    @property
    def password(self):
        return self._password

    @password.setter
    def password(self, pw):
        self._password = encrypt_pw(pw)

    @property
    def timezone(self):
        return timezone(self._timezone)

    @timezone.setter
    def timezone(self, tz):
        timezone = unicode(tz)
        assert timezone in all_timezones
        self._timezone = timezone

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name
