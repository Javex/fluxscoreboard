# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
import pytest
import re


class TestBase(object):

    _alert_info = re.compile(r'class=".*alert-info.*"')
    _alert_css_test = re.compile(r'class=".*alert-css-test.*"')
    name = "base.mako"

    @pytest.fixture(autouse=True)
    def _prepare(self, get_template, pyramid_request):
        self.get = get_template
        self.tmpl = self.get(self.name)
        self.request = pyramid_request

    def get_def(self, name):
        original = self.tmpl.get_def("render_flash")

        def _render(*args, **kwargs):
            return original.render_unicode(*args, request=self.request,
                                           **kwargs).strip()
        return _render

    def test_render_flash_empty(self):
        def_ = self.get_def("render_flash")
        assert not def_().strip()

    def test_render_flash(self):
        def_ = self.get_def("render_flash")
        self.request.session.flash("Test")
        ret = def_()
        print(ret)
        assert len(ret.splitlines()) == 1
        assert "Test" in ret
        assert self._alert_info.search(ret)

    def test_render_flash_queue(self):
        def_ = self.get_def("render_flash")
        self.request.session.flash("Test", "error")
        ret = def_(queue='error')
        assert "Test" in ret
        assert len(ret.splitlines()) == 1
        assert self._alert_info.search(ret)

    def test_render_flash_css(self):
        def_ = self.get_def("render_flash")
        self.request.session.flash("Test")
        ret = def_(css_type='css-test')
        assert "Test" in ret
        assert len(ret.splitlines()) == 1
        assert not self._alert_info.search(ret)
        assert self._alert_css_test.search(ret)

    def test_render_flash_multiple(self):
        def_ = self.get_def("render_flash")
        self.request.session.flash("Test1")
        self.request.session.flash("Test2")
        ret = def_()
        lines = ret.splitlines()
        assert len(lines) == 2
        assert "Test1" in lines[0]
        assert "Test2" in lines[1]

    def test_render_flash_different_queues(self):
        def_ = self.get_def("render_flash")
        self.request.session.flash("Test1")
        self.request.session.flash("Test2", 'error')
        ret = def_()
        lines = ret.splitlines()
        assert len(lines) == 1
        assert "Test1" in lines[0]
        assert "Test2" not in ret
