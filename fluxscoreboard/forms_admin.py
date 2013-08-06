# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import required_validator, name_length_validator, \
    email_length_validator, password_min_length_validator, \
    password_max_length_validator
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


class NewsForm(Form):
    """
    Form to add or edit an announcement.

    Attrs:
        ``message``: The announcement message. Required.

        ``published``: Whether the announcement should be published. Required.

        ``challenge``: A list of challenges to choose from, alternatively a
        blank field with text "-- General Announcement --" to not assign it to
        a specific challenge.

        ``id``: Hidden field keeps track of challenge.

        ``submit``: Save the announcement to the database.

        ``cancel``: Do not save the announcement.
    """
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
    """
    Form to add or edit a challenge.

    Attrs:
        ``title``: Title of the challenge. Required.

        ``text``: Description of the challenge. Required.

        ``solution``: Solution. Required.

        ``points``: How many points is this challenge worth? Only required if
        the challenge is not manual, otherwise not allowed to be anything other
        than 0 or empty.

        ``published``: If the challenge is online.

        ``manual``: If the points for this challenge are given manually.

        ``id``: Track the id of the challenge.

        ``submit``: Save challenge.

        ``cancel``: Abort saving.
    """
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

    # TODO: This should not be required if manual is checked!
    points = IntegerOrEvaluatedField("Points",
                          validators=[required_validator]
                          )

    published = BooleanField("Published")

    manual = BooleanField("Manual Challenge")

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class TeamForm(Form):
    """
    Form to add or edit a team. The same restrictions as on
    :class:`fluxscoreboard.forms.RegisterForm` apply.

    Attrs:
        ``name``: The name of the name of the team. Required.

        ``password``: The team's password. Only required if the team is new.

        ``email``: E-Mail address. Required.

        ``country``: Location of team. Required.

        ``active``: If the team is active, i.e. able to log in.

        ``local``: If the team is local or remote.

        ``id``: Tracks the id of the team.

        ``submit``: Save the team.

        ``cancel``: Don't save.
    """
    name = TextField("Team Name",
                     validators=[required_validator,
                                 name_length_validator,
                                 ]
                     )

    password = PasswordField("Password",
                             validators=[password_length_validator_conditional,
                                         password_required_if_new,
                                         ]
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
    """
    Form to add or edit a submission of a team.

    Attrs:
        ``challenge``: The :class:`fluxscoreboard.models.challenge.Challenge`
        to be chosen from a list. Required.

        ``team``: The :class:`fluxscoreboard.models.team.team` to be chosem
        from a list. Required.

        ``bonus``: How many bonus points the team gets. Defaults to 0.

        ``submit``: Save.

        ``cancel``: Abort.
    """
    challenge = QuerySelectField("Challenge",
                                 query_factory=get_online_challenges)

    team = QuerySelectField("Team",
                            query_factory=get_active_teams)

    bonus = IntegerField("Bonus", default=0)

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class MassMailForm(Form):
    """
    A form to send a massmail to all users.

    Attrs:
        ``from_``: The sending address. Recommended to set it to
        ``settings["default_sender"]``, e.g.:

            .. code-block:: python

                if not form.from_.data:
                    settings = self.request.registry.settings
                    form.from_.data = settings["mail.default_sender"]

        ``subject``: A subject for the E-Mail.

        ``message``: A body for the E-Mail.

        ``submit``: Send the mail.

        ``cancel``: Don't send.

    """
    from_ = TextField("From")

    subject = TextField("Subject")

    message = TextAreaField("Message")

    submit = SubmitField("Send")

    cancel = SubmitField("Cancel")
