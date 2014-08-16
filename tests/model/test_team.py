# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.challenge import Submission, Challenge
from fluxscoreboard.models.team import (get_team_solved_subquery, get_team,
    groupfinder, get_all_teams, get_active_teams, get_number_solved_subquery,
    register_team, confirm_registration, login, password_reminder,
    check_password_reset_token, get_team_by_ref, ref_token, Team)
from fluxscoreboard.util import random_token
from pyramid.httpexceptions import HTTPFound
from pytz import timezone, utc
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.exc import StatementError
import pytest
import re
from mock import MagicMock


def test_groupfinder(make_team):
    request = MagicMock()
    request.team = make_team()
    assert groupfinder(None, request) == ['group:team']
    request = MagicMock()
    request.team = None
    assert groupfinder(None, request) is None


class TestTeamQueries(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_team, dbsession, make_challenge):
        self.dbsession = dbsession
        self.make_team = make_team
        self.make_challenge = make_challenge

    def test_get_all_teams(self):
        t1 = self.make_team()
        t2 = self.make_team(active=True)
        teams = [t1, t2]
        self.dbsession.add_all(teams)
        q = get_all_teams()
        assert q.count() == 2
        assert set(q.all()) == set(teams)

    def test_get_active_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team()
        self.dbsession.add_all([t1, t2])
        q = get_active_teams()
        assert q.count() == 1
        assert q.first() == t1

    def test_get_team_solved_subquery(self):
        t = self.make_team()
        c1 = self.make_challenge()
        c2 = self.make_challenge()
        s1 = Submission(challenge=c1, team=t)
        self.dbsession.add_all([s1, c2])
        self.dbsession.flush()
        query = get_team_solved_subquery(t.id)
        query = self.dbsession.query(query)
        assert query.count() == 1
        exists, = query.first()
        assert exists

    def test_get_number_solved_subquery(self):
        c = self.make_challenge()
        t = self.make_team()
        s = Submission(challenge=c, team=t)
        self.dbsession.add(s)
        q = (self.dbsession.query(Challenge, get_number_solved_subquery()))
        chall, count = q.first()
        assert c is chall
        assert count == 1


class TestGetTeam(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, login_team, dbsession, make_team, pyramid_request, dbsettings):
        self._login = login_team
        self.dbsession = dbsession
        self.make_team = make_team
        self.request = pyramid_request
        self.dbsettings = dbsettings
        self._team = None

    @property
    def team(self):
        if self._team is None:
            self._team = self.make_team(active=True)
            self.dbsession.add(self._team)
            self.dbsession.flush()
        return self._team

    def login(self, team=None):
        if team is None:
            team = self.team
        self._login(team.id)

    def test_get_team(self):
        self.login()
        team = get_team(self.request)
        assert team is not None
        assert team is self.team

    def test_get_team_inactive(self):
        t = self.make_team(active=False)
        self.dbsession.add(t)
        self.dbsession.flush()
        self.login(t)
        team = get_team(self.request)
        assert team is None

    def test_get_team_none(self):
        assert get_team(self.request) is None

    def test_get_team_archive_mode(self):
        self.dbsettings.archive_mode = True
        assert get_team(self.request) is None

    def test_get_team_archive_mode_logged_in(self):
        self.login()
        self.dbsettings.archive_mode = True
        assert self.request.unauthenticated_userid is not None
        assert get_team(self.request) is None
        assert self.request.unauthenticated_userid is None


