Installing the Software
=======================

As a Python WSGI application, it can be run in any environment that supports
the WSGI protocol.

.. warning::
    Irrespectable of which way you choose, you **must** make sure that the
    complete ``/admin`` subdomain is protected by external measures (e.g. HTTP
    Basic Auth). The backend has no separate protection.

.. warning::
    If not using Nginx, you have to make sure **manually** to set the ``Host``
    header to a static value and not trust the client as Pyramid relies on it
    to generate URLs!

Quickstart
----------

This gives an installation example. Adjust the paths to your liking. Also pay
attention to the username and group for the web server, it depends on the
server you are using and the distribution, it may for example be "www-data" or
"http" or "www". You should also use `virtualenv`_ instead of your global
python installation to run the scoreboard under.

.. _virtualenv: https://pypi.python.org/pypi/virtualenv

.. code-block:: bash

    mkdir -p /var/www/hacklu
    cd /var/www/hacklu
    chown http:http .
    virtualenv .
    . bin/activate
    tar -xzf fluxscoreboard.tar.gz
    cd fluxscoreboard/
    python setup.py install

Now create the MySQL database and a user:

.. code-block:: mysql

    -- Choose a secure password here!
    CREATE USER 'hacklu'@'localhost' IDENTIFIED BY 'mypass';
    CREATE DATABASE scoreboard;
    GRANT ALL ON scoreboard.* TO 'hacklu'@'localhost';

Now create a valid `Configuration`_.

Webserver Nginx + gunicorn
--------------------------

This is an example configuration file that can be used with `Nginx`_. For this
server you additionally need a reverse proxy that handles the WSGI protocol.

.. _Nginx: http://wiki.nginx.org/Main

.. literalinclude:: examples/nginx.conf
    :language: nginx

This defines the base application. It is configured for SSL only access and
automatically redirects any HTTP requests. There is not much to change here
except that you might want a different path for your application. However,
there is a second file that contains the actual options:

.. literalinclude:: examples/nginx_proxy.conf
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
``GRANT`` though). If you have followed the steps in `Quickstart`_ then you
already have everything and only need to enter the password you chose

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

Now install the application:

.. code-block:: python

    python installer.py install

Finally, you should protect your backend with HTTP Auth:

.. code-block:: bash

    htpasswd -c -b /var/www/hacklu/fluxscoreboard/.htpasswd_admin fluxadmin secretpassword

This will protect your backend from unauthorized access.

Finally, you have to make sure the configuration for the gunicorn server is
correct: The only setting that might change is the username you prefer. By
default user and group are configured to ``http``. But you might want to choose
any different user name (it does not have to be the one of your webserver,
though that has to read the ``static/`` directory.

Running the Scoreboard in a Subdirectory
----------------------------------------

Sometimes, for example for the archive, you might want to run the scoreboard
in a subdirectory. Let's say to want to run the 2013 scoreboard in the
subdirectory "hacklu2013". There are only a few settings you have to adjust:

- For the application, you need to insert the setting "subdirectory =
  hacklu2013", this will make all routes go to this subdirectory.
- For the Nginx configuration (or whatever your server is) you need to adjust
  all the routes to match the new subdirectory. To achieve this, you just
  prepend all routes with ``/hacklu2013``:
  - ``location /`` => ``location /hacklu2013``
  - ``location /admin`` => ``location /hacklu2013/admin``
  - ``location /static`` => ``location /hacklu2013/static``

And that's it, you can now run your scoreboard in a subdirectory. However, you
might want to adjust some paths in such a way that they are reflected as being
a subdirectory.

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
    There is no section on having a service yet. That has to be added. See
    Pyramids documentation on `supervisord`_.

.. _supervisord: http://docs.pylonsproject.org/projects/pyramid_cookbook/en/latest/deployment/nginx.html#step-4-managing-your-paster-processes-with-supervisord-optional

.. warning::
    Once the site is running the very first thing you should do is head over
    to the ``/admin/settings`` page and set a CTF start date. Without this, a
    login will throw an exception.
