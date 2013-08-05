# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.challenge import Submission, Challenge
from fluxscoreboard.util import bcrypt_split, encrypt_pw
from pyramid.security import authenticated_userid, unauthenticated_userid
from pytz import utc, timezone
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


def groupfinder(userid, request):
    if getattr(request, 'team', None) is None:
        get_team(request)
    if request.team:
        return TEAM_GROUPS


def get_all_teams():
    return DBSession().query(Team).all()


def get_active_teams():
    return DBSession().query(Team).filter(Team.active == True).all()


def get_team_solved_subquery(dbsession, team_id):
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
    return func.count(Submission.team_id)


def get_team(request):
    dbsession = DBSession()
    team_id = unauthenticated_userid(request)
    try:
        team = (dbsession.query(Team).
                filter(Team.id == team_id).
                filter(Team.active == True).one())
        request.team = team
    except NoResultFound:
        request.team = None


class Team(Base):
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
        self._timezone = unicode(tz)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name
