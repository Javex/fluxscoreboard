# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime
from fluxscoreboard.models import dynamic_challenges
from fluxscoreboard.models.challenge import get_all_challenges, \
    get_online_challenges, Submission, get_unsolved_challenges, \
    get_solvable_challenges, get_submissions, Category, get_all_categories, \
    check_submission, manual_challenge_points, Challenge
from fluxscoreboard.models.news import News
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.util import now
from datetime import timedelta
from sqlalchemy.exc import IntegrityError, DatabaseError
import pytest


@pytest.fixture
def ctf_end_date(dbsettings):
    dbsettings.ctf_end_date = now() + timedelta(1)


def test_get_all_challenges(all_challenges, dbsession):
    dbsession.add_all(all_challenges)
    assert len(get_all_challenges().all()) == 6


def test_get_online_challenges(all_challenges, dbsession):
    dbsession.add_all(all_challenges)
    assert len(get_online_challenges().all()) == 3


def test_get_unsolved_challenges(dbsession, make_team, make_challenge):
    t1 = make_team()
    c1 = make_challenge(online=True)
    s1 = Submission(challenge=c1, team=t1)
    c2 = make_challenge(online=True)
    dbsession.add_all([s1, c2])
    dbsession.flush()
    unsolved = get_unsolved_challenges(t1.id)
    assert unsolved.count() == 1
    assert unsolved[0] == c2


def test_get_solvable_challenges(dbsession, make_team, make_challenge):
    t = make_team()
    c1 = make_challenge(online=True)
    c2 = make_challenge(online=True, manual=True)
    c3 = make_challenge(online=True)
    s = Submission(challenge=c1, team=t)
    dbsession.add_all([s, c2, c3])
    dbsession.flush()
    query = get_solvable_challenges(t.id)
    assert query.count() == 1
    assert query[0] == c3


def test_get_submissions(dbsession, make_team, make_challenge):
    c = make_challenge()
    t = make_team()
    s = Submission(challenge=c, team=t)
    dbsession.add(s)

    query = get_submissions()
    assert query.count() == 1
    assert query[0] == s


def test_get_all_categories(dbsession):
    cat = Category(name="Test")
    dbsession.add(cat)
    q = get_all_categories()
    assert q.count() == 1
    assert q[0] == cat


def test_check_submission(dbsession, make_team, make_challenge, dbsettings,
                          ctf_end_date):
    c = make_challenge(online=True, solution="Test")
    t = make_team()
    dbsession.add_all([c, t])
    dbsession.flush()
    result, msg = check_submission(c, "Test", t.id, dbsettings)
    assert result is True
    assert msg == 'Congratulations: You solved this challenge as first!'
    assert len(c.submissions) == 1
    assert len(t.submissions) == 1


def test_check_submission_places(dbsession, make_team, make_challenge,
                                 dbsettings, ctf_end_date):
    c = make_challenge(online=True, solution="Test")
    teams = [make_team() for _ in range(4)]
    dbsession.add_all(teams + [c])
    dbsession.flush()
    msgs = ['Congratulations: You solved this challenge as first!',
            'Congratulations: You solved this challenge as second!',
            'Congratulations: You solved this challenge as third!',
            'Congratulations: That was the correct solution!']
    for i in range(4):
        result, msg = check_submission(c, "Test", teams[i].id, dbsettings)
        assert result is True
        assert msg == msgs[i]
        assert len(c.submissions) == i + 1
        assert len(teams[i].submissions) == 1


def test_check_submission_disabled():
    result, msg = check_submission(None, None, None,
                                   Settings(submission_disabled=True))
    assert result is False
    assert msg == "Submission is currently disabled"


def test_check_submission_offline(make_challenge, dbsettings, ctf_end_date):
    result, msg = check_submission(make_challenge(), None, None, dbsettings)
    assert result is False
    assert msg == "Challenge is offline."


