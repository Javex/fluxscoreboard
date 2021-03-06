import pytest
from fluxscoreboard.forms.admin import (NewsForm, ChallengeForm, CategoryForm,
    TeamForm, IPSearchForm, SubmissionForm, MassMailForm, ButtonForm,
    SubmissionButtonForm, TeamCleanupForm, SettingsForm,
    get_dynamic_module_choices)
from fluxscoreboard.models import Challenge, News, Category, Team, Submission, MassMail, Settings
from fluxscoreboard.models import dynamic_challenges
from webob.multidict import MultiDict
from mock import MagicMock
from conftest import GeneralCSRFTest
from datetime import datetime


class GeneralAdminFormTest(GeneralCSRFTest):
    _pks = ['id']

    def test_populate_obj(self, dbsession):
        obj = self._db_cls()
        form = self.make(self.data)
        for k in self._pks:
            if getattr(form, k).data == '':
                getattr(form, k).data = None
        with dbsession.no_autoflush:
            form.populate_obj(obj)
            dbsession.add(obj)
        dbsession.flush()
        self._check_obj(obj)

    def _check_obj(self, obj):
        for k, v in self.data.items():
            if k in ['submit', 'cancel', 'password']:
                continue
            if k in self._pks and self.data[k] == '':
                continue
            else:
                if not hasattr(obj, k) and not hasattr(obj, k + '_id'):
                    continue
                obj_val = getattr(obj, k, None)
                pk_val = getattr(obj, k + '_id', None)
                if isinstance(obj_val, bool):
                    assert obj_val == bool(v)
                elif isinstance(obj_val, datetime):
                    assert str(obj_val.replace(tzinfo=None)) == v
                elif obj_val is None and pk_val is None:
                    assert not v
                else:
                    assert str(obj_val) == v or str(pk_val) == v


