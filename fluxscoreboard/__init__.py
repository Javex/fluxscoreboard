# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession, RootFactory
from fluxscoreboard.routes import routes
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.config import Configurator
from pyramid_beaker import session_factory_from_settings
from sqlalchemy import engine_from_config
from fluxscoreboard.models.team import groupfinder


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """

    # Database
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)

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
    for name, path in routes:
        config.add_route(name, path)

    config.scan()
    return config.make_wsgi_app()
