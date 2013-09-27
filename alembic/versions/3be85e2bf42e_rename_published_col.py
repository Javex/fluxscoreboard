"""Rename 'published' column to 'online'

Revision ID: 3be85e2bf42e
Revises: 3802853ae276
Create Date: 2013-09-23 18:49:44.107466

"""

# revision identifiers, used by Alembic.
revision = '3be85e2bf42e'
down_revision = u'3802853ae276'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    op.alter_column('challenge', 'published',
                    type_=mysql.TINYINT(display_width=1),
                    new_column_name='online')


def downgrade():
    op.alter_column('challenge', 'online',
                    type_=mysql.TINYINT(display_width=1),
                    new_column_name='published')
