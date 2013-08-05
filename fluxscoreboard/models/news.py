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
    """
    A single announcement, either global or for a challenge, depending on the
    ``challenge_id`` attribute.

    Attributes:
        ``id``: The primary key.

        ``timestamp``: A UTC-aware :class:`datetime.dateime` object. If setting
        always only pass either a timezone-aware object or a naive UTC
        datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``message``: The text of the announcement.

        ``published``: Whether the announcement is displayed in the frontend.

        ``challenge_id``: If present, which challenge this announcement belongs
        to.

        ``challenge``: Direct access to the challenge, if any.
    """
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
    """
    An entry of a mass mail that was sent.

    Attributes:
        ``id``: The primary key.

        ``timestamp``: A UTC-aware :class:`datetime.dateime` object. If setting
        always only pass either a timezone-aware object or a naive UTC
        datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``subject``: The subject of the mail

        ``message``: The body of the mail

        ``recipients``: A list of recipients that have recieved this mail.
        Internally this is stored as a json encoded list.

        ``from_``: The address which was used as the ``From:`` field of the
        mail.
    """
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
