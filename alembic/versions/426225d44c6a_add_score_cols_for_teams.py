"""Add score cols for teams

Revision ID: 426225d44c6a
Revises: 45600078c47a
Create Date: 2014-10-19 13:31:14.537259

"""

# revision identifiers, used by Alembic.
revision = '426225d44c6a'
down_revision = '3e5d30f79ca'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    op.add_column('team', sa.Column('base_score', sa.Integer(), server_default=u'0', nullable=False))
    op.add_column('team', sa.Column('bonus_score', sa.Integer(), server_default=u'0', nullable=False))


def downgrade():
    op.drop_column('team', 'bonus_score')
    op.drop_column('team', 'base_score')
