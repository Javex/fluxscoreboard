# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from datetime import datetime, timedelta
from fluxscoreboard.models.news import News, get_published_news
from fluxscoreboard.util import now
from sqlalchemy.exc import OperationalError
import pytest


class TestQueries(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_challenge, make_news):
        self.dbsession = dbsession
        self.make_challenge = make_challenge
        self.make_news = make_news

    def test_get_published_news(self):
        n = self.make_news(published=True)
        self.dbsession.add(n)
        assert get_published_news().one() is n

    def test_get_published_news_unpublished(self):
        n = self.make_news(published=False)
        self.dbsession.add(n)
        assert get_published_news().count() == 0

    def test_get_published_news_with_chall(self):
        c = self.make_challenge(published=True)
        n = self.make_news(challenge=c, published=True)
        self.dbsession.add(n)
        assert get_published_news().one() is n

    def test_get_published_news_with_chall_unpub(self):
        c = self.make_challenge(published=False)
        n = self.make_news(challenge=c, published=True)
        self.dbsession.add(n)
        assert get_published_news().count() == 0

    def test_get_published_news_with_chall_both_unpub(self):
        c = self.make_challenge(published=False)
        n = self.make_news(challenge=c, published=False)
        self.dbsession.add(n)
        assert get_published_news().count() == 0

    def test_get_published_news_with_chall_news_unpub(self):
        c = self.make_challenge(published=True)
        n = self.make_news(challenge=c, published=False)
        self.dbsession.add(n)
        assert get_published_news().count() == 0

    def test_get_published_news_ordered(self):
        n1 = self.make_news(published=True, timestamp=datetime.utcnow() - timedelta(1))
        n2 = self.make_news(published=True, timestamp=datetime.utcnow())
        self.dbsession.add_all([n1, n2])
        self.dbsession.flush()
        assert get_published_news().all() == [n2, n1]

    def test_get_published_news_without_future(self):
        n1 = self.make_news(published=True, timestamp=datetime.utcnow() + timedelta(1))
        self.dbsession.add(n1)
        self.dbsession.flush()
        assert get_published_news().count() == 0

class TestNews(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_team, make_challenge, make_news):
        self.dbsession = dbsession
        self.make_team = make_team
        self.make_challenge = make_challenge
        self.make_news = make_news

    def test_init(self):
        now_before = now() - timedelta(1)
        n = News()
        now_after = now() + timedelta(1)
        self.dbsession.add(n)
        self.dbsession.flush()
        self.dbsession.expire(n)
        assert n.timestamp > now_before
        assert n.timestamp < now_after

    def test_defaults(self):
        n = News()
        self.dbsession.add(n)
        assert n.published is None
        self.dbsession.flush()
        assert n.published is False

    def test_nullables(self):
        n = News()
        n.timestamp = None
        self.dbsession.add(n)
        self.dbsession.flush()

    def test_challenge(self):
        c = self.make_challenge()
        self.dbsession.add(c)
        n1 = News(message="Test1", timestamp=datetime(2012, 1, 1))
        c.announcements.append(n1)
        n2 = News(message="Test2")
        c.announcements.append(n2)
        assert c.announcements == [n1, n2]
        self.dbsession.flush()
        self.dbsession.expire(c)
        news = self.dbsession.query(News).all()
        for n in news:
            assert n.challenge == c
        assert c.announcements == [n2, n1]

    def test_printable(self):
        timestamp = datetime(2012, 1, 1)
        n = self.make_news(timestamp=timestamp)
        repr_ = repr(n)
        assert isinstance(repr_, str)
        assert ("<News id=None, from=2012-01-01 00:00:00, "
                "message=Bla<br>foo, challenge=None>") == repr_

        n = self.make_news(id=7, message="A" * 100,
                           challenge=self.make_challenge(),
                           timestamp=timestamp)
        repr(n)
        n = self.make_news(id=7, message="" * 10,
                           challenge=self.make_challenge(),
                           timestamp=timestamp)
        repr(n)


class TestMassMail(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, dbsession, make_massmail):
        self.dbsession = dbsession
        self.make_massmail = make_massmail

    def test_defaults(self):
        now_before = now() - timedelta(1)
        m = self.make_massmail()
        self.dbsession.add(m)
        self.dbsession.flush()
        self.dbsession.expire(m)
        now_after = now() + timedelta(1)
        assert m.timestamp > now_before
        assert m.timestamp < now_after

    def test_nullables(self, nullable_exc):
        mails = []
        for param in ["subject", "message", "recipients", "from_"]:
            mail = self.make_massmail()
            setattr(mail, param, None)
            mails.append(mail)
        for mail in mails:
            trans = self.dbsession.begin_nested()
            with pytest.raises(nullable_exc):
                self.dbsession.add(mail)
                self.dbsession.flush()
            trans.rollback()
