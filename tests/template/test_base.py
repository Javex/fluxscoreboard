# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from mako.template import Template
from tests.template import TemplateTestBase
from fluxscoreboard.util import now
from datetime import timedelta
import re
import pytest

pytestmark = pytest.mark.xfail


class TestBaseBody(TemplateTestBase):
    name = "base.mako"

    def load_template(self):
        self.tmpl = Template('<%inherit file="base.mako" />',
                             lookup=self.template_lookup)

    def test_body(self):
        data = self.render()
        head = data.find("head")
        script = lambda r: head.find("script", src=re.compile(r'.*%s$' % r))
        style = lambda r: head.find("link", href=re.compile(r'.*%s$' % r))
        assert not script("admin.js")
        assert not style("bootstrap.min.css")
        assert style("hacklu-base.min.css")
        adm_nav = data.find("body").find(
            "ul", class_=["nav navbar-nav pull-right"])
        assert not adm_nav
        assert not data.find(class_="navbar-admin")

    def test_body_admin(self):
        self.request.path = "/admin/asd"
        data = self.render()
        head = data.find("head")
        script = lambda r: head.find("script", src=re.compile(r'.*%s$' % r))
        style = lambda r: head.find("link", href=re.compile(r'.*%s$' % r))
        assert script("admin.js")
        assert style("bootstrap.min.css")
        assert not style("hacklu-base.min.css")
        adm_nav = data.find("body").find_all("ul", class_="nav")[1]
        assert adm_nav.find_all("li")[1].a.string == "Frontpage"
        menu = data.find("div", id="menu")
        assert "navbar-admin" in menu['class']

    def test_body_menu(self):
        self.request.path_url = self.request.route_url('home')
        self.view.menu.append(('home', "Home"))
        data = self.render()
        nav = data.find("ul", class_="menu")
        nav_entry = nav.find_all("li")[5]
        nav_link = nav_entry.a
        assert "active" in nav_entry["class"]
        assert "Home" == nav_link.string
        assert self.request.path_url == nav_link.attrs["href"]

    def test_body_flash_queues(self):
        for queue, css_type in [('', 'info'), ('error', 'danger'),
                                ('success', 'success'), ('warning', '')]:
            self.request.session.flash(css_type.upper(), queue)
            data = self.render()
            msg_div = data.find("div", class_=['alert'])
            classes = sorted(msg_div['class'])
            assert 'alert' in msg_div['class']
            if css_type:
                assert css_type.upper() == msg_div.string

    def test_global_announcement_without_design(self):
        self.settings.ctf_start_date = now() + timedelta(hours=1)
        self.test_global_announcement_with_design()

    def test_global_announcement_with_design(self):
        self.request.session.flash('TestWarningLol', 'warning')
        data = self.render()
        assert "TestWarningLol" in unicode(data)

    def test_global_announcement_wo_design_no_msg(self):
        self.settings.ctf_start_date = now() + timedelta(hours=1)
        self.test_global_announcement_w_design_no_msg()

    def test_global_announcement_w_design_no_msg(self):
        data = self.render()
        assert not data.find(class_='alert')


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
