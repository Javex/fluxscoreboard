"""Make column name on table team unique

Revision ID: 263f849107af
Revises: 3be85e2bf42e
Create Date: 2013-10-16 09:51:01.754634

"""

# revision identifiers, used by Alembic.
revision = '263f849107af'
down_revision = '3be85e2bf42e'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    conn = op.get_bind()
    query_str = ('SELECT t1.id FROM team AS t1 WHERE EXISTS (SELECT t2.id '
                 'FROM team AS t2 WHERE t2.id != t1.id AND t2.name = t1.name)')
    duplicate_teams_query = conn.execute(query_str)
    duplicate_teams = [id_ for id_, in duplicate_teams_query.fetchall()]
    if duplicate_teams:
        raise ValueError("The following team IDs have the same name : %s. "
                         "Please manually adjust the duplicate teams by "
                         "removing/renaming them, then run this again."
                         % duplicate_teams)
    op.create_unique_constraint("uq_team_name", 'team', ['name'])


def downgrade():
    op.drop_constraint("uq_team_name", "team", "unique")