class TestNewsForm(GeneralAdminFormTest):

    _form = NewsForm
    _db_cls = News

    def _make_data(self):
        data =  [
            ('message', u'foo'),
            ('published', ''),
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


class TestChallengeForm(GeneralAdminFormTest):

    _form = ChallengeForm
    _db_cls = Challenge

    def _make_data(self):
        data = [
            ('title', u'Foo'),
            ('text', u'Foo<br>Bla'),
            ('solution', u'Lol'),
            ('base_points', '123'),
            ('author', u'foo, lol'),
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
    def module(self, request):
        module = MagicMock()
        dynamic_challenges.registry[u"testmodule"] = module

        def remove_module():
            del dynamic_challenges.registry[u"testmodule"]
        request.addfinalizer(remove_module)
        return u"testmodule"

    def _make_dynamic(self, module):
        self.data["dynamic"] = '1'
        self.data["base_points"] = ''
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
        self.data["base_points"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'base_points' in form.errors

    def test_points_manual(self):
        self.data["manual"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'base_points' in form.errors

    def test_points_dynamic(self):
        self.data["dynamic"] = '1'
        form = self.make(self.data)
        assert not form.validate()
        assert 'base_points' in form.errors

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


class TestCategoryForm(GeneralAdminFormTest):

    _form = CategoryForm
    _db_cls = Category

    def _make_data(self):
        data =  [
            ('name', u'foo'),
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


class TestTeamForm(GeneralAdminFormTest):

    _form = TeamForm
    _db_cls = Team

    def _make_data(self):
        data =  [
            ('name', u'foo'),
            ('password', u'foo2foo2foo2'),
            ('email', u'foo@example.com'),
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

    def test_password_empty_existing(self, make_team, dbsession):
        t = make_team()
        dbsession.add(t)
        dbsession.flush()
        self.data["password"] = ''
        self.data["id"] = str(t.id)
        form = self.make(self.data)
        assert form.validate()

    def test_password_too_long(self):
        self.data["password"] = 'A' * 1025
        form = self.make(self.data)
        assert not form.validate()
        assert "password" in form.errors

    def test_password_too_short(self):
        self.data["password"] = 'A' * 7
        form = self.make(self.data)
        assert not form.validate()
        assert "password" in form.errors

    def test_email_missing(self):
        self.data["email"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "email" in form.errors

    def test_email_too_long(self):
        self.data["email"] = 'A@b.com' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert "email" in form.errors

    def test_invalid_country(self):
        self.data["country"] = '1234'
        form = self.make(self.data)
        assert not form.validate()
        assert "country" in form.errors


class TestIPSearchForm(GeneralCSRFTest):

    _form = IPSearchForm

    def _make_data(self):
        data =  [
            ('term', ''),
            ('submit', 'Search'),
        ]
        return data


class TestSubmissionForm(GeneralAdminFormTest):

    _form = SubmissionForm
    _db_cls = Submission
    _pks = []

    def _make_data(self):
        data = [
            ('bonus', '0'),
            ('submit', 'Save'),
        ]
        return data

    @pytest.fixture(autouse=True)
    def _add_challenge_and_team(self, make_team, make_challenge, dbsession):
        self.team = make_team(active=True)
        self.challenge = make_challenge()
        dbsession.add_all([self.team, self.challenge])
        dbsession.flush()
        self.data["challenge"] = str(self.challenge.id)
        self.data["team"] = str(self.team.id)

    def test_invalid_challenge(self):
        self.data["challenge"] = "1234"
        form = self.make(self.data)
        assert not form.validate()
        assert "challenge" in form.errors

    def test_invalid_team(self):
        self.data["team"] = "1234"
        form = self.make(self.data)
        assert not form.validate()
        assert "team" in form.errors


class TestMassMailForm(GeneralAdminFormTest):

    _form = MassMailForm
    _db_cls = MassMail
    _pks = []

    def _make_data(self):
        data = [
            ('from_', u'foo@example.com'),
            ('subject', u'Bla'),
            ('message', u'Lol\nWhatever'),
            ('submit', 'Send'),
        ]
        return data

    def test_subject_missing(self):
        self.data["subject"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "subject" in form.errors

    def test_message_missing(self):
        self.data["message"] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "message" in form.errors

    def test_populate_obj(self, dbsession):
        obj = self._db_cls()
        form = self.make(self.data)
        form.populate_obj(obj)
        obj.recipients = []
        dbsession.add(obj)
        dbsession.flush()
        self._check_obj(obj)


class TestButtonForm(GeneralCSRFTest):

    _form = ButtonForm

    def _make_data(self):
        data = [
            ('button', 'Something'),
            ('id', '1'),
        ]
        return data

    def test_id_missing(self):
        self.data['id'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'id' in form.errors


class TestSubmissionButtonForm(GeneralCSRFTest):

    _form = SubmissionButtonForm

    def _make_data(self):
        data = [
            ('button', b'Something'),
            ('challenge_id', '1'),
            ('team_id', '1'),
        ]
        return data

    def test_challenge_id_missing(self):
        self.data['challenge_id'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'challenge_id' in form.errors

    def test_team_id_missing(self):
        self.data['team_id'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'team_id' in form.errors


class TestTeamCleanupForm(GeneralCSRFTest):

    _form = TeamCleanupForm

    def _make_data(self):
        return [('team_cleanup', 'Whatever')]


class TestSettingsForm(GeneralAdminFormTest):

    _form = SettingsForm
    _db_cls = Settings
    _pks = []

    def _make_data(self):
        data = [
            ('submission_disabled', ''),
            ('ctf_start_date', '2014-08-05 19:28:00'),
            ('ctf_end_date', '2014-08-05 19:29:00'),
            ('archive_mode', ''),
            ('submit', 'Send'),
        ]
        return data

    @pytest.mark.parametrize("field", ['ctf_start_date',
                                       'ctf_end_date'])
    def test_invalid_tzdatetime(self, field):
        self.data[field] = 'something'
        form = self.make(self.data)
        assert not form.validate()
        assert field in form.errors
