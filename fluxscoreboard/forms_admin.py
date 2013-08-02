# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import required_validator, password_length_validator, \
    name_length_validator, email_length_validator
from fluxscoreboard.models.challenge import get_online_challenges
from wtforms import validators
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from wtforms.fields.core import SelectField, IntegerField, BooleanField
from wtforms.fields.simple import TextAreaField, SubmitField, HiddenField, \
    TextField, PasswordField
from wtforms.form import Form
from fluxscoreboard.models.team import TEAM_NAME_MAX_LENGTH, get_active_teams
from wtforms.fields.html5 import EmailField
from fluxscoreboard.models.country import get_all_countries
from pyramid.threadlocal import get_current_registry


def password_length_validator_conditional(form, field):
    if field.data:
        return password_length_validator(form, field)
    else:
        return True


class NewsForm(Form):
    message = TextAreaField("Message",
                            validators=[required_validator])

    published = BooleanField("Published")

    challenge = QuerySelectField("Challenge",
                                 query_factory=get_online_challenges,
                                 allow_blank=True,
                                 blank_text='-- General Announcement --')

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class ChallengeForm(Form):
    title = TextField("Title",
                      validators=[required_validator,
                                  validators.Length(max=255),
                                  ]
                      )

    text = TextAreaField("Text",
                         validators=[required_validator]
                         )

    solution = TextField("Solution",
                         validators=[required_validator]
                         )

    points = IntegerField("Points",
                          validators=[required_validator]
                          )

    status = BooleanField("Published")

    manual = BooleanField("Manual Challenge")

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class TeamForm(Form):
    name = TextField("Team Name",
                     validators=[required_validator,
                                 name_length_validator,
                                 ]
                     )

    password = PasswordField("Password",
                             validators=[password_length_validator_conditional]
                             )

    email = EmailField("E-Mail Address",
                       validators=[required_validator,
                                   email_length_validator,
                                   ]
                       )

    country = QuerySelectField("Country/State",
                               query_factory=get_all_countries
                               )

    active = BooleanField("Active")

    local = BooleanField("Local")

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class SubmissionForm(Form):
    challenge = QuerySelectField("Challenge",
                                 query_factory=get_online_challenges)

    team = QuerySelectField("Team",
                            query_factory=get_active_teams)

    bonus = IntegerField("Bonus", default=0)

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class MassMailForm(Form):
    from_ = TextField("From")

    subject = TextField("Subject")

    message = TextAreaField("Message")

    submit = SubmitField("Send")

    cancel = SubmitField("Cancel")
