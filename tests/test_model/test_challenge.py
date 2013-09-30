# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from . import all_challenges, challenge, make_team
from ..fixture import pyramid_request, settings
from fluxscoreboard.models.challenge import (get_all_challenges,
    get_online_challenges, Submission, Challenge, get_unsolved_challenges,
    get_solvable_challenges, get_submissions, Category, get_all_categories,
    check_submission, manual_challenge_points)
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.models.team import Team
from sqlalchemy.orm.exc import DetachedInstanceError
import pytest
from fluxscoreboard.models import dynamic_challenges


def test_get_all_challenges(all_challenges, dbsession):
    dbsession.add_all(all_challenges)
    assert len(get_all_challenges().all()) == 6


def test_get_online_challenges(all_challenges, dbsession):
    dbsession.add_all(all_challenges)
    assert len(get_online_challenges().all()) == 3


def test_get_unsolved_challenges(dbsession, make_team):
    t1 = make_team()
    c1 = Challenge(online=True)
    s1 = Submission(challenge=c1, team=t1)
    c2 = Challenge(online=True)
    dbsession.add_all([s1, c2])
    dbsession.flush()
    unsolved = get_unsolved_challenges(t1.id)
    assert unsolved.count() == 1
    assert unsolved[0] == c2


def test_get_solvable_challenges(dbsession, make_team):
    t = make_team()
    c1 = Challenge(online=True)
    c2 = Challenge(online=True, manual=True)
    c3 = Challenge(online=True)
    s = Submission(challenge=c1, team=t)
    dbsession.add_all([s, c2, c3])
    dbsession.flush()
    query = get_solvable_challenges(t.id)
    assert query.count() == 1
    assert query[0] == c3


def test_get_submissions(dbsession, make_team):
    c = Challenge()
    t = make_team()
    s = Submission(challenge=c, team=t)
    dbsession.add(s)

    query = get_submissions()
    assert query.count() == 1
    assert query[0] == s


def test_get_all_categories(dbsession):
    cat = Category()
    dbsession.add(cat)
    q = get_all_categories()
    assert q.count() == 1
    assert q[0] == cat


def test_check_submission(dbsession, make_team):
    c = Challenge(online=True, solution="Test")
    t = make_team()
    dbsession.add_all([c, t])
    dbsession.flush()
    result, msg = check_submission(c, "Test", t.id, Settings())
    assert result is True
    assert msg == 'Congratulations: You solved this challenge as first!'
    assert len(c.submissions) == 1
    assert len(t.submissions) == 1


def test_check_submission_places(dbsession, make_team):
    c = Challenge(online=True, solution="Test")
    teams = [make_team() for _ in range(4)]
    dbsession.add_all(teams + [c])
    dbsession.flush()
    msgs = ['Congratulations: You solved this challenge as first!',
            'Congratulations: You solved this challenge as second!',
            'Congratulations: You solved this challenge as third!',
            'Congratulations: That was the correct solution!']
    for i in range(4):
        result, msg = check_submission(c, "Test", teams[i].id, Settings())
        assert result is True
        assert msg == msgs[i]
        assert len(c.submissions) == i + 1
        assert len(teams[i].submissions) == 1


def test_check_submission_disabled():
    result, msg = check_submission(None, None, None,
                                   Settings(submission_disabled=True))
    assert result is False
    assert msg == "Submission is currently disabled"


def test_check_submission_offline():
    result, msg = check_submission(Challenge(), None, None, Settings())
    assert result is False
    assert msg == "Challenge is offline."


def test_check_submission_incorrect_solution():
    c = Challenge(solution="Test", online=True)
    result, msg = check_submission(c, "Test ", None, Settings())
    assert result is False
    assert msg == "Solution incorrect."


def test_check_submission_manual():
    c = Challenge(solution="Test", manual=True, online=True)
    result, msg = check_submission(c, "Test", None, Settings())
    assert result is False
    assert msg == "Credits for this challenge will be given manually."


def test_check_submission_dynamic():
    c = Challenge(solution="Test", dynamic=True, online=True)
    result, msg = check_submission(c, "Test", None, Settings())
    assert result is False
    assert msg == "The challenge is dynamic, no submission possible."


def test_check_submission_already_solved(make_team, dbsession):
    c = Challenge(solution="Test", online=True)
    t = make_team()
    s = Submission(team=t, challenge=c)
    dbsession.add(s)
    dbsession.flush()
    result, msg = check_submission(c, "Test", t.id, Settings())
    assert result is False
    assert msg == "Already solved."


def test_Challenge_points():
    c = Challenge(points=123)
    assert c.points == 123
    c.points = 321
    assert c.points == 321


def test_Challenge_points_manual():
    c = Challenge(manual=True)
    c.points = 123
    assert c.points is manual_challenge_points
    c.points = 321
    assert c.points is manual_challenge_points


def test_Challenge_module():
    c = Challenge()
    assert c.module is None
    c.module_name = "flags"
    assert c.module is dynamic_challenges.flags
