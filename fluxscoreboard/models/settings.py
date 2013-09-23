# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime
from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, Boolean


def get():
    """
    Get the single settings row. This intentionally calls ``one`` on the
    query to make sure the application breaks as soon as someone inserts more
    than one row.

    There's genrally two recommended ways to import and call this function
    without causing confusion:

    .. code-block:: python

        # If you have no local naming conflict
        from fluxscoreboard.models import settings
        settings.get()

        # If you want to name your variable settings do this:
        from fluxscoreboard.models.settings import get as get_settings
        settings = get_settings()
    """
    return DBSession().query(Settings).one()


class Settings(Base):
    """
    Represents application settings. Do **not** insert rows of this. There
    must always be only **one** row which is updated. This is preferred to
    having multiple rows with only key->value because with this we can
    enforce types and give an overview over available settings.

    The most straightforward usage is calling :func:`get` to retrieve the
    current settings which you can then also edit and they will be saved
    automatically.

    The following settings are available:

        ``submission_disabled``: A boolean that describes whether currently
        submissions are allowed or disabled. Default: ``False``

        ``ctf_start_date``: A timezone-aware datetime value that describes when
        the CTF should start. Before that, the application will behave
        differently, e.g. may not allow login.

        ``ctf_started``: This is a property that can only be read and just
        compares ``ctf_start_date`` with the current time to find out whether
        the CTF has already started or not.
    """
    id = Column(Integer, primary_key=True)
    submission_disabled = Column(Boolean, default=False)
    ctf_start_date = Column(TZDateTime)

    @property
    def ctf_started(self):
        from fluxscoreboard.util import now
        return now() >= self.ctf_start_date
