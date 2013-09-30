# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from . import make_team
from ..fixture import dbsession
from fluxscoreboard.models.challenge import Submission, Challenge
from fluxscoreboard.models.team import get_team_solved_subquery


def test_get_team_solved_subquery(make_team, dbsession):
    t = make_team()
    c1 = Challenge()
    c2 = Challenge()
    s1 = Submission(challenge=c1, team=t)
    dbsession.add_all([s1, c2])
    dbsession.flush()
    query = get_team_solved_subquery(t.id)
    assert query.count() == 1
    subm = query.first()
    assert subm == s1
    assert subm.challenge == c1
    assert subm.team == t
