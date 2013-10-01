# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models.country import get_all_countries, Country


def test_get_all_countries(dbsession, countries):
    q = get_all_countries()
    assert q.count() == len(countries)
    assert set(q) == set(countries)


def test_Country_printable():
    c = Country(name="Täst")
    str_ = str(c)
    uni = unicode(c)
    assert isinstance(uni, unicode)
    assert uni == "Täst"
    assert isinstance(str_, str)
    assert str_ == b"Täst"
