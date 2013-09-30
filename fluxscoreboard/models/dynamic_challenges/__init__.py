# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from . import flags
from .flags import GeoIP, TeamFlag


__doc__ = """
The system allows you to build challenges that work as dynamic python modules.
Through a minimal interface, this allows you to create a challenge that can
display anything it wants.
"""

registry = {'flags': flags}
"""
Registry for all dynamic challenges, to be registered here with their name
as a key and module as a value.
"""
