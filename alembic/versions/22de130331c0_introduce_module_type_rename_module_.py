"""Introduce module type, rename module_name to module

Revision ID: 22de130331c0
Revises: a36e99747e8
Create Date: 2014-07-28 16:43:58.254590

"""

# revision identifiers, used by Alembic.
revision = '22de130331c0'
down_revision = 'a36e99747e8'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    op.alter_column('challenge', 'module_name', new_column_name='module', type_=sa.Unicode(255))


def downgrade():
    op.alter_column('challenge', 'module', new_column_name='module_name', type_=sa.Unicode(255))
