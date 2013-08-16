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

:mod:`fluxscoreboard.forms.admin`
---------------------------------

Administrative Forms
####################

.. automodule:: fluxscoreboard.forms.admin

.. autoclass:: NewsForm

.. autoclass:: ChallengeForm

.. autoclass:: CategoryForm

.. autoclass:: TeamForm

.. autoclass:: SubmissionForm

.. autoclass:: MassMailForm

.. autoclass:: ButtonForm

.. autoclass:: SubmissionButtonForm

:mod:`fluxscoreboard.forms.validators`
--------------------------------------

.. automodule:: fluxscoreboard.forms.validators

.. autofunction:: email_unique_validator

.. autofunction:: password_length_validator_conditional

.. autofunction:: password_required_if_new

.. autofunction:: password_required_and_valid_if_pw_change

.. autofunction:: password_max_length_if_set_validator

.. autofunction:: password_min_length_if_set_validator

.. autofunction:: required_or_manual

.. autoclass:: AvatarDimensions

.. autoclass:: AvatarSize

.. todo::
    Document and include all the validators and stuff thats still missing here.

:mod:`fluxscoreboard.forms.fields`
----------------------------------

.. automodule:: fluxscoreboard.forms.fields

.. autoclass:: AvatarWidget

.. autoclass:: AvatarField

.. autoclass:: ButtonWidget

.. autoclass:: IntegerOrEvaluatedField
