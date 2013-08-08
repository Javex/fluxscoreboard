# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from wtforms.ext.csrf.form import SecureForm
from wtforms.fields.html5 import IntegerField
from wtforms.fields.simple import HiddenField
import logging


log = logging.getLogger(__name__)


class CSRFForm(SecureForm):
    """
    .. todo::
        Document.
    """

    def generate_csrf_token(self, csrf_context):
        self.request = csrf_context
        return self.request.session.get_csrf_token()

    def validate(self):
        result = SecureForm.validate(self)
        if not result and self.csrf_token.errors:
            log.warn("Invalid CSRF token with error(s) '%s' from IP address "
                     "'%s'."
                     % (", ".join(self.csrf_token.errors),
                        self.request.client_addr))
        return result


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
