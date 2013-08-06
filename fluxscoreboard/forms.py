# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import get_unsolved_challenges
from fluxscoreboard.models.country import get_all_countries
from fluxscoreboard.models.team import TEAM_NAME_MAX_LENGTH, \
    TEAM_MAIL_MAX_LENGTH, Team
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
password_length_validator = validators.Length(min=8,
                                              message=("Oh boy, shorter than "
                                                       "%(min)d characters. "
                                                       "You should be "
                                                       "ashamed!")
                                              )
name_length_validator = validators.Length(min=5, max=TEAM_NAME_MAX_LENGTH,
                                          message=("Team name must have "
                                                   "a length between %(min)d "
                                                   "and %(max)d characters")
                                          )
required_validator = validators.Required(
    "This field is mandatory, please enter a valid value."
    )


class RegisterForm(Form):
    """Registration form for new teams."""
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
                                         password_length_validator,
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
    """Login form for teams that are activated."""
    email = EmailField("Team E-Mail",
                       validators=[required_validator])

    password = PasswordField("Password",
                             validators=[required_validator])

    login = SubmitField("Login")


class ProfileForm(Form):
    """A form to edit a team's profile."""
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
    """
    solution = TextField("Solution", validators=[required_validator,
                                                 ]
                         )

    submit = SubmitField("Submit")


class SolutionSubmitListForm(SolutionSubmitForm):
    """
    A form to submit a solution for any challenge selected from a list. Keeps
    track of which challenge the solution was submitted for.
    """
    challenge = QuerySelectField("Challenge",
                                 query_factory=get_unsolved_challenges,
                                 )
