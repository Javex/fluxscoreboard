"""Add challenge published flag

Revision ID: 2052bc64ecfb
Revises: 228a282cce01
Create Date: 2013-10-21 20:43:48.118058

"""
from fluxscoreboard.models.challenge import Challenge

# revision identifiers, used by Alembic.
revision = '2052bc64ecfb'
down_revision = '228a282cce01'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('challenge', sa.Column('published', sa.Boolean()))
    op.execute(Challenge.__table__.update().
               values(published=False))
    op.alter_column('challenge', 'published', nullable=False,
                    existing_type=sa.Boolean())


def downgrade():
    op.drop_column('challenge', 'published')
