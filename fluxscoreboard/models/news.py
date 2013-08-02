# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.types import Integer, DateTime, UnicodeText, Enum, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
import json


class News(Base):
    __tablename__ = 'news'
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime)
    message = Column(UnicodeText)
    published = Column(Boolean, default=False)
    challenge_id = Column(Integer, ForeignKey('challenge.id'))

    challenge = relationship("Challenge", backref="news", lazy='joined')

    def __init__(self, *args, **kwargs):
        if "timestamp" not in kwargs:
            self.timestamp = datetime.utcnow()
        Base.__init__(self, *args, **kwargs)


class MassMail(Base):
    __tablename__ = 'massmail'
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, nullable=False)
    subject = Column(UnicodeText, nullable=False)
    message = Column(UnicodeText, nullable=False)
    _recipients = Column('recipients', UnicodeText, nullable=False)
    from_ = Column(UnicodeText, nullable=False)

    def __init__(self, *args, **kwargs):
        if "timestamp" not in kwargs:
            self.timestamp = datetime.utcnow()
        Base.__init__(self, *args, **kwargs)

    @property
    def recipients(self):
        return json.loads(self._recipients)

    @recipients.setter
    def recipients(self, addr_list):
        self._recipients = json.dumps(addr_list)
