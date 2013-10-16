# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.challenge import Submission, Challenge, Category
from fluxscoreboard.util import bcrypt_split, encrypt_pw, random_token
from pyramid.renderers import render
from pyramid.security import unauthenticated_userid
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from pytz import utc, timezone, all_timezones
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.orm import relationship
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql.expression import func, desc
from sqlalchemy.types import Integer, Unicode, Boolean
import logging
import os
import random
import string
from pyramid.decorator import reify


log = logging.getLogger(__name__)


TEAM_NAME_MAX_LENGTH = 255
TEAM_MAIL_MAX_LENGTH = 255
TEAM_PASSWORD_MAX_LENGTH = 60


TEAM_GROUPS = ['group:team']
"""Groups are just fixed: If a team is logged in it belongs to these groups."""


def groupfinder(userid, request):
    """
    Check if there is a team logged in, and if it is, return the default
    :data:`TEAM_GROUPS`.
    """
    if get_team(request):
        return TEAM_GROUPS


def get_all_teams():
    """
    Get a query that returns a list of all teams.
    """
    return DBSession().query(Team)


def get_active_teams():
    """
    Get a query that returns a list of all active teams.
    """
    return DBSession().query(Team).filter(Team.active == True)


def get_leading_team():
    actives = get_active_teams()
    score = desc(get_score_subquery())
    return actives.order_by(score)[0]


def get_team_solved_subquery(team_id):
    """
    Get a query that searches for a submission from a team for a given
    challenge. The challenge is supposed to come from an outer query.

    Example usage:
        .. code-block:: python

            team_solved_subquery = get_team_solved_subquery(team_id)
            challenge_query = (dbsession.query(Challenge,
                                               team_solved_subquery.exists()))

    In this example we query for a list of all challenges and additionally
    fetch whether the currenttly logged in team has solved it.
    """
    # This subquery basically searches for whether the current team has
    # solved the corresponding challenge. The correlate statement is
    # a SQLAlchemy statement that tells it to use the **outer** challenge
    # column.
    team_solved_subquery = (DBSession().query(Submission).
                            filter(Submission.team_id == team_id).
                            filter(Challenge.id ==
                                   Submission.challenge_id).
                            correlate(Challenge))
    return team_solved_subquery


def get_number_solved_subquery():
    """
    Get a subquery that returns how many teams have solved a challenge.

    Example usage:

        .. code-block:: python

            number_of_solved_subquery = get_number_solved_subquery()
            challenge_query = (dbsession.query(Challenge,
                                               number_of_solved_subquery)

    Here we query for a list of all challenges and additionally fetch the
    number of times it has been solved. This subquery will use the outer
    challenge to correlate on, so make sure to provide one or this query
    makes no sense.
    """
    return (DBSession().query(func.count('*')).
            filter(Challenge.id == Submission.challenge_id).
            correlate(Challenge).
            as_scalar())


def get_score_subquery():
    from ..models import dynamic_challenges
    dbsession = DBSession()
    # Calculate sum of all points, defalt to 0
    challenge_sum = func.coalesce(func.sum(Challenge._points), 0)
    # Calculate sum of all bonus points, default to 0
    bonus_sum = func.coalesce(func.sum(Submission.bonus), 0)
    points_col = challenge_sum + bonus_sum
    for module in dynamic_challenges.registry.values():
        points_col += module.points_query()
    # Create a subquery for the sum of the above points. The filters
    # basically join the columns and the correlation is needed to reference
    # the **outer** Team query.
    team_score_subquery = (dbsession.query(points_col).
                           filter(Challenge.id == Submission.challenge_id).
                           filter(Team.id == Submission.team_id).
                           filter(~Challenge.dynamic).
                           correlate(Team))
    return team_score_subquery.as_scalar()


def get_team(request):
    """
    Get the currently logged in team. Fetches the team from the database
    only once, then stores it in the request.
    """
    if not hasattr(request, 'team'):
        dbsession = DBSession()
        team_id = unauthenticated_userid(request)
        try:
            team = (dbsession.query(Team).
                    filter(Team.id == team_id).
                    filter(Team.active == True).one())
            request.team = team
        except NoResultFound:
            request.team = None
    return request.team


