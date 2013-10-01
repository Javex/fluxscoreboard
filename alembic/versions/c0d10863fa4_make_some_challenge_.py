"""Make some challenge columns mandatory.

Revision ID: c0d10863fa4
Revises: 51d8bc17784c
Create Date: 2013-10-01 19:07:43.053890

"""
from alembic import op
from fluxscoreboard.models.challenge import Challenge
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'c0d10863fa4'
down_revision = '51d8bc17784c'



def upgrade():
    op.alter_column('challenge', 'title',
               existing_type=sa.Unicode(255),
               nullable=False)
    op.alter_column('challenge', 'online',
               existing_type=sa.Boolean,
               nullable=False)
    op.alter_column('challenge', 'manual',
               existing_type=sa.Boolean,
               nullable=False)
    op.execute(Challenge.__table__.update().
               where(~Challenge.dynamic).
               values({'dynamic': False}))
    op.alter_column('challenge', 'dynamic',
               existing_type=sa.Boolean,
               nullable=False)


def downgrade():
    op.alter_column('challenge', 'title',
               existing_type=sa.Unicode(255),
               nullable=True)
    op.alter_column('challenge', 'online',
               existing_type=sa.Boolean,
               nullable=True)
    op.alter_column('challenge', 'manual',
               existing_type=sa.Boolean,
               nullable=True)
    op.alter_column('challenge', 'dynamic',
               existing_type=sa.Boolean,
               nullable=True)
