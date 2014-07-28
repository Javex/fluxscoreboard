# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from pytz import utc, timezone, all_timezones
from sqlalchemy.types import TypeDecorator, DateTime, UnicodeText, Unicode
import json


class TZDateTime(TypeDecorator):
    """
    Coerces a tz-aware datetime object into a naive utc datetime object to be
    stored in the database. If already naive, will keep it.

    On return of the data will restore it as an aware object by assuming it
    is UTC.

    Use this instead of the standard :class:`sqlalchemy.types.DateTime`.
    """

    impl = DateTime

    def process_bind_param(self, value, dialect):
        if hasattr(value, 'tzinfo') and value.tzinfo is not None:
            value = value.astimezone(utc).replace(tzinfo=None)
        return value

    def process_result_value(self, value, dialect):
        if hasattr(value, 'tzinfo') and value.tzinfo is None:
            value = utc.localize(value)
        return value


class Timezone(TypeDecorator):
    """
    Represent a timezone, storing it as a unicode string but giving back a
    :class:`datetime.tzinfo` instance.
    """

    impl = Unicode

    def process_bind_param(self, value, dialect):
        if value is not None:
            if not isinstance(value, unicode):
                value = unicode(value)
            if value not in all_timezones:
                raise ValueError("Invalid Timezone")
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            return timezone(value)
        else:
            return None



class JSONList(TypeDecorator):
    """
    Represent an **immutable** list in the table, stored as a JSON string.
    Note that this must be updated as a whole or not at all. Do not try to
    mutate it in-place!
    """

    impl = UnicodeText

    def process_bind_param(self, value, dialect):
        return unicode(json.dumps(value)) if value is not None else None

    def process_result_value(self, value, dialect):
        return json.loads(value) if value is not None else None
