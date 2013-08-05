# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base
from pytz import utc
from sqlalchemy.orm import relationship, backref
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.types import Integer, DateTime, UnicodeText, Boolean
import json


class News(Base):
    __tablename__ = 'news'
    id = Column(Integer, primary_key=True)
    _timestamp = Column('timestamp', DateTime,
                        nullable=False,
                        default=datetime.utcnow
                        )
    message = Column(UnicodeText)
    published = Column(Boolean, default=False)
    challenge_id = Column(Integer, ForeignKey('challenge.id'))

    challenge = relationship("Challenge",
                             backref=backref("announcements",
                                             cascade="all, delete-orphan",
                                             order_by="desc(News._timestamp)"),
                             lazy='joined')

    def __init__(self, *args, **kwargs):
        if "timestamp" not in kwargs:
            self.timestamp = datetime.utcnow()
        Base.__init__(self, *args, **kwargs)

    @property
    def timestamp(self):
        return utc.localize(self._timestamp)

    @timestamp.setter
    def timestamp(self, dt):
        if dt.tzinfo is None:
            dt = utc.localize(dt)
        self._timestamp = dt.astimezone(utc)


class MassMail(Base):
    __tablename__ = 'massmail'
    id = Column(Integer, primary_key=True)
    _timestamp = Column('timestamp', DateTime,
                        nullable=False,
                        default=datetime.utcnow
                        )
    subject = Column(UnicodeText, nullable=False)
    message = Column(UnicodeText, nullable=False)
    _recipients = Column('recipients', UnicodeText, nullable=False)
    from_ = Column(UnicodeText, nullable=False)

    @property
    def recipients(self):
        return json.loads(self._recipients)

    @recipients.setter
    def recipients(self, addr_list):
        self._recipients = json.dumps(addr_list)

    @property
    def timestamp(self):
        return utc.localize(self._timestamp)

    @timestamp.setter
    def timestamp(self, dt):
        if dt.tzinfo is None:
            dt = utc.localize(dt)
        self._timestamp = dt.astimezone(utc)
