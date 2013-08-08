.. _dev_forms:

Displaying and Using Forms
==========================

Forms a built using `WTForms`_. This allows us to map forms to classes, build
validators and let it take the pain out of forms. There is no real, perfect
forms library but with WTForms it is at least easier than writing the HTML
directly.

.. _WTForms: http://wtforms.simplecodes.com/docs/1.0.4/index.html

Defining a Basic Form
---------------------

To define a form derive from the :class:`wtforms.form.Form` class and start
defining your fields (for a more thorough definition and explanation refer to
the original documentation):

.. code-block:: python

    from wtforms.form import Form
    from wtforms.fields.simple import TextField, SubmitField

    class SampleForm(Form):
        text = TextField("Sample Text")

        submit = SubmitField("Submit")


Using a Form
------------

Now we can use this form (and load it with data) from a view:

.. code-block:: python

    def some_view(request):
        form = SampleForm(request.POST)

Then we make sure it is valid:

.. code-block:: python

    if not form.validate():
        # do something
        pass

But what does validate do?

Defining Validation on a Form
-----------------------------

To get validation, we define a list of validators on a field. For example:

.. code-block:: python

    from fluxscoreboard.forms.validators import required_validator
    class SampleForm(Form):
        text = TextField("Sample Text",
                         validators=[required_validator]
                        )
        ...

For details on validators already provided, see the documentation for
:mod:`fluxscoreboard.forms.validators`. There are
already some common validators for length and other stuff defined. Also pay
attention that you should have a validator that checks for the allowed database
length (e.g. if you database column is ``Unicode(255)`` check that it is not
longer than 255 characters).


From- & Database-Interaction
----------------------------

Getting a form into the database is easy.

.. code-block:: python

    # Create the form
    form = SampleForm(request.POST)
    # Create the database object
    dbitem = Sample()
    # Fill it with the form data
    form.populate_obj(dbitem)

Of course, this only works when the form fields and database names are the
same. You can also manually map the fields together if you want.

Filling a form from the database is also easy:

.. code-block:: python

    # Load the object (maybe from database)
    dbitem = get_item()
    # Create the form
    form = SampleForm(request.POST, dbitem)

What does this do? It loads the database item from somewhere and then
instantiates the form as previously but now it fills the missing fields from
the database.

You can combine the two approaches above to retrieve a form to be edited and
then save it back to the database:

.. code-block:: python

    def my_view(request):
        dbitem = get_item()
        form = SampleForm(request.POST, dbitem)
        if request.method == 'POST':
            if not form.validate():
                # handle it
                pass
            form.populate_obj(dbitem)
            # redirect or something
        return {'form': form}

This approach will load an item from the database, then fill the form correctly
and on a ``GET`` request just display it. Once editing is done and the form
gets submitted we now load the form data into the database item.

.. note::
    This is a fairly simple example. Normally you would want to track something
    liket the id in a field and use that to query the database and also have
    some nice wrapping stuff that displays messages, redirects on success and
    notifies the user of any problems.

.. todo::
    There is currently an ugly display of buttons on the Action listings as
    they don't have a 100% width. However setting it to 100% causes Overflow of
    larger text. Both is not nice :(
