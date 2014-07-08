from setuptools import setup, find_packages
import os
import re


here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.md')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

version_file = os.path.join(os.path.dirname(__file__),
                            'fluxscoreboard',
                            '__init__.py')
v = open(version_file)
VERSION = re.compile(r".*__version__ = '(.*?)'", re.S).match(v.read()).group(1)
v.close()

requires = [
    'pyramid',  # WSGI framework
    'SQLAlchemy==0.8.6',  # Database
    'mysql-python',  # Database
    'zope.sqlalchemy',  # Database
    'transaction',  # Transactions
    'pyramid_tm',  # Transactions
    'pyramid_beaker',  # Sessions
    'beaker',  # Sessions
    'pyramid_mako',  # Templates
    'mako',  # Template
    'pyramid_mailer',  # Mail
    'webhelpers',  # Utility
    'py_bcrypt',  # Password storage
    'wtforms==1.0.5',  # Forms
    'pytz',  # Timezone
    'pyramid_debugtoolbar',  # Dev Server
    'waitress',  # Dev Server
    'pytest',  # Testing
    'webtest',  # Testing
    'requests',  # Download data (GeoIP)
    'alembic',  # Database migration
    ]

setup(name='fluxscoreboard',
      version=VERSION,
      description='fluxscoreboard',
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='',
      author_email='',
      url='',
      keywords='web wsgi bfg pylons pyramid',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      test_suite='fluxscoreboard',
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
      main = fluxscoreboard:main
      [console_scripts]
      initialize_fluxscoreboard_db = fluxscoreboard.scripts.initializedb:main
      """,
      )
