"""Add protocols challenge

Revision ID: 9bb80708bd9
Revises: 3e5d30f79ca
Create Date: 2014-10-21 22:09:43.495308

"""

# revision identifiers, used by Alembic.
revision = '9bb80708bd9'
down_revision = '3e5d30f79ca'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'protocol',
        sa.Column('id', sa.Integer, nullable=False),
        sa.Column('name', sa.Unicode, nullable=False),
        sa.Column('flag', sa.Unicode, nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_table(
        'protocols_team',
        sa.Column('team_id', sa.Integer, nullable=False),
        sa.Column('protocol_id', sa.Integer, nullable=False),
        sa.ForeignKeyConstraint(['protocol_id'], ['protocol.id'], ),
        sa.ForeignKeyConstraint(['team_id'], ['team.id'], ),
        sa.PrimaryKeyConstraint('team_id', 'protocol_id')
    )


def downgrade():
    op.drop_table('protocols_team')
    op.drop_table('protocol')
