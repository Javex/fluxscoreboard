# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import timedelta
from fluxscoreboard.forms.front import SolutionSubmitForm
from fluxscoreboard.util import now
from fluxscoreboard.models import Submission
from tests.template import TemplateTestBase
from webob.multidict import MultiDict
from mock import MagicMock
import pytest


class TestChallenge(TemplateTestBase):
    name = "challenge.mako"
    _form = SolutionSubmitForm

    @pytest.fixture(autouse=True)
    def _create_challenge(self, make_challenge, make_category, make_news,
                          dbsession):
        self.challenge = make_challenge(author="AuthorFoo", has_token=True,
                                        online=True)
        self.challenge.category = make_category(name="CategoryFoo")
        self.challenge.announcements.append(make_news(message="FooAnn",
                                                      published=True))
        dbsession.add(self.challenge)
        dbsession.flush()

    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, pyramid_request, dbsession):
        pyramid_request.team = make_team()
        dbsession.add(pyramid_request.team)
        dbsession.flush()

    def _make_form_data(self):
        data = MultiDict({'solution': 'Foo',
                          })
        return data

    def render(self, *args, **kw):
        kw.setdefault('challenge', self.challenge)
        kw.setdefault('is_solved', False)
        kw.setdefault('form', self.form())
        return TemplateTestBase.render(self, *args, **kw)

    def test_body(self):
        out = self.render(form=self.form(False))
        assert "AuthorFoo" in out
        assert "CategoryFoo" in out
        assert self.request.team.challenge_token in out
        assert "Scoreboard is in archive mode" not in out
        assert "Enter solution for challenge" in out
        assert "FooAnn" in out
        assert "alert" not in out
        assert "alert-danger" not in out

    def test_solution_missing(self):
        out = self.render(form=self.form(solution=''))
        assert "alert-danger" in out

    def test_archive_mode(self):
        self.settings.archive_mode = True
        out = self.render()
        assert "00000000-0000-0000-0000-000000000000" in out
        assert "Scoreboard is in archive mode" in out
        assert "Enter solution" in out

    def test_solved_challenge(self):
        out = self.render(is_solved=True)
        assert "You have already solved" in out
        assert "Enter solution" not in out

    def test_ctf_over(self):
        self.settings.ctf_end_date = now() - timedelta(hours=1)
        out = self.render()
        assert "CTF is over" in out
        assert "Enter solution" not in out

    def test_manual_challenge(self):
        self.challenge.manual = True
        out = self.render()
        assert "evaluated manually" in out
        assert "Enter solution" not in out

    def test_submission_disabled(self):
        self.settings.submission_disabled = True
        out = self.render()
        assert "Submission of solutions is currently disabled" in out
        assert "Enter solution" not in out

    def test_challenge_offline(self):
        self.challenge.online = False
        out = self.render()
        assert "currently offline" in out
        assert "Enter solution" not in out

    def test_dynamic_mock(self, module):
        self.challenge.dynamic = True
        self.challenge.module = module
        module.render.return_value = "Dynamic<br>Out"
        out = self.render()
        assert "Dynamic<br>Out" in out

    def test_dynamic(self, dynamic_module):
        _, module = dynamic_module
        self.challenge.dynamic = True
        self.challenge.module = module
        assert isinstance(self.render(), (unicode, str))