# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.challenge import Submission, Challenge
from fluxscoreboard.models.team import (get_team_solved_subquery, get_team,
    groupfinder, get_all_teams, get_active_teams, get_number_solved_subquery,
    register_team, confirm_registration, login, password_reminder,
    check_password_reset_token, get_team_by_ref, ref_token, Team,
    get_leading_team)
from fluxscoreboard.util import random_token
from pyramid_mailer import get_mailer
from pytz import timezone, utc
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.orm.exc import NoResultFound
import pytest
import transaction


def test_groupfinder(make_team):
    class A(object):
        pass
    request = A()
    request.team = make_team()
    assert groupfinder(None, request) == ['group:team']
    assert groupfinder(None, A()) is None


def test_get_all_teams(make_team, dbsession):
    t1 = make_team()
    t2 = make_team(active=True)
    teams = [t1, t2]
    dbsession.add_all(teams)
    q = get_all_teams()
    assert q.count() == 2
    assert set(q.all()) == set(teams)


def test_get_active_teams(make_team, dbsession):
    t1 = make_team(active=True)
    t2 = make_team()
    dbsession.add_all([t1, t2])
    q = get_active_teams()
    assert q.count() == 1
    assert q.first() == t1


def test_get_leading_team(make_team, make_challenge, dbsession):
    t1 = make_team(active=True)
    t2 = make_team(active=True)
    c1 = make_challenge(points=200)
    c2 = make_challenge(points=100)
    dbsession.add_all([t1, t2, c1, c2])
    Submission(challenge=c1, team=t1, bonus=1)
    Submission(challenge=c1, team=t2)
    assert get_leading_team() is t1


def test_get_leading_team_none():
    assert get_leading_team() is None


def test_get_team_solved_subquery(make_team, dbsession, make_challenge):
    t = make_team()
    c1 = make_challenge()
    c2 = make_challenge()
    s1 = Submission(challenge=c1, team=t)
    dbsession.add_all([s1, c2])
    dbsession.flush()
    query = get_team_solved_subquery(t.id)
    assert query.count() == 1
    subm = query.first()
    assert subm == s1
    assert subm.challenge == c1
    assert subm.team == t


def test_get_number_solved_subquery(make_team, dbsession, make_challenge):
    c = make_challenge()
    t = make_team()
    s = Submission(challenge=c, team=t)
    dbsession.add(s)
    q = (dbsession.query(Challenge, get_number_solved_subquery()))
    chall, count = q.first()
    assert c is chall
    assert count == 1


def test_get_team(login_team, dbsession, make_team, pyramid_request):
    t = make_team(active=True)
    dbsession.add(t)
    dbsession.flush()
    login_team(t.id)
    team = get_team(pyramid_request)
    assert team is t
    assert pyramid_request.team is t


def test_get_team_hasattr(make_team):
    class A(object):
        pass
    request = A()
    request.team = make_team()
    assert get_team(request) is request.team


def test_register_team(pyramid_request, dbsession, countries, config, mailer):
    class A(object):
        pass
    form = A()
    for field in ['name', 'email', 'password', 'country', 'timezone', 'size']:
        setattr(form, field, A())
    form.name.data = "test1"
    form.email.data = "test1@example.com"
    form.password.data = "test123"
    form.country.data = countries[0]
    form.timezone.data = timezone("Europe/Berlin")
    form.size.data = 10
    team = register_team(form, pyramid_request)
    assert team.name == "test1"
    assert team.email == "test1@example.com"
    assert team.password != "test123"
    assert len(team.password) == 60
    assert team.country == countries[0]
    assert team.timezone == timezone("Europe/Berlin")
    assert team.size == 10
    assert len(mailer.outbox) == 1
    mail = mailer.outbox[0]
    assert mail.subject == "Your hack.lu 2013 CTF Registration"
    assert mail.recipients == ["test1@example.com"]


def test_confirm_registration(dbsession, make_team):
    t = make_team()
    dbsession.add(t)
    assert not t.active
    assert confirm_registration(t.token)
    assert t.active


def test_confirm_registration_no_team():
    assert not confirm_registration("A" * 20)


def test_confirm_registration_no_token():
    assert not confirm_registration(None)


def test_login(make_team, dbsession):
    t = make_team(active=True)
    dbsession.add(t)
    res, msg, team = login("team0@example.com", "Password0")
    assert res
    assert msg is None
    assert team == t


def test_login_no_team(make_team, dbsession):
    t = make_team()
    dbsession.add(t)
    res, msg, team = login("teamX@example.com", None)
    assert not res
    assert msg == "Team not found"
    assert team is None


def test_login_invalid_pw(make_team, dbsession):
    t = make_team()
    dbsession.add(t)
    res, msg, team = login("team0@example.com", "PasswordX")
    assert not res
    assert msg == "Invalid password"
    assert team is None


def test_login_inactive(make_team, dbsession):
    t = make_team()
    dbsession.add(t)
    res, msg, team = login("team0@example.com", "Password0")
    assert not res
    assert msg == "Team not activated yet"
    assert team is None


def test_password_reminder(make_team, dbsession, pyramid_request, config,
                           mailer):
    t = make_team()
    dbsession.add(t)
    assert t.reset_token is None
    assert password_reminder("team0@example.com", pyramid_request) == t
    assert len(t.reset_token) == 64
    assert len(mailer.outbox) == 1
    mail = mailer.outbox[0]
    assert mail.subject == "Password Reset for Hack.lu 2013"
    assert mail.recipients == ["team0@example.com"]
    assert "You have requested to reset your password." in mail.html


