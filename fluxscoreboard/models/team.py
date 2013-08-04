# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.types import Integer, Unicode, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import exists
import binascii
import os
from fluxscoreboard.util import bcrypt_split, encrypt_pw
import logging


log = logging.getLogger(__name__)


TEAM_NAME_MAX_LENGTH = 255
TEAM_MAIL_MAX_LENGTH = 255


TEAM_GROUPS = ['group:team']


def groupfinder(userid, request):
    team_exists = DBSession().query(exists().where(Team.id == userid)).scalar()
    if team_exists:
        return TEAM_GROUPS


def get_all_teams():
    return DBSession().query(Team).all()


def get_active_teams():
    return DBSession().query(Team).filter(Team.active == True).all()


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

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name
