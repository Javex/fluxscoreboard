# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.config import ROOT_DIR
from fluxscoreboard.models import Base, DBSession
from fluxscoreboard.models.team import get_team_by_ref
from fluxscoreboard.views.front import BaseView
from pyramid.renderers import render
from pyramid.view import view_config
from sqlalchemy.dialects.mysql import INTEGER
from sqlalchemy.orm import relationship, backref
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql.expression import func
from sqlalchemy.types import Integer, Unicode
from tempfile import mkdtemp
import csv
import logging
import os.path
import requests
import shutil
import socket
import zipfile


log = logging.getLogger(__name__)
allow_multiple = False
"""Whether multiple instances of this are allowed"""
# GeoIP database
db_url = 'http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip'


class FlagView(BaseView):
    @view_config(route_name='ref', renderer="json")
    def ref(self):
        """
        Public view that is invoked at the ``ref`` route to which a client
        delivers a ``ref_id`` by which a team is found. This ID is then used
        to find the team it belongs to and upgrade its flag count if the
        location the client was from was not already in the list of registered
        locations for the team.
        """
        ref_id = self.request.matchdict["ref_id"]
        team = get_team_by_ref(ref_id)
        loc = get_location(self.request.client_addr)
        ret = {'success': True}
        if loc is None:
            log.warn("No valid location returned for IP address '%s' for "
                     "team '%s' with ref id '%s'"
                     % (self.request.client_addr, team, ref_id))
            ret["success"] = False
            ret["msg"] = ("No location found. Try a different IP from that "
                            "range.")
            return ret
        ret["location"] = loc
        if loc not in [l.flag for l in team.flags]:
            team.flags.append(TeamFlag(team=team, flag=loc))
            ret["msg"] = "Location successfully registered."
        else:
            ret["msg"] = "Location already registered."
        return ret


class TeamFlag(Base):
    """
    Represent a quasi-many-to-many relationship between teams and flags. But
    the flags table is only present as a module-global variable and not in the
    database as it can be considered static (see :func:`install` for possible
    caveats).

    Recommended access to this is just going through a teams ``flags``
    attribute as it directly represents the flags already solves as a list of
    strings.

    .. todo::
        Once list is turned into a set of strings, update this documentation
        accordingly.
    """
    __tablename__ = 'team_flag'
    team_id = Column(Integer, ForeignKey('team.id'))
    flag = Column(Unicode(2), primary_key=True)
    team = relationship("Team",
                        backref=backref("team_flags",
                                        cascade="all, delete-orphan"))


class GeoIP(Base):
    """
    A mapping of an IP range to country codes. IP ranges are integers as they
    are natively anyway (4 blocks of 8 bit) and are stored this way for easier
    comparison.
    """
    ip_range_start = Column(INTEGER(unsigned=True), primary_key=True,
                            autoincrement=False)
    ip_range_end = Column(INTEGER(unsigned=True), nullable=False, unique=True)
    country_code = Column(Unicode(2), nullable=False)

    @staticmethod
    def ip_str(int_ip):
        """
        Turn an IP integer (such as those stored in the database) into a string
        for easier human-readable representation.
        """
        return socket.inet_ntoa(hex(int_ip)[2:].zfill(8).decode("hex"))

    @staticmethod
    def ip_int(str_ip):
        """
        Turn a human-readable string IP addressinto an integer IP address.
        """
        return int(socket.inet_aton(str_ip).encode("hex"), 16)


def display(challenge, request):
    """
    Render the output for the challenge view. Displays a description and a
    grid of flags that can be visited.
    """
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


def install(connection):
    geoip_fname = 'GeoIPCountryWhois.csv'
    try:
        r = requests.get(db_url)
    except Exception as e:
        # TODO: catch requests exception
        log.error("Could not download current database because requests "
                  "threw an exception. This only means that the database will "
                  "not be up to date but we will use the old cached version. "
                  "Requests reported the following: '%s'" % (e.msg))
    else:
        # TOD: Move new geoip file over to update it.
        tmpdir = mkdtemp()
        zipname = os.path.join(tmpdir, os.path.basename(db_url))
        with open(zipname, "w") as f:
            f.write(r.content)
        zip_ = zipfile.ZipFile(zipname)
        zip_.extractall(tmpdir)
        extracted_csv = os.path.join(tmpdir, geoip_fname)
        raise NotImplementedError("How to move a file?")
        shutil.rmtree(tmpdir)
    geoip_file = os.path.join(ROOT_DIR, 'data', geoip_fname)
    data = []
    available_country_codes = set()
    with open(geoip_file) as f:
        csv_ = csv.reader(f)
        for row in csv_:
            ip_int_start = int(row[2])
            ip_int_end = int(row[3])
            country_code = unicode(row[4].lower())
            if country_code not in flag_list:
                raise ValueError("The country code '%s' is not in the list of "
                                 "flags. It has the following data attached: "
                                 "'%s'" % row)
            available_country_codes.add(country_code)
            item = {'ip_range_start': ip_int_start,
                    'ip_range_end': ip_int_end,
                    'country_code': country_code}
            data.append(item)
    connection.execute(GeoIP.__table__.insert().values(data))
    unreachable_countries = set(flag_list) - available_country_codes
    if unreachable_countries:
        log.warning("There are a number of countries that will not be "
                    "reachable for the teams because it is not present in our "
                    "database even though we display their flag. These "
                    "are the country codes that cannot be reached: '%s'"
                    % list(unreachable_countries))


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
