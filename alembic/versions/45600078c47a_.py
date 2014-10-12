"""empty message

Revision ID: 45600078c47a
Revises: 3206a9f01fe8
Create Date: 2014-10-11 00:00:42.589225

"""

# revision identifiers, used by Alembic.
revision = '45600078c47a'
down_revision = '3206a9f01fe8'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('settings', sa.Column('global_announcement', sa.Unicode))


def downgrade():
    op.drop_column('settings', 'global_announcement')
