# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from wtforms.form import Form
from wtforms.fields.simple import TextField, SubmitField, PasswordField
from wtforms import validators
from wtforms.fields.html5 import EmailField
from wtforms.fields.core import SelectField
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from fluxscoreboard.models.country import get_all_countries
from fluxscoreboard.models.team import TEAM_NAME_MAX_LENGTH, \
    TEAM_MAIL_MAX_LENGTH


email_validator = validators.Email("Please enter a valid E-Mail Address.")
email_equal_validator = validators.EqualTo("email_repeat",
                                            "E-Mail Addressed do not match.")
email_length_validator = validators.Length(min=5, max=TEAM_MAIL_MAX_LENGTH,
                                           message=("Team email must "
                                                    "have a length between "
                                                    "%(min)d and %(max)d "
                                                    "characters")
                                           )
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
    name = TextField("Team Name",
                     validators=[required_validator,
                                 name_length_validator,
                                 ]
                     )

    email = EmailField("Team E-Mail",
                       validators=[required_validator,
                                   email_equal_validator,
                                   email_length_validator,
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

    submit = SubmitField("Register")


class LoginForm(Form):
    email = EmailField("Team E-Mail",
                       validators=[required_validator])

    password = PasswordField("Password",
                             validators=[required_validator])

    login = SubmitField("Login")
