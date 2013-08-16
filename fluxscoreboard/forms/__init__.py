# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from wtforms.ext.csrf.form import SecureForm
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
