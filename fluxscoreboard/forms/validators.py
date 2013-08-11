# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.team import TEAM_MAIL_MAX_LENGTH, Team, \
    TEAM_PASSWORD_MAX_LENGTH, TEAM_NAME_MAX_LENGTH
from wtforms import validators
from sqlalchemy.orm.exc import NoResultFound

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


def required_or_manual(form, field):
    """
    Enforces a "required" only if the "manual" field is not set.
    """
    if not form.manual.data:
        return required_validator(form, field)
    else:
        return field.data is None
