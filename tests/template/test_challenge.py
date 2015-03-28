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

    @pytest.mark.xfail
    def test_body(self):
        out = self.render(form=self.form(False))
        assert u"AuthorFoo" in out.find("small").string
        assert u"CategoryFoo" in out.text
        assert self.request.team.challenge_token in out.text
        assert u"Scoreboard is in archive mode" not in out.text
        assert u"Enter solution for challenge" in out.text
        assert u"FooAnn" in out.text
        assert u"alert" not in out.text
        assert u"alert-danger" not in out.text

    def test_solution_missing(self):
        out = self.render(form=self.form(solution=''))
        assert out.find("form").find("div", class_="alert-danger")

    @pytest.mark.xfail
    def test_archive_mode(self):
        self.settings.archive_mode = True
        out = self.render()
        assert u"00000000-0000-0000-0000-000000000000" in out.text
        assert u"Scoreboard is in archive mode" in out.text
        assert u"Enter solution" in out.text

    def test_solved_challenge(self):
        out = self.render(is_solved=True)
        assert u"You have already solved" in out.text
        assert u"Enter solution" not in out.text

    def test_ctf_over(self):
        self.settings.ctf_end_date = now() - timedelta(hours=1)
        out = self.render()
        assert u"CTF is over" in out.text
        assert u"Enter solution" not in out.text

    def test_manual_challenge(self):
        self.challenge.manual = True
        self.challenge.base_points = None
        out = unicode(self.render())
        assert u"evaluated manually" in out
        assert u"Enter solution" not in out

    @pytest.mark.xfail
    def test_submission_disabled(self):
        self.settings.submission_disabled = True
        out = unicode(self.render())
        assert u"Submission of solutions is currently disabled" in out
        assert u"Enter solution" not in out

    def test_challenge_offline(self):
        self.challenge.online = False
        out = unicode(self.render())
        assert u"currently offline" in out
        assert u"Enter solution" not in out

    def test_dynamic_mock(self, module):
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = module
        module.render.return_value = "Dynamic<br/>Out"
        out = unicode(self.render())
        assert u"Dynamic<br/>Out" in out

    @pytest.mark.skipif(True, reason="Broken")
    def test_dynamic(self, dynamic_module):
        _, module = dynamic_module
        self.challenge.dynamic = True
        self.challenge.base_points = None
        self.challenge.module = module
        assert self.render()
