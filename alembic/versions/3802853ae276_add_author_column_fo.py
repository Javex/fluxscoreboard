"""Add author column for challenge

Revision ID: 3802853ae276
Revises: 34020db8313e
Create Date: 2013-09-23 18:27:47.141216

"""
from __future__ import unicode_literals

# revision identifiers, used by Alembic.
revision = '3802853ae276'
down_revision = '34020db8313e'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('challenge', sa.Column('author', sa.Unicode(length=255),
                                         nullable=True))


def downgrade():
    op.drop_column('challenge', 'author')
