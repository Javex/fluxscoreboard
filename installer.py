# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.install import uninstall, install
from fluxscoreboard.models import DBSession
from paste.deploy.loadwsgi import appconfig
from pyramid.paster import setup_logging
from sqlalchemy.engine import engine_from_config
from subprocess import call
import os
import re
import shutil
import sys
import logging
"""
Script to help with application installation.
"""

ROOT_PATH = os.path.dirname(__file__)
EXISTING_SUBDIRS = ["tmp", "log"]
STATIC_PATH = os.path.abspath(os.path.join(ROOT_PATH,
                                           'fluxscoreboard',
                                           'static'))
YUICOMP = os.path.abspath(os.path.join(ROOT_PATH, 'yuicompressor.jar'))
log = logging.getLogger(__name__)


def minify():
    """
    Minify and compress all JS and CSS files.
    """
    for dirpath, __, filenames in os.walk(STATIC_PATH):
        for filename in filenames:
            try:
                basename, ext = filename.rsplit('.', 1)
            except:
                continue
            min_name = '%s.min.%s' % (basename, ext)
            file_path = os.path.abspath(os.path.join(dirpath, filename))
            min_path = os.path.abspath(os.path.join(dirpath, min_name))
            if (re.match(r'^.*\.(css|js)$', filename) and
                    not os.path.exists(min_path) and
                    not re.match(r'^.*\.min\.(css|js)$', filename)):
                call(['java', '-jar', YUICOMP, '-o', min_path,
                               file_path])


if __name__ == '__main__':
    filename = 'production.ini'
    if len(sys.argv) >= 3:
        filename = sys.argv[2]
        print("[*] Using configuration file %s" % filename)
    config_file = os.path.abspath(os.path.join(ROOT_PATH, filename))
    settings = appconfig('config:' + config_file)
    # has to be set up before laoding the logging config
    print("[*] Installing directories and files")
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
        print("[*] Installing database")
        engine = engine_from_config(settings, 'sqlalchemy.')
        DBSession.configure(bind=engine)
        install(settings, test_data=(task == "install_test"))
        print("[*] Minifying and joining CSS/JS files")
        minify()
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
