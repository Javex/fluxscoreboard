# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime
from fluxscoreboard.models.news import News
from sqlalchemy.exc import OperationalError
import pytest


class TestNews(object):

    def test_init(self):
        now_before = datetime.utcnow()
        n = News()
        now_after = datetime.utcnow()
        assert n.timestamp > now_before
        assert n.timestamp < now_after

    def test_defaults(self, dbsession):
        n = News()
        dbsession.add(n)
        assert n.published is None
        dbsession.flush()
        assert n.published is False

    def test_nullables(self, dbsession):
        n = News()
        n.timestamp = None
        dbsession.add(n)
        dbsession.flush()

    def test_challenge(self, dbsession, make_team, make_challenge):
        c = make_challenge()
        dbsession.add(c)
        n1 = News(message="Test1", timestamp=datetime(2012, 1, 1))
        c.announcements.append(n1)
        n2 = News(message="Test2")
        c.announcements.append(n2)
        assert c.announcements == [n1, n2]
        dbsession.flush()
        dbsession.expire(c)
        news = dbsession.query(News).all()
        for n in news:
            assert n.challenge == c
        assert c.announcements == [n2, n1]

    def test_printable(self, dbsession, make_challenge):
        def mk_news(**kw):
            kw.setdefault("timestamp", datetime(2012, 1, 1))
            return News(**kw)
        n = mk_news()
        repr_ = repr(n)
        assert isinstance(repr_, str)
        assert ("<News id=None, from=2012-01-01 00:00:00, "
                "message=None, challenge=None>") == repr_

        n = mk_news(id=7, message="A" * 100, challenge=make_challenge())
        repr(n)
        n = mk_news(id=7, message="" * 10, challenge=make_challenge())
        repr(n)


class TestMassMail(object):

    def test_defaults(self, dbsession, make_massmail):
        now_before = datetime.utcnow()
        m = make_massmail()
        dbsession.add(m)
        dbsession.flush()
        now_after = datetime.utcnow()
        assert m.timestamp > now_before
        assert m.timestamp < now_after

    def test_nullables(self, dbsession, make_massmail, nullable_exc):
        mails = []
        for param in ["subject", "message", "recipients", "from_"]:
            mail = make_massmail()
            setattr(mail, param, None)
            mails.append(mail)
        for mail in mails:
            trans = dbsession.begin_nested()
            with pytest.raises(nullable_exc):
                dbsession.add(mail)
                dbsession.flush()
            trans.rollback()
