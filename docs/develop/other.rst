Send Mail
=========

Sending mails is done with the help of `pyramid_mailer`_. To send a mail, you
need to get the mailer, create a message and add it to the sending queue.
Here's how you do it:

.. _pyramid_mailer: http://docs.pylonsproject.org/projects/pyramid_mailer/en/latest/

.. code-block:: python

    from pyramid_mailer import get_mailer
    from pyramid_mailer.message import Message

    mailer = get_mailer(request)
    message = Message(subject="My Subject",
                      recipients=["test@example.com"],
                      body="Test Message",
                     )
    mailer.send(message)

You can also send html mails. For this it is recommended to use the templating
system and render it to HTML for a better display. Here's how you do that:

.. code-block:: python

    from pyramid.renderers import render
    # Code from above
    ...
    message = Message(subject="My HTML Mail",
                      recipients=["test@example.com"],
                      html=render('mail_test.mako',
                                  {},
                                  request=request,
                                 )
                     )
    # Code from above
    ...

This way you can send an email with an HTML body that is comfortably rendered
from a template. The empty dictionary is the data passed to the template and
the request comes from the web application.

Transaction Support
-------------------

The mailing system support transactions and thus makes sure that mails are only
sent when the transaction succeeds. Thus, when an exception occurs, the mail is
not sent. This provides a high level of integration and allows us to send mails
thoughtlessly but be sure they are never sent until the actual application
succeeded. However, this has a small performance impact on the response time:
The email is only dispatched once the application completes and that means it
cannot be deferred in any way: The application will only return once the email
is sent. This results in a small noticeable delay.
