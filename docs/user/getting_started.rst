.. _getting_started:

===============
Getting Started
===============


Installing the Scoreboard
=========================

As a Python WSGI application, it can be run in any environment that supports
the WSGI protocol.

.. warning::
    Irrespectable of which way you choose, you **must** make sure that the
    complete ``/admin`` path is protected by external measures (e.g. HTTP
    Basic Auth). The backend has no separate protection.

.. warning::
    If not using Nginx, you have to make sure to **manually** set the ``Host``
    header to a static value and not trust the client as Pyramid relies on it
    to generate URLs!

Quickstart
----------

First of all: The scoreboard uses PostgreSQL (and has only been tested with it).
It does explicitly *not* support MySQL as MySQL is crappy software. However, it
does not rely on obscure database features so you may get it running with a
different server (though not MySQL. Never MySQL.). So go ahead and install
PostgreSQL. You can then prepare the database:

.. code-block:: sql

    -- Choose a secure password here!
    CREATE USER fluxscoreboard WITH PASSWORD 'mypass';
    CREATE DATABASE scoreboard WITH OWNER fluxscoreboard;

Now let's install! Adjust the paths to your liking. Also pay
attention to the username and group for the web server, it depends on the
server you are using and the distribution, it may for example be "www-data" or
"http" or "www". You should also use `virtualenv`_ instead of your global
python installation to run the scoreboard under.

.. _virtualenv: https://pypi.python.org/pypi/virtualenv

.. code-block:: bash

    mkdir -p /var/www/ctf
    cd /var/www/ctf
    chown http:http .
    virtualenv .
    . bin/activate
    git clone git@github.com:Javex/fluxscoreboard.git
    cd fluxscoreboard/
    ./run install production

Now create a valid configuration by opening ``cfg/production.ini`` and
filling in all relevant values (everything is documented there). The ``run`` tool
has already performed some of the heavy lifting.

Webserver Nginx + gunicorn
--------------------------

This is an example configuration file that can be used with `Nginx`_. For this
server you additionally need a reverse proxy that handles the WSGI protocol.

.. _Nginx: http://wiki.nginx.org/Main

.. literalinclude:: ../examples/nginx.conf
    :language: nginx

This defines the base application. It is configured for SSL only access and
automatically redirects any HTTP requests. There is not much to change here
except that you might want a different path for your application. However,
there is a second file that contains the actual options:

.. literalinclude:: ../examples/nginx_proxy.conf
    :language: nginx

This file has to be saved somewhere *as-is* and the path in the main
configuration has to be adjusted in such a way that it points to it relative to
the Nginx main configuration directory (see comments in file). Restart Nginx.

.. note::
    The sample configuration sets the 'Host' header **statically** to whatever
    ``server_name`` setting you chose. Do not trust the ``$host`` header of
    the client: It may be spoofed but Pyramid relies on it so we have to make
    sure it is a trusted value!

After Nginx is configured this way you don't have to do much for `gunicorn`_:
It already has a valid configuration in the default configuration file (see
below).

.. todo::
    Configure gunicorn with proper logging.

.. _gunicorn: http://gunicorn.org/

Protecting the Admin Backend
----------------------------

Finally, you should protect your backend with HTTP Auth:

.. code-block:: bash

    htpasswd -c -b /var/www/ctf/fluxscoreboard/.htpasswd_admin fluxadmin secretpassword

This will protect your backend from unauthorized access.

Cron!
-----

Since calculating points is a heavy task, you should not do it on every
request from a user. Instead, we provide a convenience function that
regularly updates the points of teams and challenges:

.. code-block:: bash

    ./run update_points

Make sure to put that in a cron. Run it e.g. every five minutes.

Test it!
--------

This should be it. You should start the server as a test:

.. code-block:: bash

    gunicorn_paster production.ini

Try out the server by visiting the domain configured for Nginx. Fix any errors
that appear, then enable the ``daemon = True`` option for gunicorn in
``production.ini``. You are now good to go. A simple setup is to just run it
and close the shell. However, with this way you have no service, no monitoring
and no restarting.

.. todo::

    Add some more details here.
