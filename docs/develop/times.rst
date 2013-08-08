Times and Timezones
===================

Working with times is relatively easy if you obey one rule: **UTC, always!**.
That means: Always store times in UTC so that when to receive them, they are
UTC even if the object is naive.

Now
---

To get the current time use :meth:`datetime.datetime.utcnow` or
:meth:`time.time`. This yields UTC time (in the case of ``time`` this is
irrelevant since the Epoch is timezone independent.


Converting Times
----------------

Conversion between a timestampe and a datetime object can be done with these
functions (note that there is also the representation of timetuple which can
also be helpful sometimes).

- timestamp --> datetime: :meth:`datetime.datetime.utcfromtimestamp`
- datetime --> timestamp: :meth:`datetime.datetime.utctimetuple` and
  :func:`calendar.timegm`


Displaying Times
----------------

The most easy way to display a time is to use the
:func:`fluxscoreboard.util.tz_str` function:

.. code-block:: python

    from pytz import utc
    from fluxscoreboard.util import tz_str
    from datetime import datetime
    local_time_str = tz_str(utc.localize(datetime.utcnow()),
                            request.team.timezone)

This is very easy because the team property is available in the request and it
already know the teams timezone. Where you get the timestamp depends on what
you are working on. For example, all timestamps in the database are managed in
such a way that they already have the UTC timezone attached. Thus, for
example, to display an announcements' time, you would go like this:

.. code-block:: python

    from fluxscoreboard.util import tz_str
    from fluxscoreboard.model.news import News
    news = News()
    local_time_str = tz_str(news.timestamp, request.team.timezone)


More In-Depth Explanation
#########################

To display times, we need a timezone to display it in. Teams provide their
timezone on registration so that is the timezone we will use for display of
local timestamps. To get a localized timestamp from a naive timestamp (e.g. one
generated from the methods described in `Now`_) we use the `pytz`_ module to
first build a UTC timestamp (remember, **always UTC**?) which we can then
localize:

.. _pytz: http://pytz.sourceforge.net/

.. code-block:: python

    from pytz import utc, timezone
    from datetime import datetime
    timestamp = utc.localize(datetime.utcnow())
    local_time = timestamp.astimezone(timezone("Europe/Berlin"))

This converts a utc timestamp into localized German time.

New Timestamps
--------------

When you introduces new timestamps, always remember: **UTC, always**! If you
want to create a specific time, attach a timezone upon creation:

.. code-block:: python

    from pytz import utc
    from datetime import datetime
    timestamp = datetime(2013, 1, 1, tzinfo=utc)

If you are saving it somewhere (i.e. database) save it as a naive UTC timestamp
(saves you a lot of trouble) and then, upon retrieval, convert it to a timezone
aware UTC timestamp. For example, take a look at
:class:`fluxscoreboard.models.news.News` which shows how you could
implement this transparently.