def register_team(form, request):
    """
    Create a new team from a form and send a confirmation email.

    Args:
        ``form``: A filled out :class:`fluxscoreboard.forms.front.RegisterForm`.

        ``request``: The corresponding request.

    Returns:
        The :class:`Team` that was created.
    """
    team = Team(name=form.name.data,
                email=form.email.data,
                password=form.password.data,
                country=form.country.data,
                timezone=form.timezone.data,
                size=form.size.data,
                )
    dbsession = DBSession()
    dbsession.add(team)
    mailer = get_mailer(request)
    message = Message(subject="Your hack.lu 2013 CTF Registration",
                      recipients=[team.email],
                      html=render('mail_register.mako',
                                  {'team': team},
                                  request=request,
                                  )
                      )
    mailer.send(message)
    return team


def confirm_registration(token):
    """
    For a token, check the database for the corresponding team and activate it
    if found.

    Args:
        ``token``: The token that was sent to the user (a string)

    Returns:
        Either ``True`` or ``False`` depending on whether the confirmation was
        successful.
    """
    if token is None:
        return False
    try:
        team = DBSession().query(Team).filter(Team.token == token).one()
    except NoResultFound:
        return False
    team.active = True
    return True


def login(email, password):
    """
    Check a combination of credentials for validaity and either return a
    reason why it failed or return the logged in team.

    Args:
        ``email``: The email address of the team.

        ``password``: The corresponding password.

    Returns:
        A three-tuple of ``(result, message, team)``. ``result`` indicates
        whether the login was successful or not. In case of failure ``msg``
        contains a reason why it failed so it can be logged (but **not**
        printed - we don't want to give any angle to an attacker). If the
        login was successful, ``msg`` is ``None``. Finally, if the login
        succeeded, ``team`` contains the found instance of :class:`Team`. If
        login failed, ``team`` is ``None``.
    """
    try:
        team = (DBSession().
                query(Team).
                filter(Team.email == email).
                one())
    except NoResultFound:
        return False, "Team not found", None
    if not team.validate_password(password):
        return False, "Invalid password", None
    if not team.active:
        return False, "Team not activated yet", None
    return True, None, team


def password_reminder(email, request):
    """
    For an email address, find the corresponding team and send a password
    reset token. If no team is found send an email that no user was found for
    this address.
    """
    dbsession = DBSession()
    mailer = get_mailer(request)
    team = dbsession.query(Team).filter(Team.email == email).first()
    if team:
        # send mail with reset token
        team.reset_token = random_token()
        html = render('mail_password_reset_valid.mako', {'team': team},
                      request=request)
        recipients = [team.email]
    else:
        # send mail with information that no team was found for that address.
        html = render('mail_password_reset_invalid.mako', {'email': email},
                      request=request)
        recipients = [email]
    message = Message(subject="Password Reset for Hack.lu 2013",
                      recipients=recipients,
                      html=html,
                      )
    mailer.send(message)
    return team


def check_password_reset_token(token):
    """
    Check if an entered password reset token actually exists in the database.
    """
    dbsession = DBSession()
    team = (dbsession.query(Team).
            filter(Team.reset_token == token).first())
    return team


def get_team_by_ref(ref_id):
    return (DBSession().query(Team).
            # options(subqueryload(Team.flags)).
            filter(Team.ref_token == ref_id).one())


def ref_token():
    """
    Create a ``ref`` token (a random string of 15 letters or digits) for usage
    with the ref feature.
    """
    keyspace = string.letters + string.digits
    return "".join(random.choice(keyspace) for __ in xrange(15))


