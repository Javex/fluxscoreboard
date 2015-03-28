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

.. autoclass:: Feedback
    :members:

.. autofunction:: get_all_challenges

.. autofunction:: get_online_challenges

.. autofunction:: get_submissions

.. autofunction:: get_all_categories

.. autofunction:: check_submission

.. autodata:: manual_challenge_points

.. autofunction:: update_playing_teams

.. autofunction:: update_challenge_points

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

.. autofunction:: get_published_news

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

.. autofunction:: get_team_by_id

.. autofunction:: register_team

.. autofunction:: send_activation_mail

.. autofunction:: confirm_registration

.. autofunction:: login

.. autofunction:: password_reminder

.. autofunction:: check_password_reset_token

.. autodata:: TEAM_GROUPS

.. autofunction:: groupfinder

.. autoclass:: TeamIP

.. autofunction:: update_score

Settings Models & Functions
###########################

.. automodule:: fluxscoreboard.models.settings

.. autoclass:: Settings
    :members:

Custom Column Types
###################

.. automodule:: fluxscoreboard.models.types

.. autoclass:: TZDateTime

.. autoclass:: Timezone

.. autoclass:: Module
