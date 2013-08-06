Installing the Software
=======================

As a Python WSGI application, it can be run in any environment that supports
the WSGI protocol.

.. warning::
    Irrespectable of which way you choose, you **must** make sure that the
    complete ``/admin`` subdomain is protected by external measures (e.g. HTTP
    Basic Auth). The backend has no separate protection.

Quickstart
----------

.. todo::
    Write this section

Nginx + gunicorn
----------------

.. todo::
    Try this yourself and fill it with content

This is an example configuration file that can be used with `Nginx`_. For this
server you additionally need a reverse proxy that handles the WSGI protocol.

.. _Nginx: http://wiki.nginx.org/Main

.. literalinclude:: examples/nginx.conf
    :language: nginx

In our case this is `gunicorn`_, a fast and easy to set up WSGI server.

.. _gunicorn: http://gunicorn.org/

.. literalinclude:: examples/gunicorn.conf
    :language: ini

Configuration
=============

Configuration is done using `PasteDeploy`_ configuration files (basically just
typical ini files). The first step is to create a default configuration and
enter the necessary details to make the application start.

.. _PasteDeploy: http://pythonpaste.org/deploy/

.. code-block:: bash

    cp production.ini.example production.ini

Now open this file with your favourite text editor. There are only very few
places you actually need to change. The whole file is commented, so you can
infer the description of all settings from there.

To get started you at least have to enter the database connection values:

.. code-block:: ini

    db.user = hacklu
    db.password = mydbpassword

You also need to create that user and the default database (``scoreboard``) or
the one you entered and grant the user all permissions on it (no need for
``GRANT`` though).

In the next step, you have to configure the mailing part. The mailing system
currently only supports SMTP and no local ``sendmail`` so you have to enter
credentials for SMTP connections.

.. code-block:: ini

    mail.host = example.com
    mail.username = me@example.com
    mail.password = mymailpassword
    mail.default_sender = hacklu@example.com

By default, the system assumes you want to use SSL. If you don't, you can
instead disable the ``mail.ssl`` setting by commenting it out or setting it to
``False``. Remember to adjust the port (most likely ``25``). Further
information on the available settings can be found on the documentation of
`pyramid_mailer`_.

.. _pyramid_mailer: http://docs.pylonsproject.org/projects/pyramid_mailer/en/latest/#configuration

The last thing you absolutely **must** to is set a session secret that will be
used for signing the session ID (to prevent hijacking). You can generate a
secure secret e.g. by ``openssl rand -base64 32`` which generates base64
encoded string with an entropy of 256 bits, more than enough for this purpose.

.. code-block:: ini

    session.secret = mysecret

You can now use your application. For further configuration, take a look at the
commented configuration file.
