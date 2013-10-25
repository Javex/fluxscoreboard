"""Make category's name column mandatory.

Revision ID: 51d8bc17784c
Revises: 3749701957db
Create Date: 2013-10-01 18:30:40.969735

"""

# revision identifiers, used by Alembic.
revision = '51d8bc17784c'
down_revision = '3749701957db'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    op.alter_column('category', 'name',
               existing_type=mysql.VARCHAR(length=255),
               nullable=False)


def downgrade():
    op.alter_column('category', 'name',
               existing_type=mysql.VARCHAR(length=255),
               nullable=True)
