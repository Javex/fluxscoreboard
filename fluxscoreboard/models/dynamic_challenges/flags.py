# encoding: utf-8
from __future__ import unicode_literals, print_function, absolute_import
from fluxscoreboard.config import ROOT_DIR
from fluxscoreboard.models import Base, DBSession, settings
from fluxscoreboard.models.challenge import Challenge
from fluxscoreboard.models.team import get_team_by_ref
from fluxscoreboard.util import now
from fluxscoreboard.views.front import BaseView
from pyramid.renderers import render
from pyramid.view import view_config
from requests.exceptions import RequestException
from sqlalchemy.orm import relationship, backref
from sqlalchemy.orm.exc import NoResultFound, MultipleResultsFound
from sqlalchemy.orm.mapper import validates
from sqlalchemy.schema import ForeignKey, Column
from sqlalchemy.sql.expression import func
from sqlalchemy.types import Integer, Unicode, BigInteger
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
        try:
            challenge = (DBSession().query(Challenge).
                         filter(Challenge.module_name == 'flags').one())
        except NoResultFound:
            ret = {'success': False, 'msg': ("There is no challenge for flags "
                                             "right now")}
            return ret
        except MultipleResultsFound:
            ret = {'success': False, 'msg': ("More than one challenge is "
                                             "online. This shouldn't happen, "
                                             "contact FluxFingers.")}
            return ret
        if (not challenge.online or
                self.request.settings.submission_disabled or
                now() > self.request.settings.ctf_end_date):
            ret = {'success': False}
            if not challenge.online:
                ret["msg"] = "Challenge is offline."
            elif self.request.settings.submission_disabled:
                ret["msg"] = "Submission is disabled."
            elif now() > self.request.settings.ctf_end_date:
                ret["msg"] = "CTF is over."
            return ret
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
        try:
            team.flags.append(loc)
            DBSession().flush()
        except Exception:
            ret["msg"] = "Location already registered."
        else:
            ret["msg"] = "Location successfully registered."
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
    team_id = Column(Integer, ForeignKey('team.id'), primary_key=True)
    flag = Column(Unicode(2), primary_key=True)
    team = relationship("Team",
                        backref=backref("team_flags",
                                        cascade="all, delete-orphan"))

    def __init__(self, flag, **kwargs):
        kwargs["flag"] = flag
        Base.__init__(self, **kwargs)


class GeoIP(Base):
    """
    A mapping of an IP range to country codes. IP ranges are integers as they
    are natively anyway (4 blocks of 8 bit) and are stored this way for easier
    comparison.
    """
    ip_range_start = Column(BigInteger, primary_key=True,
                            autoincrement=False)
    ip_range_end = Column(BigInteger, nullable=False, unique=True, index=True)
    country_code = Column(Unicode(2), nullable=False)

    @staticmethod
    def ip_str(int_ip):
        """
        Turn an IP integer (such as those stored in the database) into a string
        for easier human-readable representation.
        """
        hex_ = hex(int_ip)[2:]
        if hex_.endswith("L"):
            hex_ = hex_[:-1]
        return socket.inet_ntoa(hex_.zfill(8).decode("hex"))

    @staticmethod
    def ip_int(str_ip):
        """
        Turn a human-readable string IP addressinto an integer IP address.
        """
        return int(socket.inet_aton(str_ip).encode("hex"), 16)

    @validates('ip_range_start', 'ip_range_end')
    def check_ip_range(self, key, ip):
        assert ip <= 0xFFFFFFFF
        assert ip >= 0
        return ip


def display(challenge, request):
    """
    Render the output for the challenge view. Displays a description and a
    grid of flags that can be visited.
    """
    from fluxscoreboard.models.team import get_team
    flags = []
    team = get_team(request)
    solved_flags = 0
    team_flags = set(team.flags)
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


def points_query(cls=None):
    """
    Returns a scalar query element that can be used in a ``SELECT`` statement
    to be added to the points query. The parameter ``cls`` can be anything
    that SQLAlchemy can correlate on. If left empty, it defaults to the
    standard :cls`fluxscoreboard.models.team.Team`, which is normally fine.
    However, if multiple teams are involved (as with the ranking algorithm)
    one might pass in an alias like this:

    .. code-block:: python
        inner_team = aliased(Team)
        dynamic_points = flags.points_query(inner_team)

    This will then correlate on a specific alias of ``Team`` instead of the
    default class.
    """
    if cls is None:
        from fluxscoreboard.models.team import Team
        cls = Team
    subquery = (DBSession().query(func.count('*')).
                filter(TeamFlag.team_id == cls.id).
                correlate(cls))
    return func.coalesce(subquery.as_scalar(), 0)


def points(team):
    return len(team.flags)


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


def install(connection, with_update=True):
    geoip_fname = 'GeoIPCountryWhois.csv'
    geoip_file = os.path.join(ROOT_DIR, 'data', geoip_fname)
    if with_update:
        try:
            r = requests.get(db_url)
        except RequestException as e:
            log.error("Could not download current database because requests "
                      "threw an exception. This only means that the database will "
                      "not be up to date but we will use the old cached version. "
                      "Requests reported the following: '%s'" % e)
        else:
            tmpdir = mkdtemp()
            zipname = os.path.join(tmpdir, os.path.basename(db_url))
            with open(zipname, "w") as f:
                f.write(r.content)
            zip_ = zipfile.ZipFile(zipname)
            zip_.extractall(tmpdir)
            extracted_csv = os.path.join(tmpdir, geoip_fname)
            shutil.move(extracted_csv, geoip_file)
            shutil.rmtree(tmpdir)
    data = []
    available_country_codes = set()
    with open(geoip_file) as f:
        csv_ = csv.reader(f)
        for row in csv_:
            ip_int_start = int(row[2])
            ip_int_end = int(row[3])
            country_code = unicode(row[4].lower())
            if country_code not in flag_list:
                if country_code in flag_exceptions:
                    # Don't import it
                    continue
                else:
                    raise ValueError("The country code '%s' is not in the "
                                     "list of flags. It has the following "
                                     "data attached: '%s'"
                                     % (country_code, row))
            available_country_codes.add(country_code)
            item = {'ip_range_start': ip_int_start,
                    'ip_range_end': ip_int_end,
                    'country_code': country_code}
            data.append(item)
    log.info("Adding %d rows to database" % len(data))
    dialect = connection.dialect.name
    if dialect == "sqlite":
        chunk_size = 300
    elif dialect == "mysql":
        chunk_size = 10000
    else:
        chunk_size = len(data)

    while data:
        connection.execute(GeoIP.__table__.insert().values(data[:chunk_size]))
        data = data[chunk_size:]
    unreachable_countries = set(flag_list) - available_country_codes
    if unreachable_countries:
        log.warning("There are a number of countries that will not be "
                    "reachable for the teams because it is not present in our "
                    "database even though we display their flag. These "
                    "are the country codes that cannot be reached: '%s'"
                    % list(unreachable_countries))


flag_list = ['ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'ao', 'aq',
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


# These are flags that exist in the original database but we do not recognize
# them
flag_exceptions = set(['eu', 'a2', 'yt', 'ap', 'tk', 'wf', 'cw', 'ss', 'a1',
                       'sh', 'cx', 'mf', 'gs', 'gf', 'cc', 'bl', 'nf', 'um',
                       'sj', 'bq', 'sx', 'mp', 'io', 'tf', 'ax', 'fk', 'pn',
                       'nu', 'pm'])
