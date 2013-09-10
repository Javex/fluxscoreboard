:mod:`fluxscoreboard.models`
----------------------------

.. automodule:: fluxscoreboard.models
    :members:

Challenge Models & Functions
############################

.. automodule:: fluxscoreboard.models.challenge

.. autoclass:: Challenge
    :members:

.. autoclass:: Category
    :members:

.. autoclass:: Submission
    :members:

.. autofunction:: get_all_challenges

.. autofunction:: get_online_challenges

.. autofunction:: get_unsolved_challenges

.. autofunction:: get_solvable_challenges

.. autofunction:: get_submissions

.. autofunction:: get_all_categories

.. autofunction:: check_submission

.. autodata:: manual_challenge_points

Country Models & Functions
##########################

.. automodule:: fluxscoreboard.models.country

.. autoclass:: Country
    :members:

.. autofunction:: get_all_countries

News Models & Functions
#######################

.. automodule:: fluxscoreboard.models.news

.. autoclass:: News
    :members:

.. autoclass:: MassMail
    :members:

Team Models & Functions
#######################

.. automodule:: fluxscoreboard.models.team

.. autoclass:: Team
    :members:

.. autofunction:: get_all_teams

.. autofunction:: get_active_teams

.. autofunction:: get_team_solved_subquery

.. autofunction:: get_number_solved_subquery

.. autofunction:: get_team

.. autofunction:: register_team

.. autofunction:: confirm_registration

.. autofunction:: login

.. autofunction:: password_reminder

.. autofunction:: check_password_reset_token

.. autodata:: TEAM_GROUPS

.. autofunction:: groupfinder

Settings Models & Functions
###########################

.. automodule:: fluxscoreboard.models.settings

.. autoclass:: Settings
    :members:

.. autofunction:: get

Custom Column Types
###################

.. automodule:: fluxscoreboard.models.types

.. autoclass:: TZDateTime

.. autoclass:: JSONList
