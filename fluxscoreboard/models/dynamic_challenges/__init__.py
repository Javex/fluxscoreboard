# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from . import protocols


__doc__ = """
The system allows you to build challenges that work as dynamic python modules.
Through a minimal interface, this allows you to create a challenge that can
display anything it wants.
"""

registry = {'protocols': protocols}
"""
Registry for all dynamic challenges, to be registered here with their name
as a key and module as a value.
"""
