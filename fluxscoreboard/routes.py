# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function

routes = [('home', '/'),
          # Frontpage routes
          ('news', '/news'),
          ('challenges', '/challenges'),
          ('challenge', '/challenges/{id}'),
          ('scoreboard', '/scoreboard'),
          # User routes
          ('submit', '/submit'),
          ('logout', '/logout'),
          ('login', '/login'),
          ('register', '/register'),
          ('confirm', '/confirm/{token}'),
          ('profile', '/profile'),
          # Administration routes
          ('admin', '/admin'),
          ('admin_news', '/admin/news'),
          ('admin_news_edit', '/admin/news/{id}'),
          ('admin_news_delete', '/admin/news/delete/{id}'),
          ('admin_news_toggle_status', '/admin/news/toggle-status/{id}'),
          ('admin_challenges', '/admin/challenges'),
          ('admin_challenges_edit', '/admin/challenges/{id}'),
          ('admin_challenges_delete', '/admin/challenges/delete/{id}'),
          ('admin_challenges_toggle_status',
           '/admin/challenges/toggle-status/{id}'),
          ('admin_teams', '/admin/teams'),
          ('admin_teams_edit', '/admin/teams/{id}'),
          ('admin_teams_delete', '/admin/teams/delete/{id}'),
          ('admin_teams_activate', '/admin/teams/activate/{id}'),
          ('admin_teams_toggle_local', '/admin/teams/toggle-local/{id}'),
          ('admin_submissions', '/admin/submissions'),
          ('admin_submissions_edit', '/admin/submissions/{cid}/{tid}'),
          ('admin_submissions_delete',
           '/admin/submissions/delete/{cid}/{tid}'),
          ('admin_massmail', '/admin/massmail'),
          ('admin_massmail_single', '/admin/massmail/{id}'),
          ]
