# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from paste.deploy.loadwsgi import appconfig
from sqlalchemy.engine import engine_from_config
import os
import sys
import transaction
from pyramid.paster import setup_logging
from fluxscoreboard.models import DBSession
from fluxscoreboard.install import uninstall, install
"""
Script to help with application installation.
"""


ROOT_PATH = os.path.dirname(__file__)

if __name__ == '__main__':
    filename = 'production.ini'
    config_file = os.path.abspath(os.path.join(ROOT_PATH, filename))
    if len(sys.argv) >= 3:
        filename = sys.argv[2]
    settings = appconfig('config:' + config_file)
    setup_logging(config_file + '#loggers')
    task = sys.argv[1]
    if task in ["install", "install_test"]:
        engine = engine_from_config(settings, 'sqlalchemy.')
        DBSession.configure(bind=engine)
        install(settings, test_data=(task == "install_test"))
        transaction.commit()
        print("[*] Application installed")
    elif task == "uninstall":
        engine = engine_from_config(settings, 'sqlalchemy.')
        DBSession.configure(bind=engine)
        uninstall(settings)
        print("[*] Application uninstalled")
    else:
        raise ValueError("First argument must be either 'install' or "
                         "'uninstall', not '%s'" % task)
