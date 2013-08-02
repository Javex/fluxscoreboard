fluxscoreboard README
=====================

To run the scoreboard you need to:

- Install a Python 2.7 virtualenv
- Run `python setup.py develop`
- Create a development.ini (see below)
- Start the development version with `pserve development.ini`
- Install the application with `python installer.py install`. You can also
  install test data if you want (just random strings). Then, instead, run
  `python installer.py install_test`

Then visit localhost:6543 and start testing the application (Note: It can send
real mails so make sure to enter **your** address).

Creating a development.ini
--------------------------

Issue `cp development.ini.example development.ini`, then start editing the
file, use the comments in it. Most settings are fairly self-explanatory. The
application is currently tailored to MySQL but should also run on Postgres at
the very least (though not tested). See comments to `sqlalchemy.url`.
