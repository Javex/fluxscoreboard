# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function

from sqlalchemy.orm.scoping import scoped_session
from sqlalchemy.orm.session import sessionmaker
from sqlalchemy.ext.declarative.api import declarative_base
from zope.sqlalchemy import ZopeTransactionExtension  # @UnresolvedImport

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

from fluxscoreboard.models.challenge import Challenge, Submission
from fluxscoreboard.models.country import Country
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team
