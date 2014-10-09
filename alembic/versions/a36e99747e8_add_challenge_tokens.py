"""Add challenge tokens

Revision ID: a36e99747e8
Revises: 3642c2df0f85
Create Date: 2014-07-19 17:18:08.028126

"""

# revision identifiers, used by Alembic.
revision = 'a36e99747e8'
down_revision = '3642c2df0f85'

from alembic import op
import sqlalchemy as sa
import fluxscoreboard as fs
import uuid


def upgrade():
    op.add_column('challenge', sa.Column('has_token', sa.Boolean, nullable=False))
    op.add_column('team', sa.Column('challenge_token', sa.Unicode(36), nullable=False))
    conn = op.get_bind()
    Team = fs.models.team.Team
    result = conn.execute(sa.select([Team.id]))
    for id_, in result:
        conn.execute(Team.__table__.update().where(Team.id == id_).
                     values(challenge_token=unicode(uuid.uuid4())))
    op.create_unique_constraint('uq_team_challenge_token', 'team', ['challenge_token'])


def downgrade():
    op.drop_constraint('uq_team_challenge_token', 'team', 'unique')
    op.drop_column('team', 'challenge_token')
    op.drop_column('challenge', 'has_token')
