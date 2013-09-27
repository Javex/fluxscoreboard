"""Add settings table

Revision ID: 34020db8313e
Revises: None
Create Date: 2013-09-10 00:56:16.201199

"""
from alembic import op
from fluxscoreboard.models.settings import Settings
from fluxscoreboard.models.types import TZDateTime
from sqlalchemy.types import Boolean
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '34020db8313e'
down_revision = None


def upgrade():
    op.create_table('settings',
    sa.Column('id', sa.Integer(), primary_key=True),
    sa.Column('submission_disabled', Boolean, default=False),
    sa.Column('ctf_start_date', TZDateTime(), nullable=True),
    mysql_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )

    default_settings = {'ctf_start_date': None}
    op.bulk_insert(Settings.__table__, [default_settings])


def downgrade():
    op.drop_table('settings')