def test_password_reminer_wrong_mail(make_team, dbsession, pyramid_request,
                                     config, mailer):
    t = make_team()
    dbsession.add(t)
    assert t.reset_token is None
    assert password_reminder("team1@example.com", pyramid_request) is None
    assert t.reset_token is None
    assert len(mailer.outbox) == 1
    mail = mailer.outbox[0]
    assert mail.subject == "Password Reset for Hack.lu 2013"
    assert mail.recipients == ["team1@example.com"]
    assert "but we have no team for this address in our database" in mail.html


def test_check_password_reset_token(make_team, dbsession):
    t = make_team()
    t.reset_token = random_token()
    dbsession.add(t)
    team = check_password_reset_token(t.reset_token)
    assert team == t


def test_check_password_reset_token_invalid():
    team = check_password_reset_token("A" * 64)
    assert team is None


def test_get_team_by_ref(make_team, dbsession):
    t = make_team()
    dbsession.add(t)
    dbsession.flush()
    assert get_team_by_ref(t.ref_token) == t


def test_get_team_by_ref_notfound():
    with pytest.raises(NoResultFound):
        get_team_by_ref("A" * 12)


def test_ref_token():
    assert len(ref_token()) == 15


class TestTeam(object):

    def test_defaults(self, make_team, dbsession):
        t = make_team()
        dbsession.add(t)
        assert t.local is None
        assert t.ref_token is None
        assert t.active is None
        assert t._timezone is None
        dbsession.flush()
        assert t.local is False
        assert len(t.ref_token) == 15
        assert t.active is False
        assert t._timezone == "UTC"
        assert t.timezone is utc

    def test_nullables(self, make_team, dbsession, nullable_exc):
        teams = []
        for param in  ["name", "_password", "email", "country_id"]:
            team = make_team()
            setattr(team, param, None)
            teams.append(team)
        for team in teams:
            trans = dbsession.begin_nested()
            with pytest.raises(nullable_exc):
                dbsession.add(team)
                dbsession.flush()
            trans.rollback()

    def test_init(self):
        t = Team()
        assert len(t.token) == 64
        t = Team(name="test")
        assert t.name == "test"
        with pytest.raises(TypeError):
            t = Team(bla="foo")

    # Test printable representations
    def test_print(self):
        t = Team(name="Täst")
        assert unicode(t) == "Täst"
        assert isinstance(unicode(t), unicode)
        assert str(t) == b"Täst"
        assert isinstance(str(t), str)
        repr_ = repr(t)
        assert isinstance(repr_, str)
        assert repr_ == (b"<Team name=Täst, email=None, local=None, "
                         b"active=None>")

    def test_validate_password(self):
        t = Team(password="Test123")
        assert t.password
        assert t.validate_password("Test123")
        assert not t.validate_password("Test12")
        assert not t.validate_password("Test123 ")
        assert not t.validate_password("Test12 3")
        assert not t.validate_password(" Test123")
        assert not t.validate_password("test123")

    def test_timezone(self):
        t = Team()
        assert t.timezone is None
        assert t._timezone is None
        t.timezone = timezone("Europe/Paris")
        assert t._timezone == "Europe/Paris"
        assert t.timezone == timezone("Europe/Paris")
        t._timezone = "Europe/Berlin"
        assert t.timezone == timezone("Europe/Berlin")
        with pytest.raises(AssertionError):
            t.timezone = "Invalid/Timezone"

    def test_submissions(self, make_team, make_challenge, dbsession):
        t = make_team()
        s = Submission(team=t, challenge=make_challenge())
        dbsession.add(s)
        assert t.submissions == [s]

    def test_flags(self, make_team, make_teamflag, dbsession):
        t = make_team()
        f = make_teamflag(team=t)
        dbsession.add(f)
        assert t.flags == ["zw"]

    def test_team_flags(self, make_team, make_teamflag, dbsession):
        t = make_team()
        f = make_teamflag(team=t)
        dbsession.add(f)
        assert t.team_flags == [f]

    def test_score_no_chall(self, make_team, dbsession):
        t = make_team()
        dbsession.add(t)
        assert t.score == 0

        t_ref, score = dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 0

    def test_score(self, make_team, dbsession, make_challenge):
        t = make_team()
        c = make_challenge(points=100)
        dbsession.add_all([t, c])
        Submission(challenge=c, team=t)
        assert t.score == 100

        t_ref, score = dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 100

    def test_score_bonus(self, make_team, make_challenge, dbsession):
        t = make_team()
        c = make_challenge()
        dbsession.add_all([t, c])
        Submission(challenge=c, team=t, bonus=3)
        assert t.score == 3

        t_ref, score = dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 3

    def test_score_flags(self, make_team, make_challenge, make_teamflag,
                         dbsession):
        t = make_team()
        c = make_challenge(dynamic=True, module_name='flags')
        dbsession.add_all([t, c])
        make_teamflag(team=t)
        assert t.score == 1

        t_ref, score = dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 1

        for _ in range(10):
            make_teamflag(team=t)
        assert t.score == 11

        t_ref, score = dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 11

    def test_rank(self, make_team, make_challenge, dbsession):
        t1 = make_team()
        t2 = make_team()
        c1 = make_challenge(points=100)
        dbsession.add_all([t1, t2, c1])
        Submission(challenge=c1, team=t1)
        Submission(challenge=c1, team=t2, bonus=3)
        assert t1.rank == 2
        assert t2.rank == 1

        team_list = dbsession.query(Team.name, Team.rank).order_by(Team.id).all()
        assert len(team_list) == 2
        t1_ref, t1_rank = team_list[0]
        t2_ref, t2_rank = team_list[1]
        assert t1_ref == "Team0"
        assert t2_ref == "Team1"
        assert t1_rank == 2
        assert t2_rank == 1

