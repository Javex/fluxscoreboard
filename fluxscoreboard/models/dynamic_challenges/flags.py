# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.models import Base, DBSession
from pyramid.renderers import render
from sqlalchemy.orm import relationship, backref
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql.expression import func
from sqlalchemy.types import Integer, Unicode
import logging
import socket
from sqlalchemy.dialects.mysql import INTEGER


log = logging.getLogger(__name__)


allow_multiple = False
"""Whether multiple instances of this are allowed"""


class TeamFlag(Base):
    team_id = Column(Integer, ForeignKey('team.id'))
    flag = Column(Unicode(2), primary_key=True)
    team = relationship("Team",
                        backref=backref("flags", cascade="all, delete-orphan"))


class GeoIP(Base):
    ip_range_start = Column(INTEGER(unsigned=True), primary_key=True,
                            autoincrement=False)
    ip_range_end = Column(INTEGER(unsigned=True), nullable=False)
    country_code = Column(Unicode(2), nullable=False)

    @staticmethod
    def ip_str(int_ip):
        return socket.inet_ntoa(hex(int_ip)[2:].zfill(8).decode("hex"))

    @staticmethod
    def ip_int(str_ip):
        return int(socket.inet_aton(str_ip).encode("hex"), 16)


def display(challenge, request):
    from fluxscoreboard.models.team import get_team
    flags = []
    team = get_team(request)
    solved_flags = 0
    team_flags = set(f.flag for f in team.flags)
    for row in xrange(15):
        flag_row = []
        for col in xrange(15):
            index = row * 15 + col
            if index < len(flag_list):
                flag = flag_list[index]
                visited = flag in team_flags
                if visited:
                    solved_flags += 1
                flag_row.append((flag, visited))
        flags.append(flag_row)
    params = {'challenge': challenge,
              'flags': flags,
              'flag_stats': (solved_flags, len(flag_list)),
              'team': team}
    return render('dynamic_flags.mako', params, request)


def points_query():
    from fluxscoreboard.models.team import Team
    subquery = (DBSession().query(func.count('*')).
                filter(TeamFlag.team_id == Team.id).
                correlate(Team))
    return subquery.as_scalar()


def get_location(ip):
    query = (DBSession().query(GeoIP.country_code).
             filter(GeoIP.ip_range_start <= GeoIP.ip_int(ip)).
             filter(GeoIP.ip_range_end >= GeoIP.ip_int(ip)))
    country_code, = query.first() or ("",)
    if country_code not in flag_list:
        log.info("Retrieved invalid country code '%s' for IP address %s. "
                 % (country_code, ip))
        return None
    else:
        return country_code


def title():
    return "Geolocation Flags (%s)" % __name__


flag_list = ['ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq',
             'ar', 'as', 'at', 'au', 'aw', 'az', 'ba', 'bb', 'bd', 'be',
             'bf', 'bg', 'bh', 'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs',
             'bt', 'bw', 'by', 'bz', 'ca', 'cg', 'cf', 'cd', 'ch', 'ci',
             'ck', 'cl', 'cm', 'cn', 'co', 'cr', 'cu', 'cv', 'cy', 'cz',
             'de', 'dj', 'dk', 'dm', 'do', 'dz', 'ec', 'ee', 'eg', 'eh',
             'er', 'es', 'et', 'fi', 'fj', 'fm', 'fo', 'fr', 'ga', 'gb',
             'gd', 'ge', 'gg', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp', 'gq',
             'gr', 'gt', 'gu', 'gw', 'gy', 'hk', 'hn', 'hr', 'ht', 'hu',
             'id', 'mc', 'ie', 'il', 'im', 'in', 'iq', 'ir', 'is', 'it',
             'je', 'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km', 'kn',
             'kp', 'kr', 'kw', 'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk',
             'lr', 'ls', 'lt', 'lu', 'lv', 'ly', 'ma', 'md', 'me', 'mg',
             'mh', 'mk', 'ml', 'mm', 'mn', 'mo', 'mq', 'mr', 'ms', 'mt',
             'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na', 'nc', 'ne', 'ng',
             'ni', 'nl', 'no', 'np', 'nr', 'nz', 'om', 'pa', 'pe', 'pf',
             'pg', 'ph', 'pk', 'pl', 'pr', 'ps', 'pt', 'pw', 'py', 'qa',
             're', 'ro', 'rs', 'ru', 'rw', 'sa', 'sb', 'sc', 'sd', 'se',
             'sg', 'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'st', 'sv',
             'sy', 'sz', 'tc', 'td', 'tg', 'th', 'tj', 'tl', 'tm', 'tn',
             'to', 'tr', 'tt', 'tv', 'tw', 'tz', 'ua', 'ug', 'us', 'uy',
             'uz', 'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu', 'ws', 'ye',
             'za', 'zm', 'zw']