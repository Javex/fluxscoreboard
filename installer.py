# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from paste.deploy.loadwsgi import appconfig
from sqlalchemy.engine import engine_from_config
import os
import sys
from pyramid.paster import setup_logging
from fluxscoreboard.models import DBSession
from fluxscoreboard.install import uninstall, install
import shutil
"""
Script to help with application installation.
"""


ROOT_PATH = os.path.dirname(__file__)
EXISTING_SUBDIRS = ["tmp", "log"]

if __name__ == '__main__':
    filename = 'production.ini'
    if len(sys.argv) >= 3:
        filename = sys.argv[2]
        print("[*] Using configuration file %s" % filename)
    config_file = os.path.abspath(os.path.join(ROOT_PATH, filename))
    settings = appconfig('config:' + config_file)
    # has to be set up before laoding the logging config
    for dir_ in EXISTING_SUBDIRS:
        try:
            os.mkdir(os.path.abspath(os.path.join(ROOT_PATH, dir_)))
        except OSError:
            # try already exists, that's okay
            pass
    with open("log/fluxscoreboard.log", "w") as f:
        os.utime(f.name, None)
    setup_logging(config_file + '#loggers')
    task = sys.argv[1]
    if task in ["install", "install_test"]:
        engine = engine_from_config(settings, 'sqlalchemy.')
        DBSession.configure(bind=engine)
        install(settings, test_data=(task == "install_test"))
        print("[*] Application installed")
    elif task == "uninstall":
        engine = engine_from_config(settings, 'sqlalchemy.')
        DBSession.configure(bind=engine)
        uninstall(settings)
        for dir_ in EXISTING_SUBDIRS:
            shutil.rmtree(os.path.abspath(os.path.join(ROOT_PATH, dir)))
        print("[*] Application uninstalled")
    else:
        raise ValueError("First argument must be either 'install' or "
                         "'uninstall', not '%s'" % task)
