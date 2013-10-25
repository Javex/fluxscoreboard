# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from conftest import ROOT_PATH
from mako.lookup import TemplateLookup
from pyramid.asset import abspath_from_asset_spec
import os
import pytest


@pytest.fixture(scope="session")
def template_lookup(settings):
    directories = list(filter(None, settings["mako.directories"].splitlines()))
    directories = [abspath_from_asset_spec(d) for d in directories]
    mod_dir = settings["mako.module_directory"]
    return TemplateLookup(directories=directories,
                          module_directory=mod_dir)


@pytest.fixture(scope="session")
def get_template(template_lookup):

    def _get(name):
        return template_lookup.get_template(name)
    return _get


@pytest.fixture(scope="session", autouse=True)
def load_all_templates(get_template):
    """
    Makes sure that all templates were compiled once so they are included in
    the coverage report. Is on autouse thus does not need to be included
    somewhere.
    """
    full_dir = os.path.abspath(os.path.join(ROOT_PATH, 'fluxscoreboard',
                                            'templates'))
    for path, _, files in os.walk(full_dir):
        for file_ in files:
            full_path = os.path.abspath(os.path.join(path, file_))
            relp = os.path.relpath(full_path, full_dir)
            if (not file_.endswith(".mako") or file_.endswith(".mak") or
                    not os.path.isfile(full_path)):
                continue
            get_template(relp)
