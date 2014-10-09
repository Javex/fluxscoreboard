import pytest
from fluxscoreboard.forms import CSRFForm
from webob.multidict import MultiDict
from conftest import GeneralCSRFTest

class TestCSRFForm(GeneralCSRFTest):

    _form = CSRFForm

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request):
        self.request = pyramid_request
        token = self.request.session.get_csrf_token()
        self._data = MultiDict([('csrf_token', token)])

    def test_generate(self):
        form = self.make(self.data)
        token = form.generate_csrf_token(self.request)
        assert token == self.request.session.get_csrf_token()
