# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.forms import CSRFForm
from fluxscoreboard.forms.fields import AvatarField, BootstrapWidget
from fluxscoreboard.forms.validators import name_length_validator, \
    email_length_validator, password_min_length_validator, \
    password_max_length_validator, required_validator, email_equal_validator, \
    email_unique_validator, password_equal_validator, \
    password_required_and_valid_if_pw_change, password_min_length_if_set_validator, \
    password_max_length_if_set_validator, avatar_dimensions_validator, \
    avatar_size_validator
from fluxscoreboard.models.challenge import get_solvable_challenges
from fluxscoreboard.models.country import get_all_countries
from pytz import common_timezones, utc
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from wtforms.fields.core import SelectField
from wtforms.fields.html5 import EmailField, IntegerField
from wtforms.fields.simple import TextField, SubmitField, PasswordField


__doc__ = """
This module contains all forms for the frontend. Backend forms can be found
in :mod:`fluxscoreboard.forms.admin`. The forms here and there are described
as they should behave, e.g. "Save the challenge", however, this behaviour has
to be implemented by the developer and is not done automatically by it.
However, validatation restrictions (e.g. length) are enforced. But alone,
without a database to persist them, they are mostly useless.
"""


class RegisterForm(CSRFForm):
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
                           choices=([(utc.zone,
                                      '-- Please choose a timezone --')] +
                                    [(tz, tz) for tz in common_timezones]),
                           )

    size = IntegerField("Team Size")

    submit = SubmitField("Register")


class LoginForm(CSRFForm):
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


class ForgotPasswordForm(CSRFForm):
    """
    A form to get an email for a forgotten password.
    """
    email = EmailField("Team E-Mail", validators=[required_validator])

    submit = SubmitField("Send Reset E-Mail")


class ResetPasswordForm(CSRFForm):
    """
    A form to finish a started reset process.
    """
    password = PasswordField("New Password",
                             validators=[required_validator,
                                         password_equal_validator,
                                         password_min_length_validator,
                                         password_max_length_validator,
                                         ])

    password_repeat = PasswordField("Repeat New Password",
                                    validators=[required_validator])

    submit = SubmitField("Set New Password")


class ProfileForm(CSRFForm):
    """
    A form to edit a team's profile.

    Attrs:
        ``email``: The email address. Required

        ``old_password``: The old password, needed only for a password change.

        ``password``: The password. Optional, only needed if wanting to change.

        ``password_repeat``: Repeat the new password.

        ``avatar``: Display an avatar and upload a new one.

        ``country``: Change location. Required.

        ``timezone``: Change timezone. Required.

        ``submit``: Save changes

        ``cancel``: Abort
    """
    email = EmailField("Team E-Mail",
                       validators=[required_validator])

    old_password = PasswordField(
        "Old Password", validators=[password_required_and_valid_if_pw_change],
        description=("This only needs to be entered if you wish to change "
        "your password, otherwise, it is not required."),
    )

    password = PasswordField("New Password",
                             validators=[password_equal_validator,
                                         password_min_length_if_set_validator,
                                         password_max_length_if_set_validator,
                                         ]
                             )

    password_repeat = PasswordField("Repeat New Password")

    avatar = AvatarField("Avatar",
                       description=("Upload an avatar image. The File must "
                                    "not be larger than %d%s and must have "
                                    "maximum dimensions of %dx%dpx"
                                    % (avatar_size_validator.max_size,
                                       avatar_size_validator.unit,
                                       avatar_dimensions_validator.max_width,
                                       avatar_dimensions_validator.max_height)
                                    ),
                         validators=[avatar_dimensions_validator,
                                     avatar_size_validator],
                         )

    country = QuerySelectField("Country/State",
                               query_factory=get_all_countries
                               )

    timezone = SelectField("Timezone",
                           choices=[(tz, tz) for tz in common_timezones],
                           default=((utc.zone, utc.zone)),
                           )

    size = IntegerField("Team Size",
                        description=("For statistical purposes we would "
                                     "like to know how many you are. "
                                     "There is no limitation on the number "
                                     "of people each team may bring, we "
                                     "just like to know the sizes of "
                                     "teams."),
                        widget=BootstrapWidget(
                            'number',
                            group_after=['Members'],
                            default_classes=['text-right'])
                        )

    submit = SubmitField("Save")

    cancel = SubmitField("Cancel")

    def __init__(self, formdata=None, obj=None, prefix='', csrf_context=None,
                 **kwargs):
        if obj is None:
            raise ValueError("Must always provide an existing team")
        CSRFForm.__init__(self, formdata, obj, prefix, csrf_context, **kwargs)


class SolutionSubmitForm(CSRFForm):
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
                                 query_factory=get_solvable_challenges,
                                 )
