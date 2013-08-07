Interacting with the Database
=============================

The database is built with `SQLAlchemy`_ which is *the* Python ORM. It has the
ability to very easily query the data as classes but beyond that also has the
ability to write queries that result in literal SQL strings only we never have
to worry about any SQL Injection. Also it takes a lot of type checks, coercing
and whatnot pain out of databases.

.. _SQLAlchemy: http://www.sqlalchemy.org

Please not that this only introduces small bits of how some stuff is done in
this application. The introduction to SQLAlchemy itself can be found on their
page (the most important part being the `ORM tutorial`_.

.. _ORM tutorial: http://docs.sqlalchemy.org/en/rel_0_8/orm/tutorial.html

Basic Querying
--------------

So let's get started. To perform a query, we need the session on which all
queries are executed. Note that the ``DBSession`` is scoped to the current
thread. In our context that means that calling it will always give the *exact
same* session back as long as we are in the same thread. So it is not required
to pass it around all the time. Here's how you get a session to start querying:

.. code-block:: python

    from fluxscoreboard.models import DBSession
    dbsession = DBSession()

Now we can execute a query, for example, get all challenges:

.. code-block:: python

    from fluxscoreboard.models.challenges import Challenge
    all_challenges = dbsession.query(Challenge)


Note that we did not actually execute a query yet but instead have a query
object. It produces results once used as an iterable, e.g.
``list(all_challenges)`` or ``all_challenges.all()``. Then you have a
list of challenges. However, here is one thing to note:
You should always return query, i.e. not call ``all`` or similar to produce
actual results. That is done those items are actually **used**. This is
advantageous in two ways: For one, it supports the lazy technique by which a
query is only emitted once the results are actually need. And for the other
part, you can refine such queries when they are not yet results. So you could
modify the query to only get challenges which are manual:

.. code-block:: python

    manual_challenges = all_challenges.filter(Challenge.manual == True)

Now this is a query that can be executed and it will limit the results. And you
should remember to always pass around queries, never the actual lists, until
they are used.

.. note::
    This technique works so well because any
    :class:`sqlalchemy.orm.query.Query` class produces an iterable.

Pagination
##########

The query technique described above is also very useful for pagination, because
the :class:`webhelpers.paginate.Page` class supports recieving an iterable (so
a query) and can also recieve an ``item_count``. This is fortunate because we
can find the number of items from a query by exeuting
:meth:`sqlalchemy.orm.query.Query.count` on it:

.. code-block:: python

    page = Page(manual_challenges, page=1,
                item_count=manual_challenges.count(), url=page_url)

Don't worry too much about the details here, just note that we could reuse our
query to get the item count (which is far more efficient than fetching the
complete list to determine it).

The ``one`` Exception
#####################

There is one exception for only passing queries: The
:meth:`sqlalchemy.orm.query.Query.one` method. This
function can be used to ensure there was exactly **one** result returned and
throw an Exception if no result or multiple results were found. This is a very
useful function to query a page with a single item because then you can be sure
you have exactly one item and not more.