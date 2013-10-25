# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from conftest import dbsettings
from mako.template import Template
from tests.template import TemplateTestBase
import pytest
import re


class TestBaseBody(TemplateTestBase):
    name = "base.mako"

    def load_template(self):
        self.tmpl = Template('<%inherit file="base.mako" />',
                             lookup=self.template_lookup)

    def test_body(self):
        data = self.render()
        assert "admin.js" not in data
        assert "bootstrap.min.css" not in data
        assert "hacklu-base.min.css" in data
        assert "Frontpage" not in data
        assert "navbar-admin" not in data

    def test_body_admin(self):
        self.request.path = "/admin/asd"
        data = self.render()
        assert "admin.js" in data
        assert "bootstrap.min.css" in data
        assert "hacklu-base.min.css" not in data
        assert "navbar-admin" in data
        assert "Frontpage" in data

    def test_body_menu(self):
        self.request.path_url = self.request.route_url('home')
        self.view.menu.append(('home', "Home"))
        data = self.render()
        assert "active" in data
        assert "Home" in data
        assert self.request.path_url in data

    def test_body_flash_queues(self):
        for queue, css_type in [('', 'info'), ('error', 'danger'),
                                ('success', 'success'), ('warning', '')]:
            self.request.session.flash(css_type.upper(), queue)
            data = self.render()
            assert css_type.upper() in data
            assert 'class="alert %s"' % ('alert-%s' % css_type if css_type
                                         else '') in data


class TestRenderFlash(TemplateTestBase):

    _alert_info = re.compile(r'class=".*alert-info.*"')
    _alert_css_test = re.compile(r'class=".*alert-css-test.*"')
    name = "base.mako"

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
