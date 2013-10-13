# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
import pytest


@pytest.mark.usefixtures("matched_route", "config")
class TemplateTestBase(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, pyramid_request, view, template_lookup, get_template):
        self.template_lookup = template_lookup
        self.get = get_template
        self.request = pyramid_request
        self.view = view
        self.load_template()

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
