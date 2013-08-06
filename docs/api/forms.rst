:mod:`fluxscoreboard.forms`
---------------------------

Form classes exist to define, render and validate form submission. See
:ref:`dev_forms` for details.

Frontend Forms
##############

.. automodule:: fluxscoreboard.forms

.. autoclass:: RegisterForm


.. autoclass:: LoginForm

.. autoclass:: ProfileForm

.. autoclass:: SolutionSubmitForm

.. autoclass:: SolutionSubmitListForm

.. todo::
    Document and include all the validators and stuff thats still missing here.


:mod:`fluxscoreboard.forms_admin`
---------------------------------

Administrative Forms
####################

.. automodule:: fluxscoreboard.forms_admin

.. autoclass:: NewsForm

.. autoclass:: ChallengeForm

.. autoclass:: TeamForm

.. autoclass:: SubmissionForm

.. autoclass:: MassMailForm


Validators & Fields
###################

.. autofunction:: password_length_validator_conditional

.. autofunction:: password_required_if_new

.. autoclass:: IntegerOrEvaluatedField
