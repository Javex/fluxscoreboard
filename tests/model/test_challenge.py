# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.models import dynamic_challenges
from fluxscoreboard.models.challenge import (get_all_challenges,
    get_online_challenges, Submission, 
    get_submissions, Category, get_all_categories,
    check_submission, manual_challenge_points, Challenge)
from fluxscoreboard.models.news import News
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.util import now
from sqlalchemy.exc import IntegrityError, DatabaseError
import pytest


@pytest.fixture
def ctf_end_date(dbsettings):
    dbsettings.ctf_end_date = now() + timedelta(1)


class TestChallengeQueries(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession):
        self.dbsession = dbsession

    @pytest.fixture
    def all_in_db(self, all_challenges):
        self.dbsession.add_all(all_challenges)

    def test_get_all_challenges(self, all_in_db):
        assert len(get_all_challenges().all()) == 6

    def test_get_online_challenges(self, all_in_db):
        assert len(get_online_challenges().all()) == 3

    def test_get_submissions(self, make_team, make_challenge):
        c = make_challenge()
        t = make_team()
        s = Submission(challenge=c, team=t)
        self.dbsession.add(s)

        query = get_submissions()
        assert query.count() == 1
        assert query[0] == s

    def test_get_all_categories(self):
        cat = Category(name="Test")
        self.dbsession.add(cat)
        q = get_all_categories()
        assert q.count() == 1
        assert q[0] == cat


class TestSubmission(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, dbsettings, make_challenge, make_team,
                 ctf_end_date):
        self.dbsession = dbsession
        self.dbsettings = dbsettings
        self.make_team = make_team
        self.make_challenge = make_challenge
        self.ctf_end_date = ctf_end_date

    def test_check_submission(self):
        c = self.make_challenge(online=True, solution="Test")
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        result, msg = check_submission(c, "Test", t.id, self.dbsettings)
        assert result is True
        assert msg == 'Congratulations: You solved this challenge as first!'
        assert len(c.submissions) == 1
        assert len(t.submissions) == 1

    def test_check_submission_places(self):
        c = self.make_challenge(online=True, solution="Test")
        teams = [self.make_team() for _ in range(4)]
        self.dbsession.add_all(teams + [c])
        self.dbsession.flush()
        msgs = ['Congratulations: You solved this challenge as first!',
                'Congratulations: You solved this challenge as second!',
                'Congratulations: You solved this challenge as third!',
                'Congratulations: That was the correct solution!']
        for i in range(4):
            result, msg = check_submission(c, "Test", teams[i].id, self.dbsettings)
            assert result is True
            assert msg == msgs[i]
            assert len(c.submissions) == i + 1
            assert len(teams[i].submissions) == 1

    def test_check_submission_disabled(self):
        result, msg = check_submission(None, None, None,
                                       Settings(submission_disabled=True))
        assert result is False
        assert msg == "Submission is currently disabled"

    def test_check_submission_offline(self):
        result, msg = check_submission(self.make_challenge(), None, None, self.dbsettings)
        assert result is False
        assert msg == "Challenge is offline."

    def test_check_submission_incorrect_solution(self):
        c = self.make_challenge(solution="Test", online=True)
        result, msg = check_submission(c, "Test ", None, self.dbsettings)
        assert result is False
        assert msg == "Solution incorrect."

    def test_check_submission_manual(self):
        c = self.make_challenge(solution="Test", manual=True, online=True)
        result, msg = check_submission(c, "Test", None, self.dbsettings)
        assert result is False
        assert msg == "Credits for this challenge will be given manually."

    def test_check_submission_dynamic(self):
        c = self.make_challenge(solution="Test", dynamic=True, online=True)
        result, msg = check_submission(c, "Test", None, self.dbsettings)
        assert result is False
        assert msg == "The challenge is dynamic, no submission possible."

    def test_check_submission_already_solved(self):
        c = self.make_challenge(solution="Test", online=True)
        t = self.make_team()
        s = Submission(team=t, challenge=c)
        dbsession.add(s)
        dbsession.flush()
        result, msg = check_submission(c, "Test", t.id, self.dbsettings)
        assert result is False
        assert msg == "Already solved."

    def test_check_submission_ctf_over():
        self.dbsettings.ctf_end_date = now() - timedelta(1)
        result, msg = check_submission(None, None, None, self.dbsettings)
        assert result is False
        assert msg == "The CTF is over, no more solutions can be submitted."


class TestManualChallengePoints(object):

    def test_printable(self):
        assert isinstance(unicode(manual_challenge_points), unicode)
        assert isinstance(str(manual_challenge_points), str)
        assert isinstance(repr(manual_challenge_points), str)


