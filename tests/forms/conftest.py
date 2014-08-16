import pytest
from webob.multidict import MultiDict

class GeneralFormTest(object):
    
    _data = None

    @property
    def data(self):
        if self._data is None:
            self._data = MultiDict()
        return self._data

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request):
        self.request = pyramid_request
        data = self._make_data()
        for k, v in data:
            self.data[k] = v

    def make(self, data):
        return self._form(data, csrf_context=self.request)

    def test_valid(self):
        form = self.make(self.data)
        assert form.validate()


class GeneralCSRFTest(GeneralFormTest):

    def test_validate(self):
        form = self.make(self.data)
        assert form.validate()

    def test_validate_invalid_token(self):
        self.data["csrf_token"] = '0'
        form = self.make(self.data)
        assert not form.validate()

    def test_missing_token(self):
        form = self._form(csrf_context=self.request)
        assert not form.validate()


    @pytest.fixture(autouse=True)
    def _init_csrf_token(self, pyramid_request):
        token = pyramid_request.session.get_csrf_token()
        self.data['csrf_token'] = token
