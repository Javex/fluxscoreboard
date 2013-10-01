"""Rename teamflag table to team_flag.

Revision ID: 3749701957db
Revises: 370d26ee0e47
Create Date: 2013-10-01 18:27:05.487192

"""

# revision identifiers, used by Alembic.
revision = '3749701957db'
down_revision = '370d26ee0e47'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.rename_table(u'teamflag', u'team_flag')


def downgrade():
    op.rename_table(u'team_flag', u'teamflag')
