"""Add CTF end date column to settings table

Revision ID: 228a282cce01
Revises: 388e5a30d0d6
Create Date: 2013-10-16 21:04:56.416411

"""

# revision identifiers, used by Alembic.
revision = '228a282cce01'
down_revision = '388e5a30d0d6'

from alembic import op
import sqlalchemy as sa
from fluxscoreboard.models import types


def upgrade():
    op.add_column('settings', sa.Column('ctf_end_date', types.TZDateTime,
                                        nullable=True))


def downgrade():
    op.drop_column('settings', 'ctf_end_date')
