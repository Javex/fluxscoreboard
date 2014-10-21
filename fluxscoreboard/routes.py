# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function


__doc__ = """
All routes of the application in a list. Each item consists of the route name
and its path in a tuple: ``(route_name, path)``. These are then mapped to a
view via the :class:`pyramid.view.view_config` decorator. See
:ref:`dev_routes` for an explanation of how to create routes and work with
them.
"""


routes = [('home', '/'),
          # Frontpage routes
          ('news', '/news'),
          ('challenges', '/challenges'),
          ('challenge', '/challenges/{id}'),
          ('scoreboard', '/scoreboard'),
          ('team_challenges', '/teams/{team_id}'),
          ('teams', '/teams'),
          ('ref', '/ref/{ref_id}'),
          ('verify_token', '/verify_token/{token}'),
          # User routes
          ('submit', '/submit'),
          ('logout', '/logout'),
          ('login', '/login'),
          ('register', '/register'),
          ('confirm', '/confirm/{token}'),
          ('profile', '/profile'),
          ('reset-password-start', '/reset-password'),
          ('reset-password', '/reset-password/{token}'),
          # Administration routes
          ('admin', '/admin'),
          ('admin_news', '/admin/news'),
          ('admin_news_edit', '/admin/news/edit'),
          ('admin_news_delete', '/admin/news/delete'),
          ('admin_news_toggle_status', '/admin/news/toggle-status'),
          ('admin_challenges', '/admin/challenges'),
          ('admin_challenges_edit', '/admin/challenges/edit'),
          ('admin_challenges_delete', '/admin/challenges/delete'),
          ('admin_challenges_toggle_status',
           '/admin/challenges/toggle-status'),
          ('admin_challenges_toggle_published',
           '/admin/challenges/toggle-published'),
          ('admin_categories', '/admin/categories'),
          ('admin_categories_edit', '/admin/categories/edit'),
          ('admin_categories_delete', '/admin/categories/delete'),
          ('admin_teams', '/admin/teams'),
          ('admin_teams_edit', '/admin/teams/edit'),
          ('admin_teams_delete', '/admin/teams/delete'),
          ('admin_teams_activate', '/admin/teams/activate'),
          ('admin_teams_toggle_local', '/admin/teams/toggle-local'),
          ('admin_teams_regenerate_token', '/admin/teams/regenerate'),
          ('admin_teams_cleanup', '/admin/teams/cleanup'),
          ('admin_teams_ips', '/admin/teams/ips'),
          ('admin_teams_resend_activation', '/admin/teams/resend-activation'),
          ('admin_ip_search', '/admin/ips'),
          ('admin_submissions', '/admin/submissions'),
          ('admin_submissions_edit', '/admin/submissions/edit'),
          ('admin_submissions_delete',
           '/admin/submissions/delete'),
          ('admin_massmail', '/admin/massmail'),
          ('admin_massmail_single', '/admin/massmail/{id}'),
          ('admin_settings', '/admin/settings'),
          ('test_login', '/admin/test-login'),
          ]