class TestChallenge(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_challenge, make_team):
        self.dbsession = dbsession
        self.make_challenge = make_challenge
        self.make_team = make_team

    def test_defaults(self):
        c = self.make_challenge()
        self.dbsession.add(c)
        assert c.id is None
        assert c._points is None
        assert c.online is None
        assert c.manual is None
        assert c.dynamic is None
        assert c.has_token is None
        self.dbsession.flush()
        assert c.id
        assert c._points == 0
        assert c.online is False
        assert c.manual is False
        assert c.dynamic is False
        assert c.has_token is False

    def test_nullables(self, nullable_exc):
        c = Challenge()
        t = self.dbsession.begin_nested()
        self.dbsession.add(c)
        try:
            with pytest.raises(DatabaseError):
                self.dbsession.flush()
        except Exception as e:
            print(e, type(e), "hi")
            raise
        t.rollback()

        for param in ['online', 'manual', 'dynamic', 'has_token', 'published']:
            t = self.dbsession.begin_nested()
            c = self.make_challenge()
            self.dbsession.add(c)
            self.dbsession.flush()
            setattr(c, param, None)
            with pytest.raises(nullable_exc):
                self.dbsession.flush()
            t.rollback()

    def test_printables(self):
        c = self.make_challenge()
        self.dbsession.add(c)
        self.dbsession.flush()

        assert isinstance(str(c), str)
        assert str(c) == b"Challenge0"
        assert isinstance(unicode(c), unicode)
        assert unicode(c) == "Challenge0"

        r = repr(c)
        assert r == "<Challenge (normal) title=Challenge0, online=False>"

        c = self.make_challenge(manual=True, category=Category(name="Test"),
                                author="test1, test2", online=True)
        self.dbsession.add(c)
        self.dbsession.flush()
        r = repr(c)
        assert r == ("<Challenge (manual) title=Challenge1, online=True, "
                     "category=Test, author(s)=test1, test2>")

        c = self.make_challenge(dynamic=True, module="flags")
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        r = repr(c)
        assert r == ("<Challenge (dynamic) title=Challenge2, online=False, "
                     "module=flags>")

    def test_points(self):
        c = self.make_challenge(points=123)
        assert c.points == 123
        c.points = 321
        assert c.points == 321

    def test_points_manual(self):
        c = self.make_challenge(manual=True)
        c.points = 123
        assert c.points is manual_challenge_points
        c.points = 321
        assert c.points is manual_challenge_points

    def test_module(self):
        c = self.make_challenge()
        assert c.module is None
        c.module= "flags"
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        assert c.module is dynamic_challenges.flags

    def test_announcements(self):
        c = self.make_challenge()
        self.dbsession.add(c)
        self.dbsession.flush()
        n1 = News(challenge=c, timestamp=datetime(2012, 1, 1))
        n2 = News(challenge=c)
        assert c.announcements == [n2, n1]

    def test_category(self):
        c = self.make_challenge()
        cat = Category()
        cat.challenges.append(c)
        assert c.category == cat

    def test_not_manual_and_dynamic(self):
        c = self.make_challenge(manual=True, dynamic=True)
        self.dbsession.add(c)
        with pytest.raises(ValueError):
            self.dbsession.flush()

    def test_submissions(self):
        c = self.make_challenge()
        s = Submission(team=self.make_team(), challenge=c)
        self.dbsession.add(s)
        assert c.submissions == [s]


class TestCategory(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_challenge):
        self.dbsession = dbsession
        self.make_challenge = make_challenge

    def test_defaults(self):
        cat = Category(name="Täst")
        assert cat.id is None
        self.dbsession.add(cat)
        self.dbsession.flush()
        assert cat.id

    def test_nullables(self, nullable_exc):
        cat = Category()
        t = self.dbsession.begin_nested()
        self.dbsession.add(cat)
        with pytest.raises(nullable_exc):
            self.dbsession.flush()
        t.rollback()
        cat = Category(name="Test")
        self.dbsession.add(cat)
        self.dbsession.flush()

    def test_printables(self):
        cat = Category(name="Täst")
        assert isinstance(str(cat), str)
        assert str(cat) == b"Täst"
        assert isinstance(unicode(cat), unicode)
        assert unicode(cat) == "Täst"
        assert isinstance(repr(cat), str)
        assert repr(cat) == b"<Category id=None, name=Täst, challenges=0>"

    def test_challenge(self):
        cat = Category(name="Test")
        chal = self.make_challenge(category=cat)
        self.dbsession.add(chal)
        assert cat.challenges == [chal]


class TestSubmission(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_team, make_challenge):
        self.dbsession = dbsession
        self.make_team = make_team
        self.make_challenge = make_challenge

    def test_defaults(self):
        s = Submission(team=self.make_team(), challenge=self.make_challenge())
        assert s.bonus is None
        self.dbsession.add(s)
        self.dbsession.flush()
        assert s.bonus == 0

    def test_nullables(self, nullable_exc):
        fails = [Submission(),
                 Submission(team=self.make_team()),
                 Submission(challenge=self.make_challenge())]
        for subm in fails:
            trans = self.dbsession.begin_nested()
            self.dbsession.add(subm)
            with pytest.raises(IntegrityError):
                self.dbsession.flush()
            trans.rollback()

        for param in ['bonus', 'timestamp']:
            trans = self.dbsession.begin_nested()
            s = Submission(team=self.make_team(), challenge=self.make_challenge())
            self.dbsession.add(s)
            self.dbsession.flush()
            setattr(s, param, None)
            with pytest.raises(nullable_exc):
                self.dbsession.flush()
            trans.rollback()

    def test_printable(self):
        s = Submission(challenge=self.make_challenge(), team=self.make_team(),
                       timestamp=datetime(2012, 1, 1))
        self.dbsession.add(s)
        self.dbsession.flush()
        repr_ = repr(s)
        assert isinstance(repr_, str)
        assert repr_ == ("<Submission challenge=Challenge0, team=Team0, "
                         "bonus=0, timestamp=2012-01-01 00:00:00>")

    def test_team(self):
        t = self.make_team()
        s = Submission(challenge=self.make_challenge())
        t.submissions.append(s)
        assert s.team == t
        self.dbsession.add(t)
        self.dbsession.flush()
        assert s.team == t

    def test_challenge(self):
        c = self.make_challenge()
        s = Submission(team=self.make_team())
        c.submissions.append(s)
        assert s.challenge == c
        self.dbsession.add(c)
        self.dbsession.flush()
        assert s.challenge == c
