"""Add feedback table

Revision ID: 3e5d30f79ca
Revises: 45600078c47a
Create Date: 2014-10-14 17:34:18.368063

"""

# revision identifiers, used by Alembic.
revision = '3e5d30f79ca'
down_revision = '426225d44c6a'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'feedback',
        sa.Column('team_id', sa.Integer, primary_key=True),
        sa.Column('challenge_id', sa.Integer, primary_key=True),
        sa.Column('rating', sa.Integer),
        sa.Column('note', sa.Unicode),
        sa.ForeignKeyConstraint(['challenge_id'], [u'challenge.id'], ),
        sa.ForeignKeyConstraint(['team_id'], [u'team.id'], ),
    )


def downgrade():
    op.drop_table('feedback')
