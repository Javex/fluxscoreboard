# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.settings import get, Settings


def test_get(dbsession):
    assert isinstance(get(), Settings)


class TestSettings(object):
    pass
