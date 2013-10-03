# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from mako.lookup import TemplateLookup
from pyramid.asset import abspath_from_asset_spec
import pytest


@pytest.fixture(scope="session")
def template_lookup(settings):
    directories = list(filter(None, settings["mako.directories"].splitlines()))
    directories = [abspath_from_asset_spec(d) for d in directories]
    mod_dir = settings["mako.module_directory"]
    return TemplateLookup(directories=directories,
                          module_directory=mod_dir)


@pytest.fixture
def get_template(template_lookup):

    def _get(name):
        return template_lookup.get_template(name)
    return _get
