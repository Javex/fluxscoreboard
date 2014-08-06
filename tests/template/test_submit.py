# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from tests.template import TemplateTestBase
from fluxscoreboard.forms.front import SolutionSubmitListForm
from fluxscoreboard.util import now
from datetime import timedelta
from webob.multidict import MultiDict
import pytest


class TestSubmit(TemplateTestBase):
    name = "submit.mako"
    _form = SolutionSubmitListForm

    def _make_form_data(self):
        data = MultiDict({
            'solution': 'foo',
            'challenge': str(self.challenge.id),
        })
        return data

    @pytest.fixture(autouse=True)
    def _create_challenge(self, make_challenge, make_category, make_news,
                          dbsession):
        self.challenge = make_challenge(title="TitleFoo",
                                        online=True, published=True)
        dbsession.add(self.challenge)
        dbsession.flush()
        self.challenges = [self.challenge]

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team(active=True)
        dbsession.add(pyramid_request.team)
        dbsession.flush()

    def render(self, *args, **kw):
        kw.setdefault('form', self.form())
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render()
        assert "TitleFoo" in out

        assert "alert" not in out
        assert "alert-danger" not in out

    def test_archive_mode(self):
        self.settings.archive_mode = True
        out = self.render()
        assert "Scoreboard is in archive mode" in out

    def test_ctf_over(self):
        self.settings.ctf_end_date = now() - timedelta(hours=1)
        out = self.render()
        assert "The CTF is over" in out
        assert "Enter solution for challenge" not in out

    def test_submission_disabled(self):
        self.settings.submission_disabled = True
        out = self.render()
        assert "submission of solutions is currently disabled" in out
        assert "Enter solution for challenge" not in out

    def test_no_challenges(self):
        self.challenge.published = False
        out = self.render()
        assert "no challenges to submit" in out
        assert "Enter solution for challenge" not in out

    def test_missing_solution(self):
        out = self.render(form=self.form(solution=''))
        assert "alert" in out
        assert "alert-danger" in out

    def test_invalid_challenge(self):
        out = self.render(form=self.form(challenge=str(self.challenge.id + 1)))
        assert "alert" in out
        assert "alert-danger" in out
