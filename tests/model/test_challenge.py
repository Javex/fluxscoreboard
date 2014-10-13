# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.models import dynamic_challenges
from fluxscoreboard.models.challenge import (get_all_challenges,
    get_online_challenges, Submission, 
    get_submissions, Category, get_all_categories,
    check_submission, manual_challenge_points, Challenge,
    update_playing_teams, update_challenge_points)
from fluxscoreboard.models.news import News
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.util import now
from sqlalchemy.exc import IntegrityError, DatabaseError
from sqlalchemy.event import remove, listen
from mock import MagicMock
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


class TestSubmissionFuncs(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, dbsettings, make_challenge, make_team,
                 ctf_end_date):
        self.dbsession = dbsession
        self.dbsettings = dbsettings
        self.make_team = make_team
        self.make_challenge = make_challenge
        self.ctf_end_date = ctf_end_date

    @pytest.mark.parametrize("solution,input_",
                             [('Test', 'Test'),
                              ('Test', ' Test '),
                              ('Test', 'flag{Test}')
                              ])
    def test_check_submission(self, solution, input_):
        c = self.make_challenge(online=True, solution=solution)
        t = self.make_team()
        self.dbsession.add_all([c, t])
        self.dbsession.flush()
        result, msg = check_submission(c, input_, t.id, self.dbsettings)
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
        result, msg = check_submission(c, "TestX", None, self.dbsettings)
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
        self.dbsession.add(s)
        self.dbsession.flush()
        result, msg = check_submission(c, "Test", t.id, self.dbsettings)
        assert result is False
        assert msg == "Already solved."

    def test_check_submission_ctf_over(self):
        self.dbsettings.ctf_end_date = now() - timedelta(1)
        result, msg = check_submission(None, None, None, self.dbsettings)
        assert result is False
        assert msg == "The CTF is over, no more solutions can be submitted."


class TestManualChallengePoints(object):

    def test_printable(self):
        assert isinstance(unicode(manual_challenge_points), unicode)
        assert isinstance(str(manual_challenge_points), str)
        assert isinstance(repr(manual_challenge_points), str)


class TestUpdatePlayingTeams(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_team, make_challenge, dbsession):
        self.make_team = make_team
        self.make_challenge = lambda **kw: make_challenge(published=True, **kw)
        self.db = dbsession

        def _run():
            self.db.flush()
            update_playing_teams(dbsession.connection())
            self.db.flush()
            self.db.expire_all()
            settings = dbsession.query(Settings).one()
            return settings.playing_teams
        self.run = _run

    def test_no_teams(self):
        assert self.run() == 0

    def test_inactive_team(self):
        t = self.make_team(active=False)
        c = self.make_challenge()
        s = Submission(team=t, challenge=c)
        self.db.add(s)
        assert self.run() == 0

    def test_one_team(self):
        t = self.make_team(active=True)
        c = self.make_challenge()
        s = Submission(challenge=c, team=t)
        self.db.add(s)
        assert self.run() == 1

    def test_multiple_submissions(self):
        t = self.make_team(active=True)
        c1 = self.make_challenge()
        c2 = self.make_challenge()
        s1 = Submission(team=t, challenge=c1)
        s2 = Submission(team=t, challenge=c2)
        self.db.add_all([s1, s2])
        assert self.run() == 1

    def test_multiple_teams(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=True)
        c = self.make_challenge()
        s1 = Submission(team=t1, challenge=c)
        s2 = Submission(team=t2, challenge=c)
        self.db.add_all([s1, s2])
        assert self.run() == 2

    def test_distinct_team_chall(self):
        t1 = self.make_team(active=True)
        t2 = self.make_team(active=True)
        c1 = self.make_challenge()
        c2 = self.make_challenge()
        s1 = Submission(team=t1, challenge=c1)
        s2 = Submission(team=t2, challenge=c2)
        self.db.add_all([s1, s2])
        assert self.run() == 2

    def test_submission_remove(self):
        t = self.make_team(active=True)
        c = self.make_challenge()
        s = Submission(team=t, challenge=c)
        self.db.add(s)
        assert self.run() == 1
        self.db.delete(s)
        assert self.run() == 0


