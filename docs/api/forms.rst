:mod:`fluxscoreboard.forms`
---------------------------

Form classes exist to define, render and validate form submission. See
:ref:`dev_forms` for details.

Custom Fields
#############

.. automodule:: fluxscoreboard.forms

.. autoclass:: IntegerOrEvaluatedField

:mod:`fluxscreoboard.forms.front`
---------------------------------

Frontend Forms
##############

.. automodule:: fluxscoreboard.forms.front

.. autoclass:: RegisterForm


.. autoclass:: LoginForm

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

.. autoclass:: TeamForm

.. autoclass:: SubmissionForm

.. autoclass:: MassMailForm

:mod:`fluxscoreboard.forms.validators`
--------------------------------------

.. automodule:: fluxscoreboard.forms.validators

.. autofunction:: password_length_validator_conditional

.. autofunction:: password_required_if_new

.. todo::
    Document and include all the validators and stuff thats still missing here.
