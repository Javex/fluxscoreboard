# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard import routes
from fluxscoreboard.forms.fields import RecaptchaField
from fluxscoreboard.forms.front import RegisterForm
from fluxscoreboard.models import DBSession, RootFactory
from fluxscoreboard.models.team import groupfinder
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.config import Configurator
from pyramid.settings import asbool
from pyramid_beaker import session_factory_from_settings
from sqlalchemy import engine_from_config
import warnings


__version__ = '0.3.7'
# ALWAYS make an exception for a warning (from sqlalchemy)
warnings.filterwarnings("error", category=Warning, module=r'.*sqlalchemy.*')


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    fix_setting_types(settings)

    # Database
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)

    # Session & Auth
    session_factory = session_factory_from_settings(settings)
    authn_policy = SessionAuthenticationPolicy(callback=groupfinder)
    authz_policy = ACLAuthorizationPolicy()

    # Add reCAPTCHA to registration form
    pub_key = settings["recaptcha.public_key"]
    priv_key = settings["recaptcha.private_key"]
    RegisterForm.captcha = RecaptchaField(public_key=pub_key,
                                          private_key=priv_key,
                                          secure=True)

    config = Configurator(settings=settings,
                          session_factory=session_factory,
                          authentication_policy=authn_policy,
                          authorization_policy=authz_policy,
                          root_factory=RootFactory,
                          )

    # Routes & Views
    static_dir = 'static'
    subdirectory = settings.get("subdirectory", "")
    if subdirectory:
        static_dir = subdirectory + "/" + static_dir
    config.add_static_view(static_dir, 'static', cache_max_age=3600)
    avatar_domain = settings["avatar_domain"]
    avatar_base_url = '%s/static/images/avatars/' % avatar_domain
    config.add_route('avatar', avatar_base_url + '{avatar}')
    config.add_route('rules', settings["rules_url"])
    init_routes(config, subdirectory)
    config.scan()
    return config.make_wsgi_app()


def init_routes(config, subdirectory=""):
    for name, path in routes.routes:
        if subdirectory:
            path = "/" + subdirectory + path
        config.add_route(name, path)


def fix_setting_types(settings):
    """
    Parses a settings dictionary and adjusts the types of certain settings so
    they are not all strings. Additionally, may adjust some setting values,
    for example strip their strings.
    """
    # settings to be converted to boolean
    # currently no settings to convert
    for setting in []:
        settings[setting] = asbool(settings[setting])

    # settings to be stripped
    for setting in ["subdirectory"]:
        if setting in settings:
            settings[setting] = settings[setting].strip()