class TestUpdateChallengePoints(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_challenge, make_team, dbsession, dbsettings):
        self.make_team = make_team
        self.dbsettings = dbsettings

        def _make_challenge(**kw):
            kw.setdefault('published', True)
            return make_challenge(**kw)
        self.make_challenge = _make_challenge
        self.db = dbsession

        # make some active teams
        self.challenge = self.make_challenge()
        self.all_teams = []
        for _ in range(16):
            t = self.make_team(active=True)
            s = Submission(team=t, challenge=self.challenge)
            self.all_teams.append(t)
        self.db.add_all(self.all_teams)

        def _run(run_team_upd=True, team_upd_in_chall_upd=False):
            self.db.flush()
            if run_team_upd:
                update_playing_teams(self.db.connection())
            update_challenge_points(self.db.connection(),
                                    team_upd_in_chall_upd)
            self.db.flush()
            self.db.expire_all()
        self.run = _run
        self.run()

    def test_no_teams_solved(self):
        c = self.make_challenge()
        self.db.add(c)
        self.run()
        assert c.points == c.base_points + 100

    def test_one_team_solved(self):
        c = self.make_challenge()
        t = self.all_teams[0]
        s = Submission(team=t, challenge=c)
        self.db.add(s)
        self.run()
        assert c.points == c.base_points + 90

    def test_half_teams_solved(self):
        c = self.make_challenge()
        teams = self.all_teams[::2]
        self.db.add_all([Submission(team=t, challenge=c) for t in teams])
        self.run()
        assert c.points == c.base_points + 50

    def test_all_teams_solved(self):
        c = self.make_challenge()
        teams = self.all_teams
        self.db.add_all([Submission(team=t, challenge=c) for t in teams])
        self.run()
        assert c.points == c.base_points

    def test_change_base_points(self):
        c = self.make_challenge()
        self.db.add(c)
        self.run()
        assert c.points == c.base_points + 100
        c.base_points = 200
        self.run()
        assert c.points == 300

    def test_update_playing_inside(self):
        c = self.make_challenge()
        t = self.make_team(active=True)
        assert self.dbsettings.playing_teams == 16
        self.db.add(Submission(team=t, challenge=c))
        self.run(False, True)
        assert c.points == c.base_points + 90
        assert self.dbsettings.playing_teams == 17

    def test_no_update_playing(self):
        c = self.make_challenge()
        t = self.make_team(active=True)
        assert self.dbsettings.playing_teams == 16
        self.db.add_all([c, t])
        self.run(False, False)
        assert c.points == c.base_points + 100
        assert self.dbsettings.playing_teams == 16

    def test_update_manual(self):
        c = self.make_challenge(manual=True)
        self.db.add(c)
        self.run()
        assert not c._points

    def test_update_dynamic(self):
        c = self.make_challenge(dynamic=True)
        self.db.add(c)
        self.run()
        assert not c._points


class TestChallenge(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_challenge, make_team):
        self.dbsession = dbsession
        self.make_challenge = make_challenge
        self.make_team = make_team

    @pytest.fixture
    def module(self, request):
        module = MagicMock()
        module.__name__ = u"testmodule"
        dynamic_challenges.registry[u"testmodule"] = module

        def remove_module():
            del dynamic_challenges.registry[u"testmodule"]
        request.addfinalizer(remove_module)
        return u"testmodule"

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
        update_playing_teams(self.dbsession.connection())
        update_challenge_points(self.dbsession.connection())
        self.dbsession.flush()
        self.dbsession.expire(c)
        assert c.id
        assert c._points == 200
        assert c.online is False
        assert c.manual is False
        assert c.dynamic is False
        assert c.has_token is False

    def test_nullables(self, nullable_exc):
        c = Challenge(base_points=100)
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

    def test_printables(self, module):
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

        c = self.make_challenge(dynamic=True, module=module)
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        r = repr(c)
        assert r == ("<Challenge (dynamic) title=Challenge2, online=False, "
                     "module=%s>" % module)

    def test_printables_module(self, dynamic_module):
        modname, _ = dynamic_module
        c = self.make_challenge(dynamic=True, module=modname)
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        r = repr(c)
        assert r == ("<Challenge (dynamic) title=Challenge0, online=False, "
                     "module=%s>" % modname)

    def test_base_points(self):
        c = self.make_challenge(base_points=123)
        assert c.base_points == 123
        c.base_points = 321
        assert c.base_points == 321

    def test_points_manual(self):
        c = self.make_challenge(manual=True)
        assert c.points is manual_challenge_points

    def test_manual_w_base_pts(self):
        c = self.make_challenge(manual=True, base_points=100)
        self.dbsession.add(c)
        with pytest.raises(ValueError):
            self.dbsession.flush()

    def test_dynamic_w_base_pts(self):
        c = self.make_challenge(dynamic=True, base_points=100)
        self.dbsession.add(c)
        with pytest.raises(ValueError):
            self.dbsession.flush()

    def test_missing_base_pts(self):
        c = self.make_challenge()
        c.base_points = None
        self.dbsession.add(c)
        with pytest.raises(ValueError):
            self.dbsession.flush()

    def test_points_readonly(self):
        c = self.make_challenge()
        with pytest.raises(AttributeError):
            c.points = 100

    def test_module_mock(self, module):
        c = self.make_challenge()
        assert c.module is None
        c.module = module
        module_inst = dynamic_challenges.registry[module]
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        assert c.module is module_inst

    def test_module(self, dynamic_module):
        modname, module = dynamic_module
        c = self.make_challenge()
        assert c.module is None
        c.module = modname
        self.dbsession.add(c)
        self.dbsession.flush()
        self.dbsession.expire(c)
        assert c.module is module

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
        assert s.additional_pts is None
        self.dbsession.add(s)
        self.dbsession.flush()
        assert s.additional_pts == 0

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

        for param in ['additional_pts', 'timestamp']:
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
                         "additional_pts=0, timestamp=2012-01-01 00:00:00>")

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
