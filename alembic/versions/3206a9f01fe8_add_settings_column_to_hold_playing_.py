"""Add settings column to hold playing team count

Revision ID: 3206a9f01fe8
Revises: 2b8284c16559
Create Date: 2014-09-13 20:57:34.190550

"""

# revision identifiers, used by Alembic.
revision = '3206a9f01fe8'
down_revision = '2b8284c16559'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    op.alter_column('challenge', 'points', new_column_name='base_points', existing_type=sa.Integer)
    op.add_column('settings', sa.Column('playing_teams', sa.Integer(), nullable=False))
    op.alter_column('submission', 'bonus', new_column_name='additional_pts', existing_type=sa.Integer)


def downgrade():
    op.drop_column('settings', 'playing_teams')
    op.alter_column('challenge', 'base_points', new_column_name='points', existing_type=sa.Integer)
    op.alter_column('submission', 'additional_pts', new_column_name='bonus', existing_type=sa.Integer)
