"""Require a team for each team_flag entry

Revision ID: 388e5a30d0d6
Revises: c0d10863fa4
Create Date: 2013-10-09 21:55:19.870309

"""

# revision identifiers, used by Alembic.
revision = '388e5a30d0d6'
down_revision = 'c0d10863fa4'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    op.alter_column(u'team_flag', 'team_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)


def downgrade():
    op.alter_column(u'team_flag', 'team_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
