"""Rename binary to reversing. Add two new categories.

Revision ID: 3eb8226f67ad
Revises: 2052bc64ecfb
Create Date: 2013-10-21 21:35:34.710938

"""
from __future__ import unicode_literals
from fluxscoreboard.models.challenge import Category

# revision identifiers, used by Alembic.
revision = '3eb8226f67ad'
down_revision = '2052bc64ecfb'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.execute(Category.__table__.update().
               values(name='Reversing').
               where(Category.name == 'Binary'))
    op.execute(Category.__table__.insert().
               values([{'name': 'Internals'},
                       {'name': 'Exploiting'}]))


def downgrade():
    op.execute(Category.__table__.update().
               values(name='Binary').
               where(Category.name == 'Reversing'))
    op.execute(Category.__table__.delete().
               where(sa.or_(Category.name == 'Internals',
                            Category.name == 'Exploiting'))
               )
