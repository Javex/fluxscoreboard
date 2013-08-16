# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.team import TEAM_MAIL_MAX_LENGTH, Team, \
    TEAM_PASSWORD_MAX_LENGTH, TEAM_NAME_MAX_LENGTH
from wtforms import validators
from pyramid.threadlocal import get_current_request

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
    email = field.data
    dbsession = DBSession()
    email_exists = dbsession.query(Team).filter(Team.email == email).all()
    if len(email_exists) > 0:
        raise ValueError("This email is already registered.")
    else:
        return True


password_equal_validator = validators.EqualTo("password_repeat",
                                              "Passwords do not match.")
password_min_length_validator = validators.Length(
    min=8, message=("Oh boy, shorter than %(min)d characters. You should be "
                    "ashamed!"))
password_max_length_validator = validators.Length(
    max=TEAM_PASSWORD_MAX_LENGTH,
    message=("Wow! I am proud of you. But don't you think %(max)d characters "
             "should be secure enough?"))
name_length_validator = validators.Length(min=5, max=TEAM_NAME_MAX_LENGTH,
                                          message=("Team name must have "
                                                   "a length between %(min)d "
                                                   "and %(max)d characters")
                                          )
required_validator = validators.Required(
    "This field is mandatory, please enter a valid value."
    )


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


def required_or_manual(form, field):
    """
    Enforces a "required" only if the "manual" field is not set.
    """
    if not form.manual.data:
        return required_validator(form, field)
    else:
        # TODO: Shouldn't this part raise a ValueError if field.data is not
        # None?
        return field.data is None


class AvatarDimensions(object):
    """
    A validator for image dimensions. Pass it a maximum width and height with
    the ``max_width`` and ``max_height`` parameters and optionally a custom
    message that has access to both parameters:
    ``"Maximum dimensions: (%(max_width)d, %(max_height)d)"``.

    .. note::
        This validator requires access to a PIL Image, for example from the
        :class:`forms.fields.AvatarField`.
    """

    def __init__(self, max_width, max_height, message=None):
        self.max_width = max_width
        self.max_height = max_height
        if message is None:
            message = ('Invalid dimensions. The maximum allowed width is '
                       '%(max_width)dpx and the maximum allowed height is '
                       '%(max_height)dpx.')
        self.message = message % locals()

    def __call__(self, form, field):
        if field.data == '' or field.data is None:
            return True
        if field.image is None:
            raise ValueError("Invalid image.")
        width, height = field.image.size
        if width > self.max_width or height > self.max_height:
            raise ValueError(self.message)
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


avatar_dimensions_validator = AvatarDimensions(450, 200)
avatar_size_validator = AvatarSize(1)
