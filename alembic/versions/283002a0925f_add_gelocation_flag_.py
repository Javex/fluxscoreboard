"""Add geolocation flag support

Revision ID: 283002a0925f
Revises: 3be85e2bf42e
Create Date: 2013-09-25 20:23:37.662903

"""
from alembic import op
from fluxscoreboard.models.team import Team, ref_token
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '283002a0925f'
down_revision = '3be85e2bf42e'


def upgrade():
    op.add_column('challenge', sa.Column('dynamic', sa.Boolean(),
                                         nullable=True))
    op.add_column('challenge', sa.Column('module_name', sa.Unicode(length=255),
                                         nullable=True))
    op.add_column('team', sa.Column('ref_token', sa.Unicode(length=15),
                                    nullable=False))
    op.create_table('teamflag',
    sa.Column('team_id', sa.Integer(), nullable=True),
    sa.Column('flag', sa.Unicode(length=2), nullable=False),
    sa.ForeignKeyConstraint(['team_id'], [u'team.id'],),
    sa.PrimaryKeyConstraint('flag'),
    mysql_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )

    conn = op.get_bind()
    teams = conn.execute("SELECT id FROM team")
    team = Team.__table__
    for team_id, in teams:
        op.execute(team.update().
                   where(team.c.id == team_id).
                   values({'ref_token': ref_token()}))

    op.create_unique_constraint(None, 'team', ['ref_token'])


def downgrade():
    op.drop_column('team', 'ref_token')
    op.drop_column('challenge', 'module_name')
    op.drop_column('challenge', 'dynamic')
    op.drop_table('teamflag')
