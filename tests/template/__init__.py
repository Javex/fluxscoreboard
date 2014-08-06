# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
import pytest
from fluxscoreboard.util import now
from datetime import timedelta
from webob.multidict import MultiDict
from mock import MagicMock


@pytest.mark.usefixtures("matched_route", "config")
class TemplateTestBase(object):

    _data = None

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request, view, template_lookup, get_template,
                 dbsettings, countries):
        self.template_lookup = template_lookup
        self.get = get_template
        self.request = pyramid_request
        self.view = view
        self.load_template()
        self.countries = countries
        self.settings = dbsettings
        self.settings.ctf_end_date = now() + timedelta(1)
        self.settings.ctf_start_date = now() - timedelta(1)
        self.request.settings.ctf_start_date = now() - timedelta(1)
        self.request.settings.ctf_end_date = now() + timedelta(1)

        if not hasattr(self.request, 'team'):
            self.request.team = None

    def get_def(self, name):
        original = self.tmpl.get_def(name)

        def _render(*args, **kwargs):
            return original.render_unicode(*args, request=self.request,
                                           **kwargs).strip()
        return _render

    def render(self, *args, **kwargs):
        return self.tmpl.render_unicode(*args, request=self.request,
                                        view=self.view, **kwargs).strip()

    def load_template(self):
        self.tmpl = self.get(self.name)

    def form(self, with_validation=True, **kw):
        ip = self.request.client_addr
        self.data["csrf_token"] = self.request.session.get_csrf_token()
        self.data.update(self._make_form_data())
        self.data.update(kw)
        form = self._form(self.data, csrf_context=self.request,
                          captcha={'ip_address': ip})
        if with_validation:
            form.validate()
        return form

    @property
    def data(self):
        if not self._data:
            self._data = MultiDict()
        return self._data

    def _make_form_data(self):
        return MultiDict()

    @pytest.fixture
    def module(self, request):
        from fluxscoreboard.models import dynamic_challenges
        module = MagicMock()
        dynamic_challenges.registry[u"testmodule"] = module
        module.points_query.return_value = 1
        module.points.return_value = 1

        def remove_module():
            del dynamic_challenges.registry[u"testmodule"]
        request.addfinalizer(remove_module)
        return module
