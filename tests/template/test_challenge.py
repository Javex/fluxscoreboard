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
        head = out.find("div", class_="panel-heading").find("h3")
        body = out.find("div", "panel-primary").find("div", class_="col-12")
        body_rows = body.find_all(class_="row")
        assert "AuthorFoo" in head.find("small").string
        assert "CategoryFoo" in head.text
        assert self.request.team.challenge_token in body_rows[2].text
        assert "Scoreboard is in archive mode" not in body.text
        assert "Enter solution for challenge" in body.text
        assert "FooAnn" in out.text
        assert "alert" not in out.text
        assert "alert-danger" not in out.text

    def test_solution_missing(self):
        out = self.render(form=self.form(solution=''))
        body = out.find("div", "panel-primary").find("div", class_="col-12")
        assert body.find("form").find("div", class_="alert-danger")

    def test_archive_mode(self):
        self.settings.archive_mode = True
        out = self.render()
        assert "00000000-0000-0000-0000-000000000000" in out.text
        assert "Scoreboard is in archive mode" in out.text
        assert "Enter solution" in out.text

    def test_solved_challenge(self):
        out = self.render(is_solved=True)
        assert "You have already solved" in out.text
        assert "Enter solution" not in out.text

    def test_ctf_over(self):
        self.settings.ctf_end_date = now() - timedelta(hours=1)
        out = self.render()
        assert "CTF is over" in out.text
        assert "Enter solution" not in out.text

    def test_manual_challenge(self):
        self.challenge.manual = True
        out = unicode(self.render())
        assert "evaluated manually" in out
        assert "Enter solution" not in out

    def test_submission_disabled(self):
        self.settings.submission_disabled = True
        out = unicode(self.render())
        assert "Submission of solutions is currently disabled" in out
        assert "Enter solution" not in out

    def test_challenge_offline(self):
        self.challenge.online = False
        out = unicode(self.render())
        assert "currently offline" in out
        assert "Enter solution" not in out

    def test_dynamic_mock(self, module):
        self.challenge.dynamic = True
        self.challenge.module = module
        module.render.return_value = "Dynamic<br/>Out"
        out = unicode(self.render())
        assert "Dynamic<br/>Out" in out

    def test_dynamic(self, dynamic_module):
        _, module = dynamic_module
        self.challenge.dynamic = True
        self.challenge.module = module
        assert self.render()
