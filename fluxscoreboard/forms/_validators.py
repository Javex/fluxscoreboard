# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.team import (TEAM_MAIL_MAX_LENGTH, Team,
    TEAM_PASSWORD_MAX_LENGTH, TEAM_NAME_MAX_LENGTH)
from pyramid.threadlocal import get_current_request
from urllib import urlencode
from wtforms import validators
from wtforms.validators import ValidationError
import logging
import urllib2
from fluxscoreboard.models.challenge import Challenge


log = logging.getLogger(__name__)


__doc__ = """
Contains validators for forms with custom messages. Some validators are based
on the original present validators, others are own creations with extended
functionality.
"""


email_validator = validators.Email("Please enter a valid E-Mail Address.")
email_equal_validator = validators.EqualTo("email_repeat",
                                            "E-Mail Addressed do not match.")
email_length_validator = validators.Length(min=5, max=TEAM_MAIL_MAX_LENGTH,
                                           message=("Team email must "
                                                    "have a length between "
                                                    "%(min)d and %(max)d "
                                                    "characters")
                                           )


def email_unique_validator(form, field):
    """
    A validator to make sure the entered email is unique and does not exist
    yet.
    """
    email = field.data
    email_exists = DBSession.query(Team).filter(Team.email == email).all()
    if len(email_exists) > 0:
        raise ValueError("This email is already registered.")
    else:
        return True


def name_unique_validator(form, field):
    """
    A validator to make sure the entered team name is unique and does not exist
    yet.
    """
    name = field.data
    name_exists = DBSession.query(Team).filter(Team.name == name).all()
    if len(name_exists) > 0:
        raise ValueError("This name is already registered.")
    else:
        return True


password_equal_validator = validators.EqualTo("password_repeat",
                                              "Passwords do not match.")
password_min_length_validator = validators.Length(
    min=8, message=("Oh boy, shorter than %(min)d characters. You should be "
                    "ashamed!"))
password_max_length_validator = validators.Length(
    max=1024,
    message=("Wow! I am proud of you. But don't you think %(max)d characters "
             "should be secure enough?"))
name_length_validator = validators.Length(min=1, max=TEAM_NAME_MAX_LENGTH,
                                          message=("Team name must have "
                                                   "a length between %(min)d "
                                                   "and %(max)d characters")
                                          )
required_validator = validators.Required(
    "This field is mandatory, please enter a valid value."
    )


def greater_zero_if_set(form, field):
    if field.data is not None and field.data <= 0:
        raise ValidationError("If you enter a size it must be at least 1")
    else:
        return True


def password_length_validator_conditional(form, field):
    """
    A validator that only checks the length of the password if one was
    provided and otherwise just returns ``True``. Used so an item can be
    edited without entering the password for the team.
    """
    if field.data:
        min_len = password_min_length_validator(form, field)
        max_len = password_max_length_validator(form, field)
        return min_len and max_len
    else:
        return True


def password_required_if_new(form, field):
    """
    A validator that only requires a password if the team is newly created,
    i.e. its id is ``None``.
    """
    if form.id.data is None:
        return required_validator(form, field)
    else:
        return True


def password_required_and_valid_if_pw_change(form, field):
    """
    A validator that only requires a field to be set if a password change is
    intended, i.e. if the ``password`` field is set. It also checks that
    the entered password is correct.
    """
    request = get_current_request()
    if form.password.data:
        if not field.data:
            raise ValueError("The old password is required if setting a new "
                             "one.")
        elif not request.team.validate_password(field.data):
            raise ValueError("The old password is invalid.")
    else:
        return True


def password_max_length_if_set_validator(form, field):
    """
    Only apply the ``password_max_length_validator`` if the field is set at
    all.
    """
    if field.data:
        return password_max_length_validator(form, field)
    else:
        return True


def password_min_length_if_set_validator(form, field):
    """
    Only apply the ``password_min_length_validator`` if the field is set at
    all.
    """
    if field.data:
        return password_min_length_validator(form, field)
    else:
        return True


def required_or_not_allowed(field_list, validator=required_validator):
    """
    Enforces that a field is required _only_ if none of the fields in
    ``field_list`` are set. Pass in an alternative ``validator`` to allow for
    passing of validaton control down to another validator.
    """
    def _check(form, field):
        for other_field_name in field_list:
            other_field = getattr(form, other_field_name)
            if other_field.data:
                if field.data:
                    raise ValueError("This field is not allowed if field '%s' "
                                     "is selected" % other_field.label.text)
                else:
                    return True
        return validator(form, field)
    return _check