class Team(Base):
    """
    A team represented in the database.

    Attributes:
        ``id``: Primary key

        ``name``: The name of the team.

        ``password``: The password of the team. If setting the password, pass
        it as cleartext. It will automatically be encrypted and stored in the
        database.

        ``email``: E-Mail address of the team. Verified if team is ``active``.

        ``country_id``: Foreign Key specifying the location of the team.

        ``local``: Whether the team is local at the conference.

        ``token``: Token for E-Mail verification.

        ``reset_token``: When requesting a new password, this token is used.

        ``ref_token``: When using the ``ref`` feature, this token is used.

        ``active``: Whether the team's mail address has been verified and the
        team can actively log in.

        ``timezone``: A timezone, specified as a string, like
        ``"Europe/Berlin"`` or something that, when coerced to unicode, turns
        out as a string like this. Must be valid timezone.

        ``acatar_filename``: The filename under which the avatar is stored
        in the ``static/images/avatars`` directory.

        ``size``: The size of the team.

        ``flags``: A list of countries from which the team already visited.
        See :mod:`fluxscoreboard.models.dynamic_challenges.flags` for more
        information on this feature.

        .. todo::
            Update this once ``flags`` is a ``set``.

        ``country``: Direct access to the teams
        :class:`fluxscoreboard.models.country.Country` attribute.
    """
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(TEAM_NAME_MAX_LENGTH), nullable=False, unique=True)
    _password = Column('password', Unicode(TEAM_PASSWORD_MAX_LENGTH),
                       nullable=False)
    email = Column(Unicode(TEAM_MAIL_MAX_LENGTH), nullable=False, unique=True)
    country_id = Column(Integer, ForeignKey('country.id'), nullable=False)
    local = Column(Boolean, default=False)
    token = Column(Unicode(64), nullable=False, unique=True)
    reset_token = Column(Unicode(64), unique=True)
    ref_token = Column(Unicode(15), nullable=False, default=ref_token,
                       unique=True)
    active = Column(Boolean, default=False)
    # TODO: Timezone as seperate type
    _timezone = Column('timezone', Unicode(30),
                       default=lambda: unicode(utc.zone),
                       nullable=False)
    avatar_filename = Column(Unicode(68), unique=True)
    size = Column(Integer)

    # TODO: Make it a set (and update TeamFlags docs)
    flags = association_proxy("team_flags", "flag")

    country = relationship("Country", lazy='joined')

    def __init__(self, *args, **kwargs):
        kwargs.setdefault("token", random_token())
        Base.__init__(self, *args, **kwargs)

    def __str__(self):
        return unicode(self).encode("utf-8")

    def __unicode__(self):
        return self.name

    def __repr__(self):
        return (('<Team name=%s, email=%s, local=%s, active=%s>'
                % (self.name, self.email, self.local, self.active)).
                encode("utf-8"))

    def validate_password(self, password):
        """
        Validate the password agains the team. If it matches return ``True``
        else return ``False``.
        """
        salt, __ = bcrypt_split(self.password)
        reference_pw = encrypt_pw(password, salt)
        if self.password != reference_pw:
            return False
        else:
            return True

    @property
    def password(self):
        return self._password

    @password.setter
    def password(self, pw):
        self._password = encrypt_pw(pw)

    @property
    def timezone(self):
        if self._timezone is None:
            return None
        else:
            return timezone(self._timezone)

    @timezone.setter
    def timezone(self, tz):
        timezone = unicode(tz)
        assert timezone in all_timezones
        self._timezone = timezone

    def get_category_solved(self, category):
        cat_solved, total = self.stats.get(category, (0, 0))
        if total == 0:
            return 0
        else:
            return float(cat_solved) / total

    def get_overall_stats(self):
        done, total = self.stats["_overall"]
        if total == 0:
            return 0
        else:
            return float(done) / total

    @reify
    def stats(self):
        _stats = {}
        team_stats = dict(DBSession().query(Category.name, func.count('*')).
                          select_from(Submission).join(Challenge).
                          outerjoin(Challenge.category).
                          filter(Submission.team_id == self.id).
                          group_by(Category.name))
        totals = dict(DBSession().query(Category.name, func.count('*')).
                      select_from(Challenge).outerjoin(Challenge.category).
                      group_by(Category.name))
        for name, total in totals.items():
            _stats[name] = (team_stats.get(name, 0), total)
        overall_stats = [0, 0]
        for team_stat, total in _stats.values():
            overall_stats[0] += team_stat
            overall_stats[1] += total
        _stats["_overall"] = tuple(overall_stats)
        return _stats

    @property
    def rank(self):
        # TODO: Make more efficient
        score = get_score_subquery()
        teams = (DBSession().query(Team).order_by(desc(score)))
        for rank, team in enumerate(teams, 1):
            if team.id == self.id:
                return rank
        else:
            raise ValueError("Team not found!")