def test_check_submission_incorrect_solution(make_challenge, dbsettings,
                                             ctf_end_date):
    c = make_challenge(solution="Test", online=True)
    result, msg = check_submission(c, "Test ", None, dbsettings)
    assert result is False
    assert msg == "Solution incorrect."


def test_check_submission_manual(make_challenge, dbsettings, ctf_end_date):
    c = make_challenge(solution="Test", manual=True, online=True)
    result, msg = check_submission(c, "Test", None, dbsettings)
    assert result is False
    assert msg == "Credits for this challenge will be given manually."


def test_check_submission_dynamic(make_challenge, dbsettings, ctf_end_date):
    c = make_challenge(solution="Test", dynamic=True, online=True)
    result, msg = check_submission(c, "Test", None, dbsettings)
    assert result is False
    assert msg == "The challenge is dynamic, no submission possible."


def test_check_submission_already_solved(make_team, make_challenge, dbsession,
                                         dbsettings, ctf_end_date):
    c = make_challenge(solution="Test", online=True)
    t = make_team()
    s = Submission(team=t, challenge=c)
    dbsession.add(s)
    dbsession.flush()
    result, msg = check_submission(c, "Test", t.id, dbsettings)
    assert result is False
    assert msg == "Already solved."


def test_check_submission_ctf_over(dbsettings):
    dbsettings.ctf_end_date = now() - timedelta(1)
    result, msg = check_submission(None, None, None, dbsettings)
    assert result is False
    assert msg == "The CTF is over, no more solutions can be submitted."


class TestManualChallengePoints(object):

    def test_printable(self):
        assert isinstance(unicode(manual_challenge_points), unicode)
        assert isinstance(str(manual_challenge_points), str)
        assert isinstance(repr(manual_challenge_points), str)


class TestChallenge(object):

    def test_defaults(self, dbsession, make_challenge):
        c = make_challenge()
        dbsession.add(c)
        assert c.id is None
        assert c._points is None
        assert c.online is None
        assert c.manual is None
        assert c.dynamic is None
        dbsession.flush()
        assert c.id
        assert c._points == 0
        assert c.online is False
        assert c.manual is False
        assert c.dynamic is False

    def test_nullables(self, dbsession, make_challenge, nullable_exc):
        c = Challenge()
        t = dbsession.begin_nested()
        dbsession.add(c)
        try:
            with pytest.raises(DatabaseError):
                dbsession.flush()
        except Exception as e:
            print(e, type(e), "hi")
            raise
        t.rollback()

        for param in ['online', 'manual', 'dynamic']:
            t = dbsession.begin_nested()
            c = make_challenge()
            dbsession.add(c)
            dbsession.flush()
            setattr(c, param, None)
            with pytest.raises(nullable_exc):
                dbsession.flush()
            t.rollback()

    def test_printables(self, dbsession, make_challenge):
        c = make_challenge()
        dbsession.add(c)
        dbsession.flush()

        assert isinstance(str(c), str)
        assert str(c) == b"Challenge0"
        assert isinstance(unicode(c), unicode)
        assert unicode(c) == "Challenge0"

        r = repr(c)
        assert r == "<Challenge (normal) title=Challenge0, online=False>"

        c = make_challenge(manual=True, category=Category(name="Test"),
                           author="test1, test2", online=True)
        dbsession.add(c)
        dbsession.flush()
        r = repr(c)
        assert r == ("<Challenge (manual) title=Challenge1, online=True, "
                     "category=Test, author(s)=test1, test2>")

        c = make_challenge(dynamic=True, module_name="flags")
        dbsession.add(c)
        dbsession.flush()
        r = repr(c)
        assert r == ("<Challenge (dynamic) title=Challenge2, online=False, "
                     "module=flags>")

    def test_points(self, make_challenge):
        c = make_challenge(points=123)
        assert c.points == 123
        c.points = 321
        assert c.points == 321

    def test_points_manual(self, make_challenge):
        c = make_challenge(manual=True)
        c.points = 123
        assert c.points is manual_challenge_points
        c.points = 321
        assert c.points is manual_challenge_points

    def test_module(self, make_challenge):
        c = make_challenge()
        assert c.module is None
        c.module_name = "flags"
        assert c.module is dynamic_challenges.flags

    def test_announcements(self, dbsession, make_challenge):
        c = make_challenge()
        dbsession.add(c)
        dbsession.flush()
        n1 = News(challenge=c, timestamp=datetime(2012, 1, 1))
        n2 = News(challenge=c)
        assert c.announcements == [n2, n1]

    def test_category(self, make_challenge):
        c = make_challenge()
        cat = Category()
        cat.challenges.append(c)
        assert c.category == cat

    def test_not_manual_and_dynamic(self, dbsession, make_challenge):
        c = make_challenge(manual=True, dynamic=True)
        dbsession.add(c)
        with pytest.raises(ValueError):
            dbsession.flush()

    def test_submissions(self, make_team, make_challenge, dbsession):
        c = make_challenge()
        s = Submission(team=make_team(), challenge=c)
        dbsession.add(s)
        assert c.submissions == [s]


