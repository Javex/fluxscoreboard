"""Make registration token nullable

Revision ID: 2b8284c16559
Revises: a36e99747e8
Create Date: 2014-07-28 21:02:56.262567

"""

# revision identifiers, used by Alembic.
revision = '2b8284c16559'
down_revision = '22de130331c0'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    op.alter_column('team', 'token',
                    existing_type=mysql.VARCHAR(length=64),
                    nullable=True)


def downgrade():
    op.alter_column('team', 'token',
                    existing_type=mysql.VARCHAR(length=64),
                    nullable=False)
