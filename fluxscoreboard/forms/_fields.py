# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms._validators import (RecaptchaValidator,
    greater_zero_if_set)
from pyramid.threadlocal import get_current_request
from pytz import utc
from wtforms.fields.core import Field
from wtforms.fields.html5 import IntegerField, DateTimeField
from wtforms.fields.simple import FileField
from wtforms.widgets.core import FileInput, HTMLString, html_params, Input
from wtforms.widgets.html5 import NumberInput


__doc__ = """
This module contains some custom fields and widgets.
"""


class AvatarWidget(FileInput):
    """
    A widget that renders the current avatar above the form to upload a new
    one.
    """

    def __call__(self, field, **kwargs):
        out = []
        request = get_current_request()
        filename = request.team.avatar_filename
        if filename:
            fpath = request.route_url('avatar', avatar=filename)
            out.append('<img class="avatar-large" src="%s" />' % fpath)
            out.append('<input id="delete-avatar" type="submit" '
                       'class="btn btn-danger btn-small" value="Delete Avatar"'
                       ' name="delete-avatar" />')
        out.append(FileInput.__call__(self, field, **kwargs))
        return HTMLString(''.join(out))


class AvatarField(FileField):
    """
    An avatar upload field with a display of an existing avatar.
    """
    widget = AvatarWidget()

    def process(self, formdata, *args, **kw):
        if formdata.getlist("delete-avatar"):
            self.delete = True
        else:
            self.delete = False
        return FileField.process(self, formdata, *args, **kw)


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
    which is also valid. May also be empty.
    """

    def process_formdata(self, valuelist):
        [value] = valuelist
        if valuelist:
            if value == 'evaluated':
                self.data = None
                return True
            elif not value:
                self.data = None
                return True
            else:
                try:
                    self.data = int(value)
                except ValueError:
                    self.data = None
                    raise ValueError(self.gettext('Not a valid integer value'))


class IntegerOrNoneField(IntegerField):

    def process_formdata(self, valuelist):
        if valuelist and valuelist[0]:
            return IntegerField.process_formdata(self, valuelist)
        else:
            self.data = None
            return True


class BootstrapWidget(Input):

    def __init__(self, input_type=None, group_before=None, group_after=None,
                 default_classes=None):
        self.group_before = group_before or []
        self.group_after = group_after or []
        self.default_classes = default_classes or []
        Input.__init__(self, input_type=input_type)

    def __call__(self, field, **kwargs):
        html = []
        html.append('<div class="input-group">')

        for text in self.group_before:
            html.append('<span class="input-group-addon">%s</span>' % text)

        classes = kwargs.get("class_", "").split(" ")
        for class_ in self.default_classes:
            classes.append(class_)
        kwargs["class_"] = " ".join(classes)
        html.append(Input.__call__(self, field, **kwargs))

        for text in self.group_after:
            html.append('<span class="input-group-addon">%s</span>' % text)

        html.append('</div>')

        return HTMLString("".join(html))


def team_size_field():
    return IntegerOrNoneField("Team Size",
                        description=("For statistical purposes we would "
                                     "like to know how many you are. "
                                     "There is no limitation on the number "
                                     "of people each team may bring, we "
                                     "just like to know the sizes of "
                                     "teams."),
                        widget=BootstrapWidget(
                            'number',
                            group_after=['Members'],
                            default_classes=['text-right']),
                        validators=[greater_zero_if_set],
                        )


class RecaptchaWidget(object):
    """
    RecaptchaValidator widget that displays HTML depending on security status.
    """
    RECAPTCHA_HTML = u"""
        <script type="text/javascript"
         src="%(protocol)s://www.google.com/recaptcha/api/challenge?k=%(public_key)s">
        </script>
        <noscript>
            <iframe
             src="%(protocol)s://www.google.com/recaptcha/api/noscript?k=%(public_key)s"
             height="300" width="500" frameborder="0"></iframe><br>
            <textarea name="recaptcha_challenge_field" rows="3" cols="40">
            </textarea>
            <input type="hidden" name="recaptcha_response_field"
             value="manual_challenge">
        </noscript>
    """

    def __call__(self, field, **kwargs):
        html = self.RECAPTCHA_HTML % {
                'protocol': 'https' if field.secure else 'http',
                'public_key': field.public_key
        }
        return HTMLString(html)


class RecaptchaField(Field):
    """Handles captcha field display and validation via reCaptcha"""

    widget = RecaptchaWidget()

    def __init__(self, label='', validators=None, public_key=None,
                 private_key=None, secure=False, http_proxy=None, **kwargs):
        # Pretty useless without the RecaptchaValidator but still
        # user may want to subclass it, so keep it optional
        validators = validators or [RecaptchaValidator()]
        super(RecaptchaField, self).__init__(label, validators, **kwargs)

        if not public_key or not private_key:
            raise ValueError('Both recaptcha public and private keys are '
                             'required.')

        self.public_key = public_key
        self.private_key = private_key
        self.secure = secure
        self.http_proxy = http_proxy

        self.ip_address = None
        self.challenge = None

    def process(self, formdata, data={}):
        """Handles multiple formdata fields that are required for reCaptcha.
        Only response field is handled as raw_data as it is the only user input
        """
        self.process_errors = []

        if isinstance(data, dict):
            self.ip_address = data.pop('ip_address', None)

        try:
            self.process_data(data)
        except ValueError, e:
            self.process_errors.append(e.args[0])

        if formdata is not None:
            # Developer must supply ip_address directly so throw a
            # non-validation exception if it's not present
            if not self.ip_address:
                raise ValueError('IP address is required.')

            try:
                # These fields are coming from the outside so keep them
                # inside the usual process
                challenge = formdata.getlist('recaptcha_challenge_field')
                if not challenge:
                    raise ValueError(self.gettext('Challenge data is '
                                                  'required.'))
                self.challenge = challenge[0]

                # Pass user input as the raw_data
                self.raw_data = formdata.getlist('recaptcha_response_field')
                self.process_formdata(self.raw_data)
            except ValueError, e:
                self.process_errors.append(e.args[0])

        for filter_ in self.filters:
            try:
                self.data = filter_(self.data)
            except ValueError, e:
                self.process_errors.append(e.args[0])


class TZDateTimeField(DateTimeField):
    def process_formdata(self, valuelist):
        DateTimeField.process_formdata(self, valuelist)
        if self.data:
            self.data = utc.localize(self.data)
