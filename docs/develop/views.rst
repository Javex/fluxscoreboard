.. _dev_routes:

Routing and Views
=================

The system's routing and views are closely related and so here is a joined
explanation of both. If you want to add a new view, there has to be a way to
reach it and that is via routes. So let's start off by adding a new view.

.. note::
    Further explanation of routes and views can be found on the 
    `Pyramid documentation`_.

.. _Pyramid documentation: http://docs.pylonsproject.org/projects/pyramid/en/1.4-branch/narr/urldispatch.html

Adding a New View
-----------------

Views should be defined in the :mod:`fluxscoreboard.views` package. There you
will find :class:`fluxscoreboard.views.front.BaseView` from which you should
derive all frontend views (as it provides access to some helpful attributes).
You can also add your view to an existing view class which is most likely more
what you want so let's go down that road and define a new frontend view:

.. code-block:: python
    
    class FrontView(BaseView):
        ...

        @logged_in_view(route_name='my_route', renderer='my_route.mako')
        def my_route(self):
            # Do view stuff here
            return {}

Here's what we did: We add a method to the class and decorate it with
:data:`fluxscoreboard.views.front.logged_in_view`. This decorator protects the
view so only logged-in teams can see it. We assigned it the route name
``my_route`` and also specified a template ``my_route.mako``. A template isn't
required, but usually only in a case where you redirect after you are with your
view. After the view is done we return an empty ``dict``. This contains the
data passed to the template (in our case there is no data).

This was most of the work of adding a view. However, we still haven't defined
how to add a view. For this, you open up ``fluxscoreboard/routes.py`` and add a
new route, like this:

.. code-block:: python

    routes = [ ...
              ('my_route', '/my_route'),
              ...
              ]

As you can see, adding a new route is easy: Now, whenever someone comes to the
site and heads to ``/my_route``, he will see whatever the view ``my_route``
wants to display.

