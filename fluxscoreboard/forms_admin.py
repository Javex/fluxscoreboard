# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import required_validator, password_length_validator, \
    name_length_validator, email_length_validator
from fluxscoreboard.models.challenge import get_online_challenges, \
    get_all_challenges
from fluxscoreboard.models.country import get_all_countries
from fluxscoreboard.models.team import get_active_teams
from wtforms import validators
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from wtforms.fields.core import IntegerField, BooleanField
from wtforms.fields.html5 import EmailField
from wtforms.fields.simple import TextAreaField, SubmitField, HiddenField, \
    TextField, PasswordField
from wtforms.form import Form


def password_length_validator_conditional(form, field):
    if field.data:
        return password_length_validator(form, field)
    else:
        return True


class IntegerOrEvaluatedField(IntegerField):

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


class NewsForm(Form):
    message = TextAreaField("Message",
                            validators=[required_validator])

    published = BooleanField("Published")

    challenge = QuerySelectField("Challenge",
                                 query_factory=get_all_challenges,
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

    points = IntegerOrEvaluatedField("Points",
                          validators=[required_validator]
                          )

    published = BooleanField("Published")

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

    id = HiddenField(default=None)

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