class TestCategory(object):

    def test_defaults(self, dbsession):
        cat = Category(name="Täst")
        assert cat.id is None
        dbsession.add(cat)
        dbsession.flush()
        assert cat.id

    def test_nullables(self, dbsession, nullable_exc):
        cat = Category()
        t = dbsession.begin_nested()
        dbsession.add(cat)
        with pytest.raises(nullable_exc):
            dbsession.flush()
        t.rollback()
        cat = Category(name="Test")
        dbsession.add(cat)
        dbsession.flush()

    def test_printables(self):
        cat = Category(name="Täst")
        assert isinstance(str(cat), str)
        assert str(cat) == b"Täst"
        assert isinstance(unicode(cat), unicode)
        assert unicode(cat) == "Täst"
        assert isinstance(repr(cat), str)
        assert repr(cat) == b"<Category id=None, name=Täst, challenges=0>"

    def test_challenge(self, make_challenge, dbsession):
        cat = Category(name="Test")
        chal = make_challenge(category=cat)
        dbsession.add(chal)
        assert cat.challenges == [chal]


class TestSubmission(object):

    def test_defaults(self, dbsession, make_team, make_challenge):
        s = Submission(team=make_team(), challenge=make_challenge())
        assert s.bonus is None
        dbsession.add(s)
        dbsession.flush()
        assert s.bonus == 0

    def test_nullables(self, dbsession, make_team, make_challenge,
                       nullable_exc):
        fails = [Submission(),
                 Submission(team=make_team()),
                 Submission(challenge=make_challenge())]
        for subm in fails:
            trans = dbsession.begin_nested()
            dbsession.add(subm)
            with pytest.raises(IntegrityError):
                dbsession.flush()
            trans.rollback()

        for param in ['bonus', 'timestamp']:
            trans = dbsession.begin_nested()
            s = Submission(team=make_team(), challenge=make_challenge())
            dbsession.add(s)
            dbsession.flush()
            setattr(s, param, None)
            with pytest.raises(nullable_exc):
                dbsession.flush()
            trans.rollback()

    def test_printable(self, make_team, make_challenge, dbsession):
        s = Submission(challenge=make_challenge(), team=make_team(),
                       timestamp=datetime(2012, 1, 1))
        dbsession.add(s)
        dbsession.flush()
        repr_ = repr(s)
        assert isinstance(repr_, str)
        assert repr_ == ("<Submission challenge=Challenge0, team=Team0, "
                         "bonus=0, timestamp=2012-01-01 00:00:00>")

    def test_team(self, make_team, dbsession, make_challenge):
        t = make_team()
        s = Submission(challenge=make_challenge())
        t.submissions.append(s)
        assert s.team == t
        dbsession.add(t)
        dbsession.flush()
        assert s.team == t

    def test_challenge(self, make_team, dbsession, make_challenge):
        c = make_challenge()
        s = Submission(team=make_team())
        c.submissions.append(s)
        assert s.challenge == c
        dbsession.add(c)
        dbsession.flush()
        assert s.challenge == c
