# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import
from fluxscoreboard.forms.admin import NewsForm, ChallengeForm, TeamForm, \
    SubmissionForm, MassMailForm, ButtonForm, SubmissionButtonForm, CategoryForm, \
    TeamCleanupForm, SettingsForm, IPSearchForm
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import Challenge, Submission, \
    get_submissions, Category
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import (Team, get_active_teams, TeamIP,
    send_activation_mail)
from pyramid.httpexceptions import HTTPFound
from pyramid.security import remember
from pyramid.view import view_config
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from sqlalchemy.orm import subqueryload
from sqlalchemy.orm.exc import NoResultFound, MultipleResultsFound
from sqlalchemy.sql.expression import not_, desc, asc
from webhelpers.paginate import Page, PageURL_WebOb
import logging
import uuid


log = logging.getLogger(__name__)


class AdminView(object):
    """
    The view for everything corresponding to administration. The views here
    are not protected because they must be protected from the outside, i.e.
    HTTP Authorization or similar.
    """

    _menu = [('admin_news', 'Announcements'),
             ('admin_challenges', 'Challenges'),
             ('admin_categories', 'Categories'),
             ('admin_teams', 'Teams'),
             ('admin_ip_search', 'Search IP'),
             ('admin_submissions', 'Submissions'),
             ('admin_massmail', 'Mass Mail'),
             ('admin_settings', 'Settings'),
             ]

    def __init__(self, request):
        self.request = request

    @property
    def menu(self):
        return self._menu

    def page(self, items):
        """
        Return a :class:`webhelpers.paginate.Page` instance for an ``items``
        iterable.
        """
        if "items_per_page" not in self.request.session:
            message = (
                "Hint: You can change the number of items that are displayed "
                "per page by passing a GET parameter: ?items=20. This will "
                "then be remembered for your session. Pass in ?items=5 to "
                "hide this notice but keep the default of 5 items per page.")
            for msg in self.request.session.peek_flash():
                if msg == message:
                    break
            else:
                self.request.session.flash(message)
        items_per_page = self.request.GET.get('items', None)
        if items_per_page:
            self.request.session["items_per_page"] = int(items_per_page)
        items_per_page = self.request.session.get("items_per_page", 5)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(items, page=current_page, url=page_url,
                    items_per_page=items_per_page, item_count=items.count())
        return page

    def redirect(self, route_name, current_page=None):
        """
        For a given route name and page number get a redirect to that page.
        Convenience method for writing clean code.
        """
        query = {'page': current_page} if current_page is not None else None
        return HTTPFound(
            location=self.request.route_url(route_name,
                                            _query=query)
        )

    def items(self, DatabaseClass):
        """
        Construct a simple query to the database. Even though it is dead simple
        it is factored out because it is used in more than one place.
        """
        return DBSession.query(DatabaseClass).order_by(DatabaseClass.id)

    def _list_retparams(self, page, form, is_new=None):
        """
        Get a dictionary of parameters to return to a list + edit form view.

        ``page`` must be an instance of :class:`webhelpers.paginate.Page` and
        ``form`` must be an instance of the form to be displayed (whatever
        that is).
        """
        if is_new is None:
            is_new = not bool(form.id.data)
        return {'items': page.items,
                'form': form,
                'is_new': is_new,
                'page': page,
                'ButtonForm': ButtonForm,
                }

    def _delete_item(self, dbsession, item, title, title_plural=None):
        # Prepare parameters
        if title_plural is None:
            title_plural = title + "s"

        # Delete (make sure only **one** item is deleted)
        try:
            dbsession.delete(item.one())
        except NoResultFound:
            self.request.session.flash("The %s to be deleted was "
                                       "not found!" % title.lower(),
                                       "error"
                                       )
        except MultipleResultsFound:
            log.error("Multiple %s would have been deleted with the query "
                      "'%s' so the process was aborted."
                      % (title_plural.lower(), item))
            raise ValueError("Multiple %s were found. This should never "
                             "happen!" % title_plural.lower())
        else:
            self.request.session.flash("%s deleted!" % title)

    def _admin_list(self, route_name, FormClass, DatabaseClass, title,
                    change_query=None):
        """
        A generic function for all views that contain a list of things and also
        a form to edit or add entries.

        .. note::
            This only handles items with their own single primary key and not
            anything with composite foreign keys.

        Args:
            ``route_name``: A string containing the name of the route to which
            the admin should be redirected aver an edit was saved. For example
            ``"admin_challenges"``.

            ``FormClass``: The class of the form that should be displayed at
            the bottom of the page to edit or add items. For example
            :class:`fluxscoreboard.forms.admin.ChallengeForm`.

            ``DatabaseClass``: The ORM class from the model that is used to
            add and fetch items. For example
            :class:`fluxscoreboard.models.challenge.Challenge`.

            ``title``: A string that expresses a singular item, for example
            ``"Challenge"``. Will be used for flash messages.

            ``change_query``: A function that receives one parameter (a query),
            modifies it and returns the new query. May for example be used to
            modify the order or refine results. Optional.

        Returns:
            A dictionary or similar that can be directly returned to the
            application to be rendered as a view.

        An example usage might be like this:

        .. code-block:: python

            def challenges(self):
            return self._admin_list('admin_challenges', ChallengeForm,
                                    Challenge, "Challenge")
        """
        # Prepare some paramters
        items = self.items(DatabaseClass)
        if change_query:
            items = change_query(items)
        page = self.page(items)
        redirect = self.redirect(route_name, page.page)
        item_id = None
        if self.request.method == 'POST':
            # Someone wants to edit so make sure to load and check the form
            # for CSRF and get the ID.
            edit_form = ButtonForm(self.request.POST,
                                   csrf_context=self.request)
            if not edit_form.validate():
                # Error, most likely CSRF
                return redirect
            item_id = edit_form.id.data

        # Either load a new form or load old data into it.
        if item_id is None:
            form = FormClass(self.request.POST, csrf_context=self.request)
        else:
            db_item = (DBSession.query(DatabaseClass).
                       filter(DatabaseClass.id == item_id).one())
            form = FormClass(None, db_item, csrf_context=self.request)

        # Display the page
        return self._list_retparams(page, form)

    def _admin_edit(self, route_name, FormClass, DatabaseClass, title):
        """
        A generic function for a view that is invoked after an edit (or add)
        has been performed. It is separate from that of
        :meth:`AdminView._admin_list` to keep the code cleaner. It has the
        same parameters and return types but can only be invoked as a ``POST``.
        """
        # We don't accept GET or others here
        assert self.request.method == "POST"

        # Prepare parameters
        form = FormClass(self.request.POST, csrf_context=self.request)
        page = self.page(self.items(DatabaseClass))
        redirect = self.redirect(route_name, page.page)

        # Cancel button pressed?
        if not form.submit.data:
            return redirect

        # Form errors?
        if not form.validate():
            return self._list_retparams(page, form)

        # New item or existing one?
        if not form.id.data:
            db_item = DatabaseClass()
            DBSession.add(db_item)
            self.request.session.flash("%s added!" % title)
        else:
            db_item = (DBSession.query(DatabaseClass).
                       filter(DatabaseClass.id == form.id.data).one())
            self.request.session.flash("%s edited!" % title)

        # Transfer edits into database
        form.populate_obj(db_item)
        if db_item.id == '':
            # Safe measure to ensure a clean item ID
            db_item.id = None
        return redirect

    def _admin_delete(self, route_name, DatabaseClass, title,
                      title_plural=None):
        """
        Generic function to delete a single item from the database. Its
        arguments have the same meaning as explained in :meth:`_admin_list`
        with the addition of ``title_plural`` which is just a pluraized
        version of the ``title`` argument. Also returns something that can
        be returned directly to the application.

        .. note::
            To avoid problems with cascade instead of just emitting an SQL
            ``DELETE`` statement, this queries for all affected objects
            (should be one) and deletes them afterwards. This ensures that the
            Python-side cascades appropriately delete all dependent objects.
        """
        # We don't accept GET or others here
        assert self.request.method == "POST"

        # Prepare parameters
        delete_form = ButtonForm(self.request.POST, csrf_context=self.request)
        current_page = int(self.request.GET.get('page', 1))
        redirect = self.redirect(route_name, current_page)
        if title_plural is None:
            title_plural = title + "s"

        # Check for errors
        if not delete_form.validate():
            self.request.session.flash("Delete failed.")
            return redirect

        # Load the ID to delete
        item_id = delete_form.id.data

        # Delete the item
        item = (DBSession.query(DatabaseClass).
                filter(DatabaseClass.id == item_id))
        self._delete_item(DBSession, item, title, title_plural)
        return redirect

    def _admin_toggle_status(self, route_name, DatabaseClass, title='',
                             status_types={False: False, True: True},
                             status_variable_name='published',
                             status_messages={False: 'Unpublished %(title)s',
                                              True: 'Published %(title)s'}):
        """
        Generic function that allows to toggle a special status on the
        challenge. By default it toggles the ``published`` property of any
        given item.

        Many arguments are the same as in :meth:`_admin_list` with these
        additional arguments:

            ``status_types``: A two-element dictionary that contains ``True``
            and ``False`` as keys and any value that describes the given
            status. For example: If the "unpublished" status is described by
            the string "offline", then the value for key ``False`` would be
            ``"offline"``. It depends on the database model, which value
            is used here. The default is just a boolean mapping.

            ``status_variable_name``: What is the name of the property in the
            model that contains the status to be changed. Defaults to
            "published".

            ``status_messages``: The same keys as for ``status_types`` but as
            values contains messages to be displayed, based on which action
            was the result. Gives access to the ``title`` variable via
            ``%(title)s`` inside the string. The defaults are sensible values
            for the the default status. Most likely you want to change this if
            changing ``status_variable_name``.

        Returns:
            A dictionary or similar that can be directly returned from a view.
        """
        # We don't accept GET or others here
        assert self.request.method == "POST"

        # Prepare parameters
        current_page = int(self.request.GET.get('page', 1))
        redirect = self.redirect(route_name, current_page)

        # Load and check form (csrf check!)
        toggle_form = ButtonForm(self.request.POST, csrf_context=self.request)
        if not toggle_form.validate():
            self.request.session.flash("Toggle failed.")
            return redirect

        # Generate a dict of inverted status types
        inverse_status_types = dict((value, key)
                                    for key, value in status_types.items())

        # Fetch the item to toggle
        item = (DBSession.query(DatabaseClass).
                filter(DatabaseClass.id == toggle_form.id.data).one())

        # Read the current status
        status = inverse_status_types[getattr(item, status_variable_name)]
        # Set the inverse
        setattr(item, status_variable_name, status_types[not status])

        # Finish the request
        self.request.session.flash(status_messages[not status]
                                   % {'title': title.lower()})
        return redirect

    @view_config(route_name='admin')
    def admin(self):
        """Root view of admin page, redirect to announcements."""
        return HTTPFound(location=self.request.route_url('admin_news'))

    @view_config(route_name='admin_news', renderer='admin_news.mako')
    def news(self):
        """
        A view to list, add and edit announcements. Implemented with
        :meth:`_admin_list`.
        """
        order = lambda q: q.order_by(desc(News.timestamp))
        return self._admin_list('admin_news', NewsForm, News, "Announcement",
                                change_query=order)

    @view_config(route_name='admin_news_edit', renderer='admin_news.mako',
                 request_method='POST')
    def news_edit(self):
        """
        This view accepts an edit form, handles it and reacts accordingly
        (either redirect or, on error, show errors). Implemented with
        :meth:`_admin_edit`.
        """
        return self._admin_edit('admin_news', NewsForm, News, "Announcement")

    @view_config(route_name='admin_news_delete', request_method='POST')
    def news_delete(self):
        """
        A view to delete an announcement. Implemented with
        :meth:`_admin_delete`.
        """
        return self._admin_delete('admin_news', News, "Announcement")

    @view_config(route_name='admin_news_toggle_status', request_method='POST')
    def news_toggle_status(self):
        """
        A view to publish or unpublish an announcement. Implemented with
        :meth:`_admin_toggle_status`.
        """
        return self._admin_toggle_status('admin_news', News, "Announcement")

    @view_config(route_name='admin_challenges',
                 renderer='admin_challenges.mako')
    @view_config(route_name='admin_challenges_edit',
                 renderer='admin_challenges.mako')
    def challenges(self):
        """
        A view to list, add and edit challenges. Implemented with
        :meth:`_admin_list`.
        """
        return self._admin_list('admin_challenges', ChallengeForm,
                                Challenge, "Challenge")

    @view_config(route_name='admin_challenges_edit',
                 renderer='admin_challenges.mako', request_method='POST')
    def challenge_edit(self):
        """
        This view accepts an edit form, handles it and reacts accordingly
        (either redirect or, on error, show errors). Implemented with
        :meth:`_admin_edit`.
        """
        return self._admin_edit('admin_challenges', ChallengeForm, Challenge,
                                "Challenge")

    @view_config(route_name='admin_challenges_delete', request_method='POST')
    def challenge_delete(self):
        """
        A view to delete a challenge. Implemented with :meth:`_admin_delete`.
        """
        return self._admin_delete('admin_challenges', Challenge, "Challenge")

    @view_config(route_name='admin_challenges_toggle_status',
                 request_method='POST')
    def challenge_toggle_status(self):
        """
        A view to toggle the online/offline status of a challenge.
        Implemented with :meth:`_admin_toggle_status`.
        """
        return self._admin_toggle_status(
            'admin_challenges', Challenge, "Challenge",
            status_variable_name='online',
            status_messages={False: 'Challenge now offline',
                             True: 'Challenge now online'})

    @view_config(route_name='admin_challenges_toggle_published',
                 request_method='POST')
    def chalenge_toggle_published(self):
        """
        Switch a challenge between published and unpublished.
        """
        return self._admin_toggle_status(
            'admin_challenges', Challenge, "Challenge",
            status_variable_name='published',
            status_messages={False: 'Challenge unpublished',
                             True: 'Challenge published'})

    @view_config(route_name='admin_categories',
                 renderer='admin_categories.mako')
    @view_config(route_name='admin_categories_edit',
                 renderer='admin_categories.mako')
    def categories(self):
        """
        A view to list, add and edit categories. Implemented with
        :meth:`_admin_list`.
        """
        return self._admin_list('admin_categories', CategoryForm,
                                Category, "Category")

    @view_config(route_name='admin_categories_edit',
                 renderer='admin_categories.mako', request_method='POST')
    def category_edit(self):
        """
        This view accepts an edit form, handles it and reacts accordingly
        (either redirect or, on error, show errors). Implemented with
        :meth:`_admin_edit`.
        """
        return self._admin_edit('admin_categories', CategoryForm, Category,
                                "Category")

    @view_config(route_name='admin_categories_delete', request_method='POST')
    def category_delete(self):
        """
        A view to delete a category. Implemented with :meth:`_admin_delete`.
        """
        return self._admin_delete('admin_categories', Category, "Category")

    @view_config(route_name='admin_teams',
                       renderer='admin_teams.mako')
    @view_config(route_name='admin_teams_edit',
                       renderer='admin_teams.mako')
    def teams(self):
        """
        List, add or edit a team.
        """
        retval = self._admin_list('admin_teams', TeamForm, Team, "Team")
        if isinstance(retval, dict):
            cleanup_form = TeamCleanupForm(csrf_context=self.request,
                                           title="Clean Up Inactive Teams")
            retval["cleanup_form"] = cleanup_form
        return retval

    @view_config(route_name='admin_teams_edit',
                 renderer='admin_teams.mako', request_method='POST')
    def team_edit(self):
        """
        This view accepts an edit form, handles it and reacts accordingly
        (either redirect or, on error, show errors). Implemented with
        :meth:`_admin_edit`.
        """
        retval = self._admin_edit('admin_teams', TeamForm, Team, "team")
        if isinstance(retval, dict):
            cleanup_form = TeamCleanupForm(csrf_context=self.request,
                                           title="Clean Up Inactive Teams")
            retval["cleanup_form"] = cleanup_form
        return retval

    @view_config(route_name='admin_teams_delete', request_method='POST')
    def team_delete(self):
        """Delete a team."""
        return self._admin_delete('admin_teams', Team, "Team")

    @view_config(route_name='admin_teams_activate', request_method='POST')
    def team_activate(self):
        """De-/Activate a team."""
        return self._admin_toggle_status('admin_teams', Team, "Team",
                                         {True: True, False: False},
                                         'active',
                                         {False: 'Deactivated %(title)s',
                                          True: 'Activated %(title)s'}
                                         )

    @view_config(route_name='admin_teams_toggle_local', request_method='POST')
    def team_toggle_local(self):
        """Toggle the local attribute of a team."""
        return self._admin_toggle_status(
            'admin_teams', Team, status_types={True: True, False: False},
            status_variable_name='local',
            status_messages={False: 'Set team as a remote team',
                             True: 'Set team as a local team'}
            )

    @view_config(route_name='admin_teams_regenerate_token', request_method='POST')
    def team_regenerate_token(self):
        """Manually regenerate the teams challenge token"""
        current_page = int(self.request.GET.get('page', 1))
        redirect = self.redirect('admin_teams', current_page)
        button_form = ButtonForm(self.request.POST, csrf_context=self.request)
        if not button_form.validate():
            self.request.session.flash("Regenerate failed.")
            return redirect

        team = DBSession.query(Team).filter(Team.id == button_form.id.data).one()
        log.info("Generating new token for team %s, old token: %s"
                 % (team.name, team.challenge_token))
        team.challenge_token = str(uuid.uuid4()).decode("ascii")

        self.request.session.flash("New token created for team %s" % team.name)
        return redirect

    @view_config(route_name='admin_teams_cleanup', request_method='POST')
    def team_cleanup(self):
        """Remove ALL inactive teams. Warning: **DANGEROUS**"""
        form = TeamCleanupForm(self.request.POST, csrf_context=self.request)
        redirect = self.redirect('admin_teams',
                                 int(self.request.GET.get("page", 1)))
        if not form.validate():
            return redirect
        if not form.team_cleanup.data:
            return redirect
        inactive_teams = DBSession.query(Team).filter(not_(Team.active)).all()
        delete_count = len(inactive_teams)
        for team in inactive_teams:
            DBSession.delete(team)
        self.request.session.flash("Deleted %d teams" % delete_count)
        return redirect

    @view_config(route_name='admin_teams_ips', renderer='admin_team_ips.mako')
    def team_ips(self):
        """A list of IPs per team."""
        form = ButtonForm(self.request.POST, csrf_context=self.request)
        redir = self.redirect('admin_teams',
                              int(self.request.GET.get("page", 1)))
        if not form.validate():
            return redir
        team = (DBSession.query(Team).
                filter(Team.id == form.id.data).
                options(subqueryload('team_ips')).
                one())
        return {'team': team}

    @view_config(route_name='admin_teams_resend_activation',
                 request_method='POST')
    def team_resend_activation(self):
        """Resend the activation mail for a team."""
        form = ButtonForm(self.request.POST, csrf_context=self.request)
        redir = self.redirect('admin_teams',
                              int(self.request.GET.get("page", 1)))
        if not form.validate():
            return redir
        team = DBSession.query(Team).filter(Team.id == form.id.data).one()
        send_activation_mail(team, self.request)
        self.request.session.flash('Activation mail for team "%s" resent.'
                                   % team.name)
        return redir

    @view_config(route_name='admin_ip_search', renderer='admin_ips.mako')
    def search_ips(self):
        form = IPSearchForm(self.request.POST, csrf_context=self.request)
        retparams = {'form': form}
        redirect = self.redirect('admin_ip_search')
        query = DBSession.query(Team).join(TeamIP)
        if self.request.method == 'POST':
            if not form.validate():
                return redirect
            query = query.filter(TeamIP.ip == form.term.data)
        retparams["results"] = query.all()
        return retparams

    @view_config(route_name='admin_submissions',
                 renderer='admin_submissions.mako')
    def submissions(self):
        """
        List, add or edit a submission. This is different because it consists
        of composite foreign keys and thus needs separate though similar logic.
        But in the end it is basically the same functionality as with the other
        list views.
        """
        # Prepare parameters
        submissions = get_submissions()
        page = self.page(submissions)
        redirect = self.redirect('admin_submissions', page.page)
        challenge_id = None
        team_id = None
        if self.request.method == 'POST':
            # Someone wants to edit so make sure to load and check the form
            # for CSRF and get the ID.
            edit_form = SubmissionButtonForm(self.request.POST,
                                             csrf_context=self.request)
            if not edit_form.validate():
                # Error, most likely CSRF
                return redirect
            challenge_id = edit_form.challenge_id.data
            team_id = edit_form.team_id.data

        # Either load a new form or load old data into it.
        if challenge_id is None or team_id is None:
            form = SubmissionForm(self.request.POST, csrf_context=self.request)
        else:
            submission = (DBSession.query(Submission).
                          filter(Submission.team_id == team_id).
                          filter(Submission.challenge_id == challenge_id).
                          order_by(desc(Submission.timestamp)).
                          one())
            form = SubmissionForm(None, submission, csrf_context=self.request)

        # Display the page
        is_new = not bool(form.challenge.data and form.team.data)
        return self._list_retparams(page, form, is_new=is_new)

    @view_config(route_name='admin_submissions_edit',
                 renderer='admin_submissions.mako',
                 request_method='POST')
    def submissions_edit(self):
        # Prepare parameters
        form = SubmissionForm(self.request.POST, csrf_context=self.request)
        submissions = get_submissions()
        page = self.page(submissions)
        redirect = self.redirect('admin_submissions', page.page)

        # Cancel button pressed?
        if not form.submit.data:
            return redirect

        is_new = not bool(form.challenge.data and form.team.data)
        # Form errors?
        if not form.validate():
            return self._list_retparams(page, form, is_new=is_new)

        # New item or existing one?
        try:
            submission = (DBSession.query(Submission).
                          filter(Submission.challenge_id ==
                                 form.challenge.data.id).
                          filter(Submission.team_id == form.team.data.id).
                          one())
            self.request.session.flash("Submission edited!")
        except NoResultFound:
            submission = Submission()
            DBSession.add(submission)
            self.request.session.flash("Submission added!")

        # Transfer edits into databse
        form.populate_obj(submission)
        return redirect

    @view_config(route_name='admin_submissions_delete', request_method='POST')
    def submissions_delete(self):
        """Delete a submission."""
        # Prepare parameters
        delete_form = SubmissionButtonForm(self.request.POST,
                                           csrf_context=self.request)
        current_page = int(self.request.GET.get('page', 1))
        redirect = self.redirect('admin_submissions', current_page)

        # Check for errors
        if not delete_form.validate():
            self.request.session.flash("Delete failed.")
            return redirect

        # Load the IDs to delete and build query
        challenge_id = delete_form.challenge_id.data
        team_id = delete_form.team_id.data
        submission = (DBSession.query(Submission).
                        filter(Submission.challenge_id == challenge_id).
                        filter(Submission.team_id == team_id))

        # Delete the item
        self._delete_item(DBSession, submission, "Submission")
        return redirect

    @view_config(route_name='admin_massmail',
                       renderer='admin_massmail.mako')
    def massmail(self):
        """
        Send a massmail to all users in the system. It also stores the sent
        mail and its recipients in the database to keep a permanent record of
        sent messages.
        """
        form = MassMailForm(self.request.POST, csrf_context=self.request)
        if not form.from_.data:
            settings = self.request.registry.settings
            form.from_.data = settings["mail.default_sender"]
        mail_query = DBSession.query(MassMail)
        page = self.page(mail_query)
        retparams = {'form': form,
                     'items': page.items,
                     'page': page}
        if self.request.method == 'POST':
            if not form.validate():
                return retparams
            teams = get_active_teams()
            # Create a record to keep track of all sent mails
            mail_record = MassMail()
            form.populate_obj(mail_record)
            recipients = [team.email for team in teams]
            mail_record.recipients = recipients
            mailer = get_mailer(self.request)
            message = Message(subject=mail_record.subject,
                              bcc=mail_record.recipients,
                              body=mail_record.message,
                              sender=mail_record.from_,
                              )
            DBSession.add(mail_record)
            mailer.send(message)
            self.request.session.flash("Mass mail sent to all %d active users"
                                       % len(recipients))
            return HTTPFound(location=self.request.route_url('admin_massmail'))
        return retparams

    @view_config(route_name='admin_massmail_single',
                       renderer='admin_massmail_single.mako')
    def massmail_single(self):
        """View a single massmail that was sent."""
        id_ = self.request.matchdict["id"]
        mail = DBSession.query(MassMail).filter(MassMail.id == id_).one()
        return {'mail': mail}

    @view_config(route_name='admin_settings', renderer='admin_settings.mako')
    def settings(self):
        """
        Adjust runtime application settings.
        """
        settings = self.request.settings
        form = SettingsForm(self.request.POST, settings,
                            csrf_context=self.request)
        retparams = {'form': form}

        if self.request.method == "POST":
            if not form.validate():
                return retparams
            form.populate_obj(settings)
            self.request.session.flash("Settings updated!")
            return self.redirect('admin_settings')
        return retparams

    @view_config(route_name='test_login')
    def test_login(self):
        """
        If there is at least one team, log in as it to see the page.
        """
        form = ButtonForm(self.request.POST, csrf_context=self.request)
        team_query = DBSession.query(Team)
        if form.id.data:
            team_query = team_query.filter(Team.id == form.id.data)
        team = team_query.first()
        if not team:
            self.request.session.flash("No team available, add one!")
            return HTTPFound(location=self.request.route_url('admin_teams'))
        return self._test_login(team)

    def _test_login(self, team):  # Start a new session due to new permissions
        self.request.session.invalidate()
        headers = remember(self.request, team.id)
        self.request.session["test-login"] = True
        self.request.session.flash("You were logged in as team %s. Please be "
                                   "aware that this is only a test login, so "
                                   "don't break anything." % team.name,
                                   'warning')
        return HTTPFound(location=self.request.route_url('home'),
                         headers=headers)