class TestFuncs(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, login_team, dbsession, make_team, pyramid_request,
                 dbsettings, config, mailer, countries):
        self._login = login_team
        self.dbsession = dbsession
        self.make_team = make_team
        self.request = pyramid_request
        self.dbsettings = dbsettings
        self.mailer = mailer
        self.countries = countries

    def test_register_team(self):
        form = MagicMock()
        for field in ['name', 'email', 'password', 'country', 'timezone', 'size']:
            setattr(form, field, MagicMock())
        form.name.data = "test1"
        form.email.data = "test1@example.com"
        form.password.data = "test123"
        form.country.data = self.countries[0]
        form.timezone.data = timezone("Europe/Berlin")
        form.size.data = 10
        team = register_team(form, self.request)
        assert team.name == "test1"
        assert team.email == "test1@example.com"
        assert team.password != "test123"
        assert len(team.password) == 60
        assert team.country == self.countries[0]
        assert team.timezone == timezone("Europe/Berlin")
        assert team.size == 10
        assert len(self.mailer.outbox) == 1
        mail = self.mailer.outbox[0]
        assert re.match(r"Your hack.lu \d{4} CTF Registration", mail.subject)
        assert mail.recipients == ["test1@example.com"]

    def test_confirm_registration(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        assert not t.active
        assert confirm_registration(t.token)
        assert t.active
        assert not t.token

    def test_confirm_registration_no_team(self):
        assert not confirm_registration("A" * 20)

    def test_confirm_registration_no_token(self):
        assert not confirm_registration(None)

    def test_login(self):
        t = self.make_team(active=True)
        self.dbsession.add(t)
        res, msg, team = login("team0@example.com", "Password0")
        assert res
        assert msg is None
        assert team == t

    def test_login_no_team(self):
        t = self.make_team()
        self.dbsession.add(t)
        res, msg, team = login("teamX@example.com", None)
        assert not res
        assert msg == "Team not found"
        assert team is None

    def test_login_invalid_pw(self):
        t = self.make_team()
        self.dbsession.add(t)
        res, msg, team = login("team0@example.com", "PasswordX")
        assert not res
        assert msg == "Invalid password"
        assert team is None

    def test_login_inactive(self):
        t = self.make_team()
        self.dbsession.add(t)
        res, msg, team = login("team0@example.com", "Password0")
        assert not res
        assert msg == "Team not activated yet"
        assert team is None

    def test_password_reminder(self):
        t = self.make_team()
        self.dbsession.add(t)
        assert t.reset_token is None
        assert password_reminder("team0@example.com", self.request) == t
        assert len(t.reset_token) == 64
        assert len(self.mailer.outbox) == 1
        mail = self.mailer.outbox[0]
        assert re.match(r"Password Reset for hack.lu CTF \d{4}", mail.subject)
        assert mail.recipients == ["team0@example.com"]
        assert "You have requested to reset your password." in mail.html

    def test_password_reminer_wrong_mail(self):
        t = self.make_team()
        self.dbsession.add(t)
        assert t.reset_token is None
        assert password_reminder("team1@example.com", self.request) is None
        assert t.reset_token is None
        assert len(self.mailer.outbox) == 1
        mail = self.mailer.outbox[0]
        assert re.match(r"Password Reset for hack.lu CTF \d{4}", mail.subject)
        assert mail.recipients == ["team1@example.com"]
        assert "but we have no team for this address in our database" in mail.html

    def test_check_password_reset_token(self):
        t = self.make_team()
        t.reset_token = random_token()
        self.dbsession.add(t)
        team = check_password_reset_token(t.reset_token)
        assert team == t

    def test_check_password_reset_token_invalid(self):
        team = check_password_reset_token("A" * 64)
        assert team is None

    def test_get_team_by_ref(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        assert get_team_by_ref(t.ref_token) == t

    def test_get_team_by_ref_notfound(self):
        with pytest.raises(NoResultFound):
            get_team_by_ref("A" * 12)

    def test_ref_token(self):
        assert len(ref_token()) == 15


class TestTeam(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_team, make_challenge, make_teamflag):
        self.dbsession = dbsession
        self.make_team = make_team
        self.make_challenge = make_challenge
        self.make_teamflag = make_teamflag

    def test_defaults(self):
        t = self.make_team()
        self.dbsession.add(t)
        assert t.local is None
        assert t.ref_token is None
        assert t.active is None
        assert t.timezone is None
        self.dbsession.flush()
        assert t.local is False
        assert len(t.ref_token) == 15
        assert t.active is False
        assert t.timezone is utc

    @pytest.mark.usefixtures("config")
    def test_nullables(self, nullable_exc):
        teams = []
        for param in  ["name", "_password", "email", "country_id"]:
            team = self.make_team()
            setattr(team, param, None)
            teams.append(team)
        for team in teams:
            trans = self.dbsession.begin_nested()
            with pytest.raises(nullable_exc):
                self.dbsession.add(team)
                self.dbsession.flush()
            trans.rollback()

    def test_init(self):
        t = self.make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        assert len(t.token) == 64
        t = Team(name="test")
        assert t.name == "test"
        with pytest.raises(TypeError):
            t = Team(bla="foo")

    # Test printable representations
    def test_print(self):
        t = self.make_team(name="Täst")
        assert unicode(t) == "Täst"
        assert isinstance(unicode(t), unicode)
        assert str(t) == b"Täst"
        assert isinstance(str(t), str)
        repr_ = repr(t)
        assert isinstance(repr_, str)
        assert repr_ == (b"<Team name=Täst, email=team0@example.com, "
                         b"local=None, active=None>")

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
        t = self.make_team()
        self.dbsession.add(t)
        assert t.timezone is None
        t.timezone = timezone("Europe/Paris")
        assert t.timezone == timezone("Europe/Paris")
        t.timezone = "Europe/Berlin"
        self.dbsession.flush()
        self.dbsession.expire(t)
        assert t.timezone == timezone("Europe/Berlin")

        t.timezone = "Invalid/Timezone"
        with pytest.raises(StatementError):
            self.dbsession.flush()

    def test_submissions(self):
        t = self.make_team()
        s = Submission(team=t, challenge=self.make_challenge())
        self.dbsession.add(s)
        assert t.submissions == [s]

    def test_flags(self):
        t = self.make_team()
        f = self.make_teamflag(team=t)
        self.dbsession.add(f)
        assert t.flags == ["zw"]

    def test_team_flags(self):
        t = self.make_team()
        f = self.make_teamflag(team=t)
        self.dbsession.add(f)
        assert t.team_flags == [f]

    def test_score_no_chall(self):
        t = self.make_team()
        self.dbsession.add(t)
        assert t.score == 0

        t_ref, score = self.dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 0

    def test_score(self):
        t = self.make_team()
        c = self.make_challenge(points=100, published=True)
        self.dbsession.add_all([t, c])
        Submission(challenge=c, team=t)
        assert t.score == 100

        t_ref, score = self.dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 100

    def test_score_bonus(self):
        t = self.make_team()
        c = self.make_challenge(published=True)
        self.dbsession.add_all([t, c])
        Submission(challenge=c, team=t, bonus=3)
        assert t.score == 3

        t_ref, score = self.dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 3

    def test_score_flags(self):
        t = self.make_team()
        c = self.make_challenge(dynamic=True, module='flags')
        self.dbsession.add_all([t, c])
        c = self.dbsession.query(Challenge).one()
        t = self.dbsession.query(Team).one()
        self.make_teamflag(team=t)
        assert t.score == 1
        
        self.dbsession.flush()
        self.dbsession.expire(c)
        t_ref, score = self.dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 1
        t._score = None

        for _ in range(10):
            self.make_teamflag(team=t)
        assert t.score == 11
        t._score = None

        t_ref, score = self.dbsession.query(Team, Team.score).first()
        assert t_ref is t
        assert score == 11

    def test_rank(self):
        t1 = self.make_team()
        t2 = self.make_team()
        t3 = self.make_team()
        t4 = self.make_team()
        c1 = self.make_challenge(points=100, published=True)
        self.dbsession.add_all([t1, t2, t3, t4, c1])
        Submission(challenge=c1, team=t1)
        Submission(challenge=c1, team=t2, bonus=3)
        Submission(challenge=c1, team=t3)
        assert t1.rank == 2
        assert t2.rank == 1
        assert t3.rank == 2
        assert t4.rank == 4

        team_list = self.dbsession.query(Team, Team.rank).order_by(Team.id).all()
        assert len(team_list) == 4
        t1_ref, t1_rank = team_list[0]
        t2_ref, t2_rank = team_list[1]
        t3_ref, t3_rank = team_list[2]
        t4_ref, t4_rank = team_list[3]
        assert t1_ref is t1
        assert t2_ref is t2
        assert t3_ref is t3
        assert t4_ref is t4
        assert t1_rank == 2
        assert t2_rank == 1
        assert t3_rank == 2
        assert t4_rank == 4

    def test_rank_dynamic(self):
        t1 = self.make_team()
        t2 = self.make_team()
        c = self.make_challenge(dynamic=True, module='flags')
        self.make_teamflag(team=t1)
        self.dbsession.add_all([t1, t2, c])
        assert t1.rank == 1
        assert t2.rank == 2

        team_list = self.dbsession.query(Team, Team.rank).order_by(Team.id).all()
        t1_ref, t1_rank = team_list[0]
        t2_ref, t2_rank = team_list[1]
        assert t1_ref is t1
        assert t2_ref is t2
        assert t1_rank == 1
        assert t2_rank == 2

    def test_get_unsolved_challenges(self):
        t1 = self.make_team()
        c1 = self.make_challenge(online=True)
        s1 = Submission(challenge=c1, team=t1)
        c2 = self.make_challenge(online=True)
        self.dbsession.add_all([s1, c2])
        self.dbsession.flush()
        unsolved = t1.get_unsolved_challenges()
        assert unsolved.count() == 1
        assert unsolved[0] == c2

    def test_get_solvable_challenges(self):
        t = self.make_team()
        c1 = self.make_challenge(online=True, published=True)
        c2 = self.make_challenge(online=True, manual=True, published=True)
        c3 = self.make_challenge(online=True, published=True)
        s = Submission(challenge=c1, team=t)
        self.dbsession.add_all([s, c2, c3])
        self.dbsession.flush()
        query = t.get_solvable_challenges()
        assert query.count() == 1
        assert query[0] == c3
