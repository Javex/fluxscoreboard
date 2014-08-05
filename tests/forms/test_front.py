import pytest
from fluxscoreboard.forms.front import (RegisterForm, ProfileForm, 
    ResetPasswordForm, SolutionSubmitListForm, SolutionSubmitForm, LoginForm,
    ForgotPasswordForm)
from fluxscoreboard.forms._fields import RecaptchaField
from mock import MagicMock
from conftest import GeneralCSRFTest
from webob.multidict import MultiDict


@pytest.mark.usefixtures("remove_captcha")
class TestRegisterForm(GeneralCSRFTest):

    _form = RegisterForm

    def _make_data(self):
        data = [
            ('name', u'Foo'),
            ('email', u'foo@example.com'),
            ('email_repeat', 'foo@example.com'),
            ('password', 'foo2foo2foo2'),
            ('password_repeat', 'foo2foo2foo2'),
            ('timezone', 'UTC'),
            ('size', ''),
            ('submit', 'Register'),
        ]
        return data

    def make(self, data):
        return self._form(data, csrf_context=self.request)

    @pytest.fixture(autouse=True)
    def _countries(self, countries):
        self.countries = countries
        self.data['country'] = str(countries[0].id)

    def test_name_missing(self):
        self.data['name'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_name_too_long(self):
        self.data['name'] = u'A' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_name_not_unique(self, make_team, dbsession):
        t = make_team()
        dbsession.add(t)
        self.data['name'] = t.name
        form = self.make(self.data)
        assert not form.validate()
        assert "name" in form.errors

    def test_email_missing(self):
        self.data['email'] = u''
        self.data['email_repeat'] = u''
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors
        assert 'email_repeat' in form.errors

    def test_email_unequal(self):
        self.data['email'] = unicode(self.data['email_repeat'] + 'A')
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors
        assert 'email_repeat' not in form.errors

    def test_email_too_long(self):
        self.data['email'] = u'A' * 256
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors
        assert 'email_repeat' not in form.errors

    def test_email_not_unique(self, make_team, dbsession):
        t = make_team()
        dbsession.add(t)
        self.data['email'] = t.email
        self.data['email_repeat'] = t.email
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors
        assert 'email_repeat' not in form.errors

    def test_password_missing(self):
        self.data['password'] = ''
        self.data['password_repeat'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' in form.errors

    def test_password_unequal(self):
        self.data['password'] = self.data['password_repeat'] + 'A'
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_short(self):
        self.data['password'] = 'A' * 7
        self.data['password_repeat'] = 'A' * 7
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_long(self):
        self.data['password'] = 'A' * 1025
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_country_invalid_choice(self):
        self.data['country'] = str(self.countries[-1].id + 1)
        form = self.make(self.data)
        assert not form.validate()
        assert 'country' in form.errors

    def test_timezone_invalid_choice(self):
        self.data['timezone'] = 'Lol/Foo'
        form = self.make(self.data)
        assert not form.validate()
        assert 'timezone' in form.errors

    def test_timezone_valid_choice(self):
        self.data['timezone'] = 'Europe/Berlin'
        form = self.make(self.data)
        assert form.validate()


class TestLoginForm(GeneralCSRFTest):

    _form = LoginForm

    def _make_data(self):
        data = [
            ('email', 'foo@example.com'),
            ('password', 'foo2foo2foo2'),
            ('login', 'Login'),
        ]
        return data

    def test_email_missing(self):
        self.data['email'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors

    def test_password_missing(self):
        self.data['password'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors


class TestForgotPasswordForm(GeneralCSRFTest):

    _form = ForgotPasswordForm

    def _make_data(self):
        data = [
            ('email', 'foo@example.com'),
            ('submit', 'Send Reset E-Mail'),
        ]
        return data

    def test_email_missing(self):
        self.data['email'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors


class TestResetPasswordForm(GeneralCSRFTest):

    _form = ResetPasswordForm

    def _make_data(self):
        data = [
            ('password', 'foo2foo2foo3'),
            ('password_repeat', 'foo2foo2foo3'),
            ('submit', 'Set New Password'),
        ]
        return data

    def test_password_missing(self):
        self.data['password'] = ''
        self.data['password_repeat'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' in form.errors

    def test_password_unequal(self):
        self.data['password'] = self.data['password_repeat'] + 'A'
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_short(self):
        self.data['password'] = 'A' * 7
        self.data['password_repeat'] = 'A' * 7
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_long(self):
        self.data['password'] = 'A' * 1025
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors


class TestProfileForm(GeneralCSRFTest):

    _form = ProfileForm

    def _make_data(self):
        data = [
            ('email', 'foo@example.com'),
            ('old_password', ''),
            ('password', ''),
            ('password_repeat', ''),
            ('avatar', ''),
            ('timezone', 'UTC'),
            ('size', ''),
            ('submit', 'Save'),
        ]
        return data

    @pytest.fixture(autouse=True)
    def _countries(self, countries):
        self.countries = countries
        self.data['country'] = str(countries[0].id)

    @pytest.fixture(autouse=True)
    def _test_team(self, dbsession, make_team):
        self.team = make_team()
        dbsession.add(self.team)
        dbsession.flush()

    @pytest.fixture
    def _create_team(self, make_team, dbsession, pyramid_request, config):
        self.team = make_team()
        dbsession.add(self.team)
        dbsession.flush()
        pyramid_request.team = self.team

    def make(self, data, team=None):
        if team is None:
            team = self.team
        return self._form(data, team, csrf_context=self.request)

    def test_missing_token(self):
        form = self._form(MultiDict(), self.team, csrf_context=self.request)
        assert not form.validate()

    def test_email_missing(self):
        self.data['email'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'email' in form.errors

    def test_old_password_if_change_missing(self):
        self.data['old_password'] = ''
        self.data['password'] = 'foo2foo2foo2'
        self.data['password_repeat'] = 'foo2foo2foo2'
        form = self.make(self.data)
        assert not form.validate()
        assert 'old_password' in form.errors

    def test_old_password_if_change_present(self, _create_team):
        self.data['old_password'] = u'foo2foo2foo3'
        self.team.password = self.data['old_password']
        self.data['password'] = u'foo2foo2foo2'
        self.data['password_repeat'] = u'foo2foo2foo2'
        form = self.make(self.data)
        assert form.validate()

    def test_password_unequal(self):
        self.data['password'] = self.data['password_repeat'] + 'A'
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_short(self):
        self.data['password'] = 'A' * 7
        self.data['password_repeat'] = 'A' * 7
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_too_long(self):
        self.data['password'] = 'A' * 1025
        form = self.make(self.data)
        assert not form.validate()
        assert 'password' in form.errors
        assert 'password_repeat' not in form.errors

    def test_password_not_required(self):
        self.data['password'] = ''
        self.data['password_repeat'] = ''
        form = self.make(self.data)
        assert form.validate()

    def test_avatar_too_large(self):
        self.data['avatar'] = MagicMock()
        self.data['avatar'].value.__len__.return_value = 200 * 1024
        form = self.make(self.data)
        assert not form.validate()
        assert 'avatar' in form.errors

    def test_country_invalid_choice(self):
        self.data['country'] = str(self.countries[-1].id + 1)
        form = self.make(self.data)
        assert not form.validate()
        assert 'country' in form.errors

    def test_timezone_invalid_choice(self):
        self.data['timezone'] = 'Lol/Foo'
        form = self.make(self.data)
        assert not form.validate()
        assert 'timezone' in form.errors

    def test_timezone_valid_choice(self):
        self.data['timezone'] = 'Europe/Berlin'
        form = self.make(self.data)
        assert form.validate()



class TestSolutionSubmitForm(GeneralCSRFTest):

    _form = SolutionSubmitForm

    def _make_data(self):
        data = [
            ('solution', 'foo'),
            ('submit', 'Submit'),
        ]
        return data

    def test_solution_missing(self):
        self.data['solution'] = ''
        form = self.make(self.data)
        assert not form.validate()
        assert 'solution' in form.errors


class TestSolutionSubmitListForm(TestSolutionSubmitForm):

    _form = SolutionSubmitListForm

    @pytest.fixture(autouse=True)
    def _prepare_challenge(self, dbsession, make_challenge):
        self.challenge = make_challenge(published=True, online=True)
        dbsession.add(self.challenge)
        dbsession.flush()
        self.data['challenge'] = str(self.challenge.id)
    
    @pytest.fixture(autouse=True)
    def _create_team(self, make_team, dbsession, pyramid_request, config):
        self.team = make_team()
        dbsession.add(self.team)
        dbsession.flush()
        pyramid_request.team = self.team

    def test_invalid_challenge(self):
        self.data['challenge'] = str(self.challenge.id + 1)
        form = self.make(self.data)
        assert not form.validate()
        assert 'challenge' in form.errors
