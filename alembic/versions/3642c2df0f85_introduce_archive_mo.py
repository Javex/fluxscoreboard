"""Introduce archive mode setting

Revision ID: 3642c2df0f85
Revises: 3c088bbc050c
Create Date: 2013-11-07 15:25:36.884717

"""
from fluxscoreboard.models.settings import Settings

# revision identifiers, used by Alembic.
revision = '3642c2df0f85'
down_revision = '3c088bbc050c'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('settings', sa.Column('archive_mode', sa.Boolean(),
                                        nullable=False))
    op.execute(Settings.__table__.update().values(archive_mode=False))


def downgrade():
    op.drop_column('settings', 'archive_mode')