def required_except(field_list):
    """
    Enforces a required constraint only if none of the fields in ``field_list``
    are set. The fields in ``field_list`` must be strings with names from other
    form fields.
    """
    def _check(form, field):
        for other_field_name in field_list:
            other_field = getattr(form, other_field_name)
            if other_field.data:
                return True
        return required_validator(form, field)
    return _check


def not_dynamic(form, field):
    """
    Checks that the "dynamic" checkbox is not checked.
    """
    if form.dynamic.data and field.data:
        raise ValueError("Not possible for dynamic challenges.")
    else:
        return True


def only_if_dynamic(form, field):
    """
    Enforces that this field is only allowed if the challenge is dynamic (and
    in that case it **must** be set).
    """
    if form.dynamic.data and not field.data:
        raise ValueError("Invalid value for a dynamic challenge.")
    elif not form.dynamic.data and field.data:
        raise ValueError("Challenge is not dynamic. Invalid selection.")


def dynamic_check_multiple_allowed(form, field):
    """
    Checks if multiple fields are allowed and if they are not and there already
    is a challenge with this dynamic type, then fail.
    """
    if not form.dynamic.data or not field.data:
        return True
    from ..models import dynamic_challenges
    module = dynamic_challenges.registry[field.data]
    instance_exists = (DBSession.query(Challenge).
                       filter(Challenge.module == field.data))
    if form.id.data:
        instance_exists = instance_exists.filter(Challenge.id != form.id.data)
    if not module.allow_multiple and instance_exists.first():
        raise ValueError("Multiple instances of this module are not allowed.")
    else:
        return True


class AvatarSize(object):
    """
    A validator class for the size of a file. Pass it a ``max_size`` to set
    the value of maximum size. The unit is determined by the ``unit`` parameter
    and defaults to 'MB'. Supported units are 'B', 'KB' and 'GB'. Optionally,
    you can pass in a custom message which has access to the ``max_size`` and
    ``unit`` parameters: ``"Maximum size: %(max_size)d%(unit)s"``.
    """

    unit_mult = {'B': 1, 'KB': 1024.0, 'MB': 1024.0 ** 2, 'GB': 1024.0 ** 3}

    def __init__(self, max_size, unit='MB', message=None):
        self.max_size = max_size
        self.unit = unit.upper()
        if message is None:
            message = ('File too large. Maximum allowed size '
                       'is %(max_size)d%(unit)s')
        self.message = message % locals()

    def __call__(self, form, field):
        if field.data == '' or field.data is None:
            return True
        byte_size = len(field.data.value)
        unit_size = byte_size / self.unit_mult[self.unit]
        if unit_size > self.max_size:
            raise ValueError(self.message)
        else:
            return True


avatar_size_validator = AvatarSize(100, 'KB')


class RecaptchaValidator(object):
    """Validates captcha by using reCaptcha API"""

    # Mapping of response error codes
    errors = {
        'invalid-site-public-key': u'Invalid public key',
        'invalid-site-private-key': u'Invalid private key',
        'invalid-request-cookie': u'Challenge is incorrect',
        'incorrect-captcha-sol': u'Incorrect captcha solution',
        'verify-params-incorrect': u'Incorrect parameters',
        'invalid-referrer': u'Incorrect domain',
        'recaptcha-not-reachable': u'Could not connect to reCaptcha'
    }

    empty_error_text = u'This field is required'
    internal_error_text = u'Internal error, please try again later'

    def _call_verify(self, params, proxy):
        """Performs a call to reCaptcha API with given params"""
        data = []
        if proxy:
            proxy_handler = urllib2.ProxyHandler({'http': proxy})
            opener = urllib2.build_opener(proxy_handler)
            urllib2.install_opener(opener)

        try:
            response = urllib2.urlopen(
                           'http://www.google.com/recaptcha/api/verify',
                           data=urlencode(params)
                           )
            data = response.read().splitlines()
            response.close()
        except Exception, e:
            log.error(str(e))
            raise ValidationError(self.errors['recaptcha-not-reachable'])

        return data

    def __call__(self, form, field):
        # Captcha challenge response is required
        if not field.data:
            raise ValidationError(field.gettext(self.empty_error_text))

        # Construct params assuming all the data is present
        params = (('privatekey', field.private_key),
                  ('remoteip', field.ip_address),
                  ('challenge', field.challenge),
                  ('response', field.data))

        data = self._call_verify(params, field.http_proxy)
        if data[0] == 'false':
            # Show only incorrect solution to the user else show default message
            if data[1] == 'incorrect-captcha-sol':
                raise ValidationError(field.gettext(self.errors[data[1]]))
            else:
                # Log error message in case it wasn't triggered by user
                log.error(self.errors.get(data[1], data[1]) + " from IP %s"
                          % field.ip_address)
                raise ValidationError(field.gettext(self.internal_error_text))
