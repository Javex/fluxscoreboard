# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from PIL import Image
from pyramid.threadlocal import get_current_request
from wtforms.fields.core import _unset_value
from wtforms.fields.html5 import IntegerField
from wtforms.fields.simple import FileField
from wtforms.widgets.core import FileInput, HTMLString, html_params


__doc__ = """
This module contains some custom fields and widgets.
"""


class AvatarWidget(FileInput):
    """
    A widget that renders the current avatar above the form to upload a new
    one.

    .. todo::
        Create a button to delete the existing avatar.
    """

    def __call__(self, field, **kwargs):
        out = []
        request = get_current_request()
        filename = request.team.avatar_filename
        if filename:
            fpath = request.static_url("fluxscoreboard:static/images/avatars/%s"
                                       % filename)
            out.append('<img class="avatar-large" src="%s" />' % fpath)
        out.append(FileInput.__call__(self, field, **kwargs))
        return HTMLString(''.join(out))


class AvatarField(FileField):
    """
    An avatar upload field with a display of an existing avatar. Also gives
    access to an ``image`` that is in instance of a PIL ``Image`` if the
    filename is set.
    """
    widget = AvatarWidget()

    def process(self, formdata, data=_unset_value):
        FileField.process(self, formdata, data)
        try:
            self.image = Image.open(self.data.file)
        except (IOError, AttributeError):
            self.image = None


class ButtonWidget(object):
    """
    .. todo::
        Document
    """
    html_params = staticmethod(html_params)

    def __init__(self, *args, **kwargs):
        pass

    def __call__(self, field, **kwargs):
        kwargs.setdefault('id', field.id)
        val = field.label.text
        out = ('<button %s>%s</button>' %
               (self.html_params(name=field.name, **kwargs),
                val)
               )
        return HTMLString(out)


class IntegerOrEvaluatedField(IntegerField):
    """
    A field that is basically an integer but with the added exception that,
    if the challenge is manual, it will contain the value ``"evaulauted"``
    which is also valid.
    """

    def process_formdata(self, valuelist):
        [value] = valuelist
        if valuelist:
            if value == 'evaluated':
                self.data = None
                return True
            else:
                try:
                    self.data = int(value)
                except ValueError:
                    self.data = None
                    raise ValueError(self.gettext('Not a valid integer value'))