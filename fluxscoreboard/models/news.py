# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from datetime import datetime
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime, JSONList
from sqlalchemy.orm import relationship, backref
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.sql.expression import desc
from sqlalchemy.types import Integer, UnicodeText, Boolean


def get_published_news():
    announcements = (DBSession().query(News).
                     filter(News.published == True).
                     order_by(desc(News.timestamp)))
    return announcements


class News(Base):
    """
    A single announcement, either global or for a challenge, depending on the
    ``challenge_id`` attribute.

    Attributes:
        ``id``: The primary key.

        ``timestamp``: A UTC-aware :class:`datetime.datetime` object. When
        assigning a value always pass either a timezone-aware object or a
        naive UTC datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``message``: The text of the announcement.

        ``published``: Whether the announcement is displayed in the frontend.

        ``challenge_id``: If present, which challenge this announcement belongs
        to.

        ``challenge``: Direct access to the challenge, if any.
    """
    id = Column(Integer, primary_key=True)
    timestamp = Column(TZDateTime,
                        nullable=False,
                        default=datetime.utcnow
                        )
    message = Column(UnicodeText)
    published = Column(Boolean, default=False)
    challenge_id = Column(Integer, ForeignKey('challenge.id'))

    challenge = relationship("Challenge",
                             backref=backref("announcements",
                                             cascade="all",
                                             order_by="desc(News.timestamp)"),
                             lazy='joined')

    def __init__(self, *args, **kwargs):
        kwargs.setdefault("timestamp", datetime.utcnow())
        Base.__init__(self, *args, **kwargs)

    def __repr__(self):
        r = ("<News id=%s, from=%s, message=%s, challenge=%s>"
             % (self.id, self.timestamp,
                self.message[:20] if self.message else None,
                repr(self.challenge)))
        return r.encode("utf-8")


class MassMail(Base):
    """
    An entry of a mass mail that was sent.

    Attributes:
        ``id``: The primary key.

        ``timestamp``: A UTC-aware :class:`datetime.datetime` object. When
        assigning a value always pass either a timezone-aware object or a
        naive UTC datetime. Defaults to :meth:`datetime.datetime.utcnow`.

        ``subject``: The subject of the mail

        ``message``: The body of the mail

        ``recipients``: A list of recipients that have recieved this mail.
        Internally this is stored as a json encoded list.

        ``from_``: The address which was used as the ``From:`` field of the
        mail.
    """
    id = Column(Integer, primary_key=True)
    timestamp = Column(TZDateTime,
                        nullable=False,
                        default=datetime.utcnow
                        )
    subject = Column(UnicodeText, nullable=False)
    message = Column(UnicodeText, nullable=False)
    recipients = Column(JSONList, nullable=False)
    from_ = Column(UnicodeText, nullable=False)
