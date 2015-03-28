:mod:`fluxscoreboard.forms`
---------------------------

Form classes exist to define, render and validate form submission. See
:ref:`dev_forms` for details.

Custom Forms
#############

.. automodule:: fluxscoreboard.forms

.. autoclass:: CSRFForm

:mod:`fluxscreoboard.forms.front`
---------------------------------

Frontend Forms
##############

.. automodule:: fluxscoreboard.forms.front

.. autoclass:: RegisterForm

.. autoclass:: LoginForm

.. autoclass:: ForgotPasswordForm

.. autoclass:: ResetPasswordForm

.. autoclass:: ProfileForm

.. autoclass:: SolutionSubmitForm

.. autoclass:: SolutionSubmitListForm

.. autoclass:: FeedbackForm

:mod:`fluxscoreboard.forms.admin`
---------------------------------

.. automodule:: fluxscoreboard.forms.admin

.. autoclass:: NewsForm

.. autoclass:: ChallengeForm

.. autoclass:: CategoryForm

.. autoclass:: TeamForm

.. autoclass:: IPSearchForm

.. autoclass:: SubmissionForm

.. autoclass:: MassMailForm

.. autoclass:: ButtonForm

.. autoclass:: SubmissionButtonForm

.. autoclass:: TeamCleanupForm

.. autoclass:: SettingsForm

:mod:`fluxscoreboard.forms._validators`
---------------------------------------

.. automodule:: fluxscoreboard.forms._validators

.. autofunction:: email_unique_validator

.. autofunction:: name_unique_validator

.. autofunction:: greater_zero_if_set

.. autofunction:: password_length_validator_conditional

.. autofunction:: password_required_if_new

.. autofunction:: password_required_and_valid_if_pw_change

.. autofunction:: password_max_length_if_set_validator

.. autofunction:: password_min_length_if_set_validator

.. autofunction:: required_or_not_allowed

.. autofunction:: required_except

.. autofunction:: not_dynamic

.. autofunction:: only_if_dynamic

.. autofunction:: dynamic_check_multiple_allowed

.. autoclass:: AvatarSize

.. autoclass:: RecaptchaValidator

:mod:`fluxscoreboard.forms._fields`
-----------------------------------

.. automodule:: fluxscoreboard.forms._fields

.. autoclass:: AvatarWidget

.. autoclass:: AvatarField

.. autoclass:: ButtonWidget

.. autoclass:: IntegerOrEvaluatedField

.. autoclass:: IntegerOrNoneField

.. autoclass:: BootstrapWidget

.. autofunction:: team_size_field

.. autoclass:: RecaptchaWidget

.. autoclass:: RecaptchaField

.. autoclass:: TZDateTimeField
