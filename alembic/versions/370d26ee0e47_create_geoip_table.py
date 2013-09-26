"""Create GeoIP table

Revision ID: 370d26ee0e47
Revises: 283002a0925f
Create Date: 2013-09-25 23:17:18.767041

"""
from alembic import op
from tempfile import mkdtemp
import os
import requests
import sqlalchemy as sa
from sqlalchemy.dialects.mysql import INTEGER
import zipfile
import csv
from fluxscoreboard.models.dynamic_challenges.flags import GeoIP
import shutil

# revision identifiers, used by Alembic.
revision = '370d26ee0e47'
down_revision = '283002a0925f'

# GeoIP database
db_url = 'http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip'


def upgrade():
    # Download first (so on error we stop)
    r = requests.get(db_url)
    tmpdir = mkdtemp()
    zipname = os.path.join(tmpdir, os.path.basename(db_url))
    with open(zipname, "w") as f:
        f.write(r.content)

    op.create_table('geoip',
    sa.Column('ip_range_start', INTEGER(unsigned=True), nullable=False,
              autoincrement=False),
    sa.Column('ip_range_end', INTEGER(unsigned=True), nullable=False),
    sa.Column('country_code', sa.Unicode(length=2), nullable=False),
    sa.PrimaryKeyConstraint('ip_range_start'),
    mysql_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )
    zip_ = zipfile.ZipFile(zipname)
    zip_.extractall(tmpdir)
    with open(os.path.join(tmpdir, 'GeoIPCountryWhois.csv')) as f:
        csv_ = csv.reader(f)
        data = []
        ip_start_set = set()
        ip_start_map = {}
        for row in csv_:
            ip_int_start = int(row[2])
            ip_int_end = int(row[3])
            country_code = row[4].lower()
            item = {'ip_range_start': ip_int_start,
                    'ip_range_end': ip_int_end,
                    'country_code': unicode(country_code)}
            ip_start_map[ip_int_start] = item
            ip_start_set.add(ip_int_start)
            data.append(item)
    # MySQL was crying like a little baby when it had to process all 80k rows
    # at once, so we give it 10k chunks.
    for index, item in enumerate(data):
        if index % 10000 == 0:
            if index != 0:
                op.bulk_insert(GeoIP.__table__, tmpdata)
            tmpdata = []
        tmpdata.append(item)
    if tmpdata:
        op.bulk_insert(GeoIP.__table__, tmpdata)
    shutil.rmtree(tmpdir)


def downgrade():
    op.drop_table('geoip')
