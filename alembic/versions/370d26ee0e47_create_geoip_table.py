"""Create GeoIP table

Revision ID: 370d26ee0e47
Revises: 283002a0925f
Create Date: 2013-09-25 23:17:18.767041

"""
from alembic import op
from fluxscoreboard.models import dynamic_challenges
from sqlalchemy.dialects.mysql import INTEGER
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '370d26ee0e47'
down_revision = '283002a0925f'


def upgrade():
    op.create_table('geoip',
    sa.Column('ip_range_start', INTEGER(unsigned=True), nullable=False,
              autoincrement=False),
    sa.Column('ip_range_end', INTEGER(unsigned=True), nullable=False,
              unique=True),
    sa.Column('country_code', sa.Unicode(length=2), nullable=False),
    sa.PrimaryKeyConstraint('ip_range_start'),
    mysql_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )
    dynamic_challenges.flags.install(op.get_bind())


def downgrade():
    op.drop_table('geoip')
