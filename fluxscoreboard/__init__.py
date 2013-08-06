# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession, RootFactory
from fluxscoreboard.models.team import groupfinder
from fluxscoreboard import routes
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.config import Configurator
from pyramid.settings import asbool
from pyramid_beaker import session_factory_from_settings
from sqlalchemy import engine_from_config, event
from zope.sqlalchemy import ZopeTransactionExtension  # @UnresolvedImport


__version__ = '0.1'

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    fix_setting_types(settings)

    # Database
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)

    # Database Session Events
    ext = ZopeTransactionExtension()
    for ev in ["after_begin", "after_attach", "after_flush",
               "after_bulk_update", "after_bulk_delete", "before_commit"]:
        func = getattr(ext, ev)
        event.listen(DBSession, ev, func)

    # Session & Auth
    session_factory = session_factory_from_settings(settings)
    authn_policy = SessionAuthenticationPolicy(callback=groupfinder)
    authz_policy = ACLAuthorizationPolicy()

    config = Configurator(settings=settings,
                          session_factory=session_factory,
                          authentication_policy=authn_policy,
                          authorization_policy=authz_policy,
                          root_factory=RootFactory,
                          )

    # Routes & Views
    config.add_static_view('static', 'static', cache_max_age=3600)
    for name, path in routes.routes:
        config.add_route(name, path)

    config.scan()
    return config.make_wsgi_app()


def fix_setting_types(settings):
    """
    Parses a settings dictionary and adjusts the types of certain settings so
    they are not all strings.
    """
    settings["submission_disabled"] = asbool(settings["submission_disabled"])
