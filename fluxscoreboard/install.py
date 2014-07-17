# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import (DBSession, Base, Challenge, News, Submission,
    Team, Country, MassMail, Category, dynamic_challenges)
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.util import random_str
import json
import logging
import random
import transaction
from alembic.config import Config
from alembic import command

__doc__ = """
Installation module that provides the application with mechanisms for
installing and uninstalling the application. Also useful for testing.

"""


log = logging.getLogger(__name__)


def install(settings, cfg_file, test_data=False):
    """
    Installs the application. Only required to be called once per installation.
    """
    dbsession = DBSession()
    transaction.begin()
    try:
        install_alembic_table(cfg_file)
        Base.metadata.create_all(bind=dbsession.connection())
        create_country_list(dbsession)
        if test_data:
            install_test_data(dbsession, settings)
        if not dbsession.query(Settings).all():
            dbsession.add(Settings())
        for dyn_mod in dynamic_challenges.registry.values():
            dyn_mod.install(dbsession.connection())
    except:
        transaction.abort()
        raise
    else:
        transaction.commit()


def install_alembic_table(configuration_file):
    config = Config(file_=configuration_file, ini_section="alembic")
    command.stamp(config, "head")


def install_test_data(dbsession, settings):
    countries = dbsession.query(Country).all()
    # Teams
    teams = []
    for __ in xrange(30):
        team = Team(name=random_str(10),
                    email="%s@%s.%s" % (random_str(10),
                                        random_str(7),
                                        random_str(3)
                                        ),
                    password=random_str(10),
                    country=random.choice(countries),
                    local=random.choice([False, True]),
                    active=random.choice([True, True, False]),
                    )
        teams.append(team)
    dbsession.add_all(teams)

    # Categories
    categories = []
    for __ in xrange(5):
        cat = Category(name=random_str(10))
        categories.append(cat)
    dbsession.add_all(categories)

    # Challenges
    challenges = []
    for __ in xrange(27):
        if random.randint(0, 100) < 80:
            cat = random.choice(categories)
        else:
            cat = None
        challenge = Challenge(title=random_str(10),
                              text=random_str(50),
                              solution=random_str(10),
                              _points=random.randint(1, 1000),
                              online=random.choice([True, True, False]),
                              manual=(True if random.randint(0, 100) < 90
                                      else False),
                              category=cat,
                              )
        challenges.append(challenge)
    dbsession.add_all(challenges)

    # News
    announcements = []
    for __ in xrange(10):
        news = News(message=random_str(100),
                    published=(True if random.randint(0, 100) < 90
                               else False),
                    challenge=random.choice([None] + challenges))
        announcements.append(news)
    dbsession.add_all(announcements)

    # Submissions
    submissions = []
    for challenge in challenges:
        for team in teams:
            if random.randint(0, 100) < 30:
                continue
            submission = Submission(bonus=0)
            submission.team = team
            submission.challenge = challenge
            submissions.append(submission)
    dbsession.add_all(submissions)

    # Mass Mails (dont really send!)
    mails = []
    recipients = [team.email for team in teams]
    for __ in xrange(10):
        mail = MassMail(subject=random_str(10),
                        message=random_str(100),
                        recipients=recipients,
                        from_=unicode(settings["mail.default_sender"]),
                        )
        mails.append(mail)
    dbsession.add_all(mails)


def create_country_list(dbsession):
    if not dbsession.query(Country).all():
        with open("states.json") as f:
            country_names = [item["name"] for item in json.load(f)]
        for name in country_names:
            assert isinstance(name, unicode)
        countries = [Country(name=name) for name in country_names]
        dbsession.add_all(countries)
        return countries


def uninstall(settings):
    """
    Remove those parts created by install
    """
    Base.metadata.drop_all(bind=DBSession.connection())
    transaction.commit()
