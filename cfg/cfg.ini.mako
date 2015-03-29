###
# app configuration
# http://docs.pylonsproject.org/projects/pyramid/en/latest/narr/environment.html
###

[app:main]
use = call:fluxscoreboard:main

#### YOUR CONFIGRATUION ####
#
# You have to make sure all settings here are correct
# Note: You might want to look at logging configuration as well.
#

# The domain on which the site runs
domain = localhost

# If the site should run in a subdirectory, set the name of the subroute you
# wish to use here.
#subdirectory =

# reCAPTCHA keys
recaptcha.public_key =
recaptcha.private_key =

# The domain to use for displaying the avatars. This should be different from
# the domain of the scoreboard for security reasons. You could for example just
# use the static IP which will be considered a different domain.
avatar_domain = http://127.0.0.1:6543

# external URL with the rules
rules_url = http://2014.hack.lu/index.php/CaptureTheFlag

# The title of your competition
competition_title = ${competition}

# Contact Details (for error messages and stuff)
contact_name = ${contact_name}
contact_mail = ${contact_mail}

# Type of the competition. This could be e.g. "CTF" or just generic "competition"
# This will be used in sentences like "This $competition does not start until..."
competition_type = ${competition_type}

# The CSP header values to set
% if mode == 'development':
csp_headers = default-src 'none'; connect-src 'self'; font-src 'self'; img-src 'self' www.google.com; script-src 'self' www.google.com 'sha256-dtX3Yk6nskFEtsDm1THZkJ4mIIohKJf5grz4nY6HxI8='; style-src 'self';
% else:
csp_headers = default-src 'none'; connect-src 'self'; font-src 'self'; img-src 'self' %(avatar_domain)s www.google.com; script-src 'self' www.google.com; style-src 'self';
% endif

# HSTS max-age setting
#hsts.max-age = 31536000


# Enter your database credentials here
db.user = ${db_user}
db.password = ${db_pass}
db.host = ${db_host}
db.port = ${db_port}
db.database = ${db_name}

# Enter SMTP mail settings for outgoing email messages
mail.host =
# The default port 465 is the default SMTP SSL port, for regular SMTP use 25.
mail.port = 465
mail.username =
mail.password =
# Deactivate this if you don't want to use SSL. Remember you might have to
# alter the port setting (to 25)
mail.ssl = True
# Enter here which address should be used as the default "From" for
# registration mails and other mail features
mail.default_sender =

# Choose a session type (or leave the default if you like it)

# General settings (these are used irregardless of the configuration)
# You only need to set a secret here (a random string with an entropy of about
# 128-256 Bit)
session.secret = ${session_secret}
session.lock_dir = %(here)s/../data/session/lock
session.key = session
session.cookie_on_exception = True
% if mode == 'production':
session.secure = True
session.cookie_domain = %(domain)s
% endif

# Default session: File
# Disable these two lines if you use another session
session.type = file
session.data_dir = %(here)s/../data/session/data

# A SQLALchemy session, based on the database settings above. Enable these if
# you want to have sessions in database as well (but remember to disable the
# default session).
#session.type = ext:database
#session.url = %(sqlalchemy.url)s


#### FURTHER CONFIGURATION ####
#
# You can alter these settings, but normally you don't need to - the applcation
# runs fine with the default values.
#

# Name of the application (the python package). Don't change!
app_name = fluxscoreboard

# The final database URL
# To use a different database type, swap out the "postgresql://" part for a
# different type. See
# http://docs.sqlalchemy.org/en/rel_0_8/core/engines.html#database-urls for
# details.
sqlalchemy.url = postgresql://%(db.user)s:%(db.password)s@%(db.host)s:%(db.port)s/%(db.database)s

# Template settings
mako.directories = %(app_name)s:templates

# Pyramid settings
pyramid.reload_templates = ${'true' if mode == 'development' else 'false'}
pyramid.debug_authorization = false
pyramid.debug_notfound = false
pyramid.debug_routematch = false
pyramid.default_locale_name = en
pyramid.includes =
    % if mode != 'production':
    pyramid_debugtoolbar
    % endif
    pyramid_tm
    pyramid_beaker
    pyramid_mako
    pyramid_mailer


# By default, the toolbar only appears for clients from IP addresses
# '127.0.0.1' and '::1'.
# debugtoolbar.hosts = 127.0.0.1 ::1


[alembic]
# path to migration scripts
script_location = alembic

# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s

# set to 'true' to run the environment during
# the 'revision' command, regardless of autogenerate
# revision_environment = false


###
# wsgi server configuration
###

[server:main]
% if mode == 'production':
use = egg:gunicorn#main
host = 127.0.0.1
port = 6875
workers = 8
#daemon = True
pidfile = tmp/fluxscoreboard.pid
user = http
group = http
error-logfile = log/gunicorn_error.log
access-logfile = log/gunicorn_access.log
% else:
use = egg:waitress#main
host = 0.0.0.0
port = 6543
% endif

###
# logging configuration
# http://docs.pylonsproject.org/projects/pyramid/en/latest/narr/logging.html
###

[loggers]
keys = root, fluxscoreboard, sqlalchemy, alembic

[handlers]
keys = console, file

[formatters]
keys = generic

[logger_root]
level = ${'WARN' if mode == 'production' else 'INFO'}
handlers = ${'console' if mode == 'development' else 'file'}

[logger_fluxscoreboard]
level = ${'WARN' if mode == 'production' else 'DEBUG'}
handlers =
qualname = fluxscoreboard

[logger_sqlalchemy]
level =  ${'INFO' if mode == 'test' else 'WARN'}
handlers =
qualname = sqlalchemy.engine
# "level = INFO" logs SQL queries.
# "level = DEBUG" logs SQL queries and results.
# "level = WARN" logs neither.  (Recommended for production systems.)

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[handler_file]
class = FileHandler
args = ('%(here)s/../log/scoreboard.log', 'w')
level = NOTSET
formatter = generic

[formatter_generic]
format = %(asctime)s %(levelname)-5.5s [%(name)s][%(threadName)s] %(message)s

% if mode == 'test':
[pytest]
markers =
    integration: integration tests. Sends Mail and has other side effects.
addopts = -m "not integration"
% endif
