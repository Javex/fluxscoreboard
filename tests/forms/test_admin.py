import pytest
from fluxscoreboard.forms.admin import NewsForm, ChallengeForm, CategoryForm, TeamForm, get_dynamic_module_choices
from fluxscoreboard.models import dynamic_challenges
from webob.multidict import MultiDict
from mock import MagicMock
from conftest import GeneralCSRFTest


class TestNewsForm(GeneralCSRFTest):

    _form = NewsForm

    def _make_data(self):
        data =  [
            ('message', 'foo'),
            ('published', False),
            ('challenge', ''),
            ('id', ''),
            ('submit', 'Save'),
            ('csrf_token', self.request.session.get_csrf_token()),
        ]
        return data

    def test_missing_message(self):
        self.data["message"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'message' in form.errors

    def test_invalid_challenge(self):
        self.data["challenge"] = "13"
        form = self.make(self.data)
        assert not form.validate()
        assert 'challenge' in form.errors

    def test_published(self):
        self.data["published"] = True
        form = self.make(self.data)
        assert form.validate()


class TestChallengeForm(GeneralCSRFTest):

    _form = ChallengeForm

    def _make_data(self):
        data = [
            ('title', 'Foo'),
            ('text', 'Foo<br>Bla'),
            ('solution', 'Lol'),
            ('points', '123'),
            ('author', 'foo, lol'),
            ('online', ''),
            ('manual', ''),
            ('dynamic', ''),
            ('module', ''),
            ('published', ''),
            ('has_token', ''),
            ('id', ''),
            ('submit', 'Save'),
            ('csrf_token', self.request.session.get_csrf_token()),
        ]
        return data

    def make(self, data):
        self._form.module.kwargs["choices"] = get_dynamic_module_choices()
        return self._form(data, csrf_context=self.request)

    @pytest.fixture(autouse=True)
    def _init_categories(self, make_category, dbsession):
        self.dbsession = dbsession
        self.cat = make_category()
        dbsession.add(self.cat)
        dbsession.flush()
        assert self.cat.id
        self.data["category"] = str(self.cat.id)

    @pytest.fixture
    def module(self):
        module = MagicMock()
        dynamic_challenges.registry[u"testmodule"] = module
        return u"testmodule"

    def _make_dynamic(self, module):
        self.data["dynamic"] = '1'
        self.data["points"] = ''
        self.data["solution"] = ''
        self.data["module"] = module

    def test_missing_title(self):
        self.data["title"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'title' in form.errors

    def test_title_too_long(self):
        self.data["title"] = 'A' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert 'title' in form.errors

    def test_missing_text(self):
        self.data["text"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'text' in form.errors

    def test_missing_text_dynamic(self, module):
        self._make_dynamic(module)
        self.data["text"] = ''
        form = self.make(self.data)
        assert form.validate()

    def test_missing_solution(self):
        self.data["solution"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'solution' in form.errors

    def test_solution_manual(self):
        self.data["manual"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'solution' in form.errors

    def test_solution_dynamic(self, module):
        self._make_dynamic(module)
        self.data["solution"] = 'foo'
        form = self.make(self.data)
        assert not form.validate()
        assert 'solution' in form.errors

    def test_missing_points(self):
        self.data["points"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'points' in form.errors

    def test_points_manual(self):
        self.data["manual"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'points' in form.errors

    def test_points_dynamic(self):
        self.data["dynamic"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'points' in form.errors

    def test_category_invalid(self):
        self.data["category"] = "foo"
        form = self.make(self.data)
        assert not form.validate()
        assert 'category' in form.errors

    def test_manual_dynamic(self):
        self.data["manual"] = '1'
        self.data["dynamic"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'manual' in form.errors

    def test_module_invalid(self):
        self.data["module"] = "foomod"
        form = self.make(self.data)
        assert not form.validate()
        assert 'module' in form.errors

    def test_module(self, module):
        self._make_dynamic(module)
        form = self.make(self.data)
        assert form.validate()

    def test_module_multiple_allowed(self, module):
        mod_obj = dynamic_challenges.registry[module]
        mod_obj.allow_multiple = True
        self._make_dynamic(module)
        form = self.make(self.data)
        assert form.validate()

    def test_module_multiple_allowed_has_multiple(self, module, make_challenge):
        c = make_challenge(module=module)
        self.dbsession.add(c)
        self._make_dynamic(module)
        mod_obj = dynamic_challenges.registry[module]
        mod_obj.allow_multiple = True
        form = self.make(self.data)
        assert form.validate()

    def test_module_multiple_not_allowed_has_multiple(self, module, make_challenge):
        c = make_challenge(module=module)
        self.dbsession.add(c)
        self._make_dynamic(module)
        mod_obj = dynamic_challenges.registry[module]
        mod_obj.allow_multiple = False
        form = self.make(self.data)
        assert not form.validate()
        assert "module" in form.errors


class TestCategoryForm(GeneralCSRFTest):

    _form = CategoryForm

    def _make_data(self):
        data =  [
            ('name', 'foo'),
            ('id', ''),
            ('submit', 'Save'),
            ('csrf_token', self.request.session.get_csrf_token()),
        ]
        return data

    def test_name_missing(self):
        self.data["name"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_name_too_long(self):
        self.data["name"] = 'A' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

class TestTeamForm(GeneralCSRFTest):

    _form = TeamForm

    def _make_data(self):
        data =  [
            ('name', 'foo'),
            ('password', 'foo2foo2foo2'),
            ('email', 'foo@example.com'),
            ('size', ''),
            ('active', ''),
            ('local', ''),
            ('id', ''),
            ('submit', 'Save'),
            ('csrf_token', self.request.session.get_csrf_token()),
        ]
        return data

    @pytest.fixture(autouse=True)
    def _countries(self, countries):
        self.countries = countries
        self.data['country'] = str(countries[0].id)

    def test_name_missing(self):
        self.data["name"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_name_too_long(self):
        self.data["name"] = 'A' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_password_empty_new(self):
        self.data["password"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "password" in form.errors

    def test_password_empty_existing(self, make_team):
        t = make_team()
        self.dbsession.add(t)
        self.dbsession.flush()
        self.data["password"] = ''
        self.data["id"] = str(t.id)
        form = self.make(self.data)
        assert form.validate()
