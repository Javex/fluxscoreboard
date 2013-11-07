# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.types import TZDateTime
from pyramid.events import NewRequest, subscriber
from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, Boolean
import logging


log = logging.getLogger(__name__)


@subscriber(NewRequest)
def load_settings(event):
    settings = DBSession().query(Settings).one()
    event.request.settings = settings


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

        ``ctf_end_date``: When the CTF will end. Same type as
        ``ctf_start_date``.

        ``ctf_started``: This is a property that can only be read and just
        compares ``ctf_start_date`` with the current time to find out whether
        the CTF has already started or not.

        ``archive_mode``: When the scoreboard is in archive mode, the frontend
        will not allow alteration to the database. Additionally, the whole
        system is public so everyone can get their solutions checked. This is
        then verified and the result is returned, but it is not added to the
        database. The following things will change in archive mode:

            - No registration
            - No login
            - Start / End times ignored
            - Solutions can be submitted but will only return the result, not
              enter something into the databse
            - Challenges are public in addition to the scoreboard
    """
    id = Column(Integer, primary_key=True)
    submission_disabled = Column(Boolean, default=False)
    ctf_start_date = Column(TZDateTime)
    ctf_end_date = Column(TZDateTime)
    archive_mode = Column(Boolean, default=False, nullable=False)

    @property
    def ctf_started(self):
        from fluxscoreboard.util import now
        if self.ctf_start_date is None:
            return False
        return now() >= self.ctf_start_date
