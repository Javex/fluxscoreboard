Templating in the Application
=============================

For templating we use `Mako Templates`_. I think it is not necessary to explain
the advantages of a template engine over manual print statements and string
replacement. This documentation should only show some nice practices that can
make your life easier.

.. _Mako Templates: http://www.makotemplates.org/

Creating a New Template
-----------------------

Simple create a file in the ``templates/`` directory with a suffix of ``.mako``
and put the following content in it to get started:

.. code-block:: mako

    <%inherit file="base.mako"/>

This one line integrates your template with the default style. The next step is
to add the HTML you want. For the syntax of Mako look at the `Mako
documentation`.

.. _Mako documentation: http://docs.makotemplates.org


Page Style
----------

The page is/was developed with `Bootstrap 3`_ which provides some nice styles
to work with when a design is not ready yet. You are encouraged to work with
the bootstrap classes as we will work to have a stylesheet that defines the
same classes and can act as a drop-in replacement thus allowing us to quickly
change the style of the page when we want.

.. _Bootstrap 3: http://getbootstrap.com/


Using Defs with Forms
---------------------

When displaying forms you will find yourself repeating over and over (either
when displaying similar forms or even inside a form for each field). You can
use defs to make your life a whole lot easier. For example, take this def that
renders a form.

.. code-block:: mako

    <%def name="render_form(action, form, legend, display_cancel=True)">
        <form method="POST" action="${action}" class="form-horizontal">
            <legend>${legend}</legend>
            % for field in [item for item in form if item.name not in ["id", "submit", "cancel"]]:
            <div class="form-group">
                ${field.label(class_="col-4 control-label")}
                <div class="col-8">
        ## This is a really ugly solution to a limitation of WTForms. It would be a lot nicer to rebuild the form fields so they do this automatically.
                    ${field(class_="form-control")}
                    % for msg in getattr(field, 'errors', []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                </div>
            </div>
            % endfor
            <div class="col-4"></div>
            <div class="col-8">
                % if getattr(form, 'id', None) is not None:
                    ${form.id()}
                % endif
                % if display_cancel and hasattr(form, 'cancel'):
                    ${form.cancel(class_="btn btn-default")}
                % endif
                ${form.submit(class_="btn btn-primary")}
            </div>
        </form>
    </%def>

This is a somewhat complex piece of code but it shows nicely how to build a
reusable def: This will render a simple form with a legend and all fields
horizontally aligned. It will first display all fields in the order defined in
the form but skip special fields. Then it will display the special fields in
the right way.

The actual implementation has some additional complexity that can help in
certain situations to a look at the template files won't hurt. This example is
from ``templates/_form_functions.mako``.

``nl2br``
---------

The :func:`fluxscoreboard.util.nl2br` function can be used to turn newlines
into line breaks for improved display in HTML. It's usage is described on the
API documentation
