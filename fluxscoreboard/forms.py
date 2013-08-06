# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import get_unsolved_challenges
from fluxscoreboard.models.country import get_all_countries
from fluxscoreboard.models.team import TEAM_NAME_MAX_LENGTH, \
    TEAM_MAIL_MAX_LENGTH, Team, TEAM_PASSWORD_MAX_LENGTH
from pytz import common_timezones, utc
from wtforms import validators
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from wtforms.fields.core import SelectField
from wtforms.fields.html5 import EmailField
from wtforms.fields.simple import TextField, SubmitField, PasswordField
from wtforms.form import Form


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
    message=("Wow! I am proud of you. But don't you thing %(max)d characters "
             "should be secure enough?"))
name_length_validator = validators.Length(min=5, max=TEAM_NAME_MAX_LENGTH,
                                          message=("Team name must have "
                                                   "a length between %(min)d "
                                                   "and %(max)d characters")
                                          )
required_validator = validators.Required(
    "This field is mandatory, please enter a valid value."
    )


class RegisterForm(Form):
    __doc__ = """
    Registration form for new teams.

    Attrs:
        ``name``: The name of the team, required and must have a length between
        %(name_min)d and %(name_max)d.

        ``email``: The teams E-Mail address, required, must be the same as
        ``email_repeat``, must have a length between %(mail_min)d and
        %(mail_max)d. It is also checked that this email is not registered
        yet.

        ``email_repeat``: Must have the same value as ``email``.

        ``password``: The team's password, must be between %(pw_min)d and
        %(pw_max)d characters long.

        ``password_repeat``: Must have the same value as ``password``.

        ``country``: A list of available countries in the database to choose
        from.

        ``timezone``: The timezone to apply for the team. When not selected,
        UTC is used, otherwise this localizes times displayed on the frontpage.

        ``submit``: The submit button.
    """ % {'name_min': name_length_validator.min,
           'name_max': name_length_validator.max,
           'mail_min': email_length_validator.min,
           'mail_max': email_length_validator.max,
           'pw_min': password_min_length_validator.min,
           'pw_max': password_max_length_validator.max,
           }
    name = TextField("Team Name",
                     validators=[required_validator,
                                 name_length_validator,
                                 ]
                     )

    email = EmailField("Team E-Mail",
                       validators=[required_validator,
                                   email_equal_validator,
                                   email_length_validator,
                                   email_unique_validator,
                                   ]
                       )

    email_repeat = EmailField("Repeat E-Mail",
                              validators=[required_validator,
                                          ]
                              )

    password = PasswordField("Password",
                             validators=[required_validator,
                                         password_equal_validator,
                                         password_min_length_validator,
                                         password_max_length_validator,
                                         ]
                         )

    password_repeat = PasswordField("Repeat Password",
                                    validators=[required_validator,
                                                ]
                                )

    country = QuerySelectField("Country/State",
                               query_factory=get_all_countries
                               )

    timezone = SelectField("Timezone",
                           choices=([('', '')] +
                                    [(tz, tz) for tz in common_timezones]),
                           default=((utc.zone, utc.zone)),
                           )

    submit = SubmitField("Register")


class LoginForm(Form):
    """
    Login form for teams that are activated.

    Attrs:
        ``email``: Login email address.

        ``password``: Login password.

        ``login``: Submit button.
    """
    email = EmailField("Team E-Mail",
                       validators=[required_validator])

    password = PasswordField("Password",
                             validators=[required_validator])

    login = SubmitField("Login")


class ProfileForm(Form):
    """
    A form to edit a team's profile.

    Attrs:
        ``email``: The email address. Required

        ``password``: The password. Optional, only needed if wanting to change.

        ``country``: Change location. Required.

        ``timezone``: Change timezone. Required.

        ``submit``: Save changes

        ``cancel``: Abort
    """
    email = EmailField("Team E-Mail",
                       validators=[required_validator])

    password = PasswordField("Password")

    country = QuerySelectField("Country/State",
                               query_factory=get_all_countries
                               )

    timezone = SelectField("Timezone",
                           choices=[(tz, tz) for tz in common_timezones],
                           default=((utc.zone, utc.zone)),
                           )

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class SolutionSubmitForm(Form):
    """
    A form to submit a solution for a challenge on a single challenge view.
    This form does not keep track of which challenge this is.

    Attrs:
        ``solution``: The proposed solution for the challenge. Required.

        ``submit``: Submit the solution.
    """
    solution = TextField("Solution", validators=[required_validator,
                                                 ]
                         )

    submit = SubmitField("Submit")


class SolutionSubmitListForm(SolutionSubmitForm):
    """
    A form to submit a solution for any challenge selected from a list. Keeps
    track of which challenge the solution was submitted for. Subclass of
    :class:`SolutionSubmitForm` and derives all attributes from it. New
    attributes defined here:

        ``challenge``: A list of challenges to choose from. Required.
    """
    challenge = QuerySelectField("Challenge",
                                 query_factory=get_unsolved_challenges,
                                 )
