# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import CSRFForm
from fluxscoreboard.forms.fields import (IntegerOrEvaluatedField, ButtonWidget,
    team_size_field, TZDateTimeField)
from fluxscoreboard.forms.validators import (email_length_validator,
    password_length_validator_conditional, password_required_if_new,
    required_validator, name_length_validator, not_dynamic, only_if_dynamic,
    required_except, required_or_not_allowed, dynamic_check_multiple_allowed)
from fluxscoreboard.models import dynamic_challenges
from fluxscoreboard.models.challenge import (get_all_challenges,
    get_all_categories)
from fluxscoreboard.models.country import get_all_countries
from fluxscoreboard.models.team import get_all_teams
from wtforms import validators
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from wtforms.fields.core import BooleanField, SelectField
from wtforms.fields.html5 import EmailField, IntegerField
from wtforms.fields.simple import (TextAreaField, SubmitField, HiddenField,
    TextField, PasswordField)


def get_dynamic_module_choices():
    module_list = [(name, module.title())
                   for name, module in dynamic_challenges.registry.items()]
    return [('', '-- Not dynamic --')] + module_list


class NewsForm(CSRFForm):
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


class ChallengeForm(CSRFForm):
    """
    Form to add or edit a challenge.

    Attrs:
        ``title``: Title of the challenge. Required.

        ``text``: Description of the challenge. Required.

        ``solution``: Solution. Required.

        ``points``: How many points is this challenge worth? Only required if
        the challenge is not manual, otherwise not allowed to be anything other
        than 0 or empty.

        ``online``: If the challenge is online.

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
                         validators=[required_except(["dynamic"])]
                         )

    solution = TextField(
        "Solution",
        validators=[required_or_not_allowed(["manual", "dynamic"])])

    points = IntegerOrEvaluatedField(
        "Points",
        validators=[required_or_not_allowed(["manual", "dynamic"])])

    author = TextField("Author(s)")

    category = QuerySelectField("Category",
                                query_factory=get_all_categories,
                                allow_blank=False,
                                blank_text='-- Choose a category --')

    online = BooleanField("Online")

    manual = BooleanField("Manual Challenge", validators=[not_dynamic])

    dynamic = BooleanField(
        "Dynamic Challenge",
        description=("A dynamic challenge is a challenge that uses a custom "
                     "Python module for validation, which, of course, has to "
                     "be written separately. If you check this, you have to "
                     "select the corresponding module for this challenge "
                     "below. Also, you may NOT make it a manual challenge as "
                     "well!"))

    module = SelectField(
        "Dynamic Module",
        description=("Which module should be used for this dynamic challenge "
                     "(only relevant if dynamic is checked above), see above "
                     "for details."),
        choices=get_dynamic_module_choices(),
        validators=[only_if_dynamic, dynamic_check_multiple_allowed]
    )

    published = BooleanField(
        "Published",
        description=("An unpublished challenge will not be displayed in the "
                     "frontend."))

    has_token = BooleanField(
        "Has Token",
        description=("If this is active, the teams token will be displayed "
                     "below the challenge so they can provide it to the "
                     "challenge. A challenge can use it to identify teams. "
                     "Check docs for move info."))

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class CategoryForm(CSRFForm):
    """
    Form to add or edit a category.

    Attrs:
        ``name``: Title of the category. Required.

        ``id``: Track the id of the category.

        ``submit``: Save category.

        ``cancel``: Abort saving.
    """
    name = TextField("Name",
                      validators=[required_validator,
                                  validators.Length(max=255),
                                  ]
                      )

    id = HiddenField()

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class TeamForm(CSRFForm):
    """
    Form to add or edit a team. The same restrictions as on
    :class:`fluxscoreboard.forms.front.RegisterForm` apply.

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

    size = team_size_field()

    country = QuerySelectField("Country/State",
                               query_factory=get_all_countries
                               )

    active = BooleanField("Active")

    local = BooleanField("Local")

    id = HiddenField(default=None)

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class IPSearchForm(CSRFForm):
    """
    Form to search for an IP address and find the resulting team(s).
    """
    term = TextField("IP Address")

    submit = SubmitField("Search")


class SubmissionForm(CSRFForm):
    """
    Form to add or edit a submission of a team.

    Attrs:
        ``challenge``: The :class:`fluxscoreboard.models.challenge.Challenge`
        to be chosen from a list. Required.

        ``team``: The :class:`fluxscoreboard.models.team.Team` to be chosem
        from a list. Required.

        ``bonus``: How many bonus points the team gets. Defaults to 0.

        ``submit``: Save.

        ``cancel``: Abort.
    """
    challenge = QuerySelectField("Challenge",
                                 query_factory=get_all_challenges)

    team = QuerySelectField("Team",
                            query_factory=get_all_teams)

    bonus = IntegerField("Bonus", default=0)

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")


class MassMailForm(CSRFForm):
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


class ButtonForm(CSRFForm):
    """
    A form that gives a button and an ID. Useful for having a simple action
    that is identified in the forms ``action`` attribute. This provides
    CSRF support and the ability to POST submit commands such as edit or
    delete.
    """
    button = SubmitField(widget=ButtonWidget())
    id = HiddenField(validators=[required_validator])

    def __init__(self, formdata=None, obj=None, prefix='',
                 csrf_context=None, title=None, **kwargs):
        CSRFForm.__init__(self, formdata, obj, prefix, csrf_context, **kwargs)
        self.button.label.text = title


class SubmissionButtonForm(CSRFForm):
    """
    Special variant of :class:`ButtonForm` that is tailored for the composite
    primary key table ``submission``. Instead of having one ``id`` field it has
    one field ``challenge_id`` identifying the challenge and a field
    ``team_id`` identifiying the team.
    """
    button = SubmitField(widget=ButtonWidget())
    challenge_id = HiddenField(validators=[required_validator])
    team_id = HiddenField(validators=[required_validator])

    def __init__(self, formdata=None, obj=None, prefix='',
                 csrf_context=None, title=None, **kwargs):
        CSRFForm.__init__(self, formdata, obj, prefix, csrf_context, **kwargs)
        self.button.label.text = title


class TeamCleanupForm(CSRFForm):
    team_cleanup = SubmitField(widget=ButtonWidget())

    def __init__(self, formdata=None, obj=None, prefix='', csrf_context=None,
                 title=None, **kwargs):
        CSRFForm.__init__(self, formdata, obj, prefix, csrf_context, **kwargs)
        self.team_cleanup.label.text = title


class SettingsForm(CSRFForm):
    submission_disabled = BooleanField(
        "Submission disabled",
        description=("When submission is disabled, no more teams can submit "
                     "solutions to challenges until this is re-enabled. "
                     "Beyond that, the page stays alive.")
    )

    ctf_start_date = TZDateTimeField(
        "CTF Start Date",
        description=("When the CTF should start, in format "
                     "'%Y-%m-%d %H:%M:%S' and UTC timezone.")
    )

    ctf_end_date = TZDateTimeField(
        "CTF End Date",
        description=("When the CTF should end, in format "
                     "'%Y-%m-%d %H:%M:%S' and UTC timezone.")
    )

    archive_mode = BooleanField(
        "Archive Mode",
        description=("Put the scoreboard in archive mode, protecting it from "
                     "changes in the frontend and allowing public access. See "
                     "documentation for details.")
    )

    submit = SubmitField("Send")
