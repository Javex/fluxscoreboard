"""Remove primary key on team_flag.flag and make it unique instead

Revision ID: 3dfaafdee0a8
Revises: 3eb8226f67ad
Create Date: 2013-10-22 11:17:40.937084

"""

# revision identifiers, used by Alembic.
revision = '3dfaafdee0a8'
down_revision = u'3eb8226f67ad'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    op.alter_column('team_flag', 'flag', nullable=True,
                    existing_type=sa.Unicode(2))
    op.execute("ALTER TABLE team_flag DROP PRIMARY KEY, "
               "ADD PRIMARY KEY (team_id, flag)")


def downgrade():
    op.alter_column('team_flag', 'flag', nullable=False,
                    existing_type=sa.Unicode(2))
