# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import RootFactory


def test_RootFactory(pyramid_request):
    RootFactory(pyramid_request)