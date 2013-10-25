"""Add IP collector table

Revision ID: 3c088bbc050c
Revises: 3dfaafdee0a8
Create Date: 2013-10-22 14:59:51.119834

"""

# revision identifiers, used by Alembic.
revision = '3c088bbc050c'
down_revision = '3dfaafdee0a8'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(u'team_ip',
    sa.Column('team_id', sa.Integer(), nullable=False),
    sa.Column('ip', sa.Unicode(length=15), nullable=False),
    sa.ForeignKeyConstraint(['team_id'], [u'team.id'],),
    sa.PrimaryKeyConstraint('team_id', 'ip'),
    mysql_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )


def downgrade():
    op.drop_table(u'team_ip')
