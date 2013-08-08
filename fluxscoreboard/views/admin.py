# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import
from fluxscoreboard.forms.admin import NewsForm, ChallengeForm, TeamForm, \
    SubmissionForm, MassMailForm, ButtonForm, SubmissionButtonForm
from fluxscoreboard.models import DBSession
from fluxscoreboard.models.challenge import Challenge, Submission
from fluxscoreboard.models.news import News, MassMail
from fluxscoreboard.models.team import Team, get_active_teams
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from sqlalchemy.orm import joinedload
from sqlalchemy.orm.exc import NoResultFound, MultipleResultsFound
from webhelpers.paginate import Page, PageURL_WebOb
import logging


log = logging.getLogger(__name__)


class AdminView(object):
    """
    The view for everything corresponding to administration. The views here
    are not protected because they must be protected from the outside, i.e.
    HTTP Authorization or similar.
    """

    _menu = [('admin_news', 'Announcements'),
             ('admin_challenges', 'Challenges'),
             ('admin_teams', 'Teams'),
             ('admin_submissions', 'Submissions'),
             ('admin_massmail', 'Mass Mail'),
             ]

    def __init__(self, request):
        self.request = request

    @property
    def menu(self):
        return self._menu

    def _admin_list(self, route_name, FormClass, DatabaseClass, title):
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
            :class:`fluxscoreboard.forms_admin.ChallengeForm`.

            ``DatabaseClass``: The ORM class from the model that is used to
            add and fetch items. For example
            :class:`fluxscoreboard.models.challenge.Challenge`.

            ``title``: A string that expresses a singular item, for example
            ``"Challenge"``. Will be used for flash messages.

        Returns:
            A dictionary or similar that can be directly returned to the
            application to be rendered as a view.

        An example usage might be like this:

        .. code-block:: python

            def challenges(self):
            return self._admin_list('admin_challenges', ChallengeForm,
                                    Challenge, "Challenge")
        """
        dbsession = DBSession()
        items = dbsession.query(DatabaseClass)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(items, page=current_page, url=page_url,
                    items_per_page=5, item_count=items.count())
        redirect = HTTPFound(
                       location=self.request.route_url(
                           route_name, query={'page': page.page}))
        item_id = None
        edit = "button" in self.request.POST
        if self.request.method == 'POST' and edit:
            edit_form = ButtonForm(self.request.POST,
                                   csrf_context=self.request)
            if not edit_form.validate():
                # Error, most likely CSRF
                return redirect
            item_id = edit_form.id.data
        if item_id is None:
            form = FormClass(self.request.POST, csrf_context=self.request)
        else:
            db_item = (dbsession.query(DatabaseClass).
                       filter(DatabaseClass.id == item_id).one())
            form = FormClass(self.request.POST if not edit else None, db_item,
                             csrf_context=self.request)
        retparams = {'items': page.items,
                     'form': form,
                     'is_new': not bool(form.id.data),
                     'page': page,
                     'ButtonForm': ButtonForm,
                     }
        if self.request.method == 'POST' and "button" not in self.request.POST:
            if form.submit.data:
                if not form.validate():
                    return retparams
                if not form.id.data:
                    db_item = DatabaseClass()
                    dbsession.add(db_item)
                    self.request.session.flash("%s added!" % title)
                else:
                    db_item = (dbsession.query(DatabaseClass).
                               filter(DatabaseClass.id == form.id.data).one())
                    self.request.session.flash("%s edited!" % title)
                form.populate_obj(db_item)
                if db_item.id == '':
                    db_item.id = None
            return redirect
        return retparams

    def _admin_delete(self, route_name, DatabaseClass, title, title_plural):
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
        delete_form = ButtonForm(self.request.POST, csrf_context=self.request)
        current_page = self.request.GET.get('page', 1)
        dbsession = DBSession()
        redirect = HTTPFound(location=self.request.route_url(route_name, _query={'page': current_page}))
        if not delete_form.validate():
            self.request.session.flash("Delete failed.")
            return redirect
        item_id = delete_form.id.data
        try:
            obj = (dbsession.query(DatabaseClass).
                            filter(DatabaseClass.id == item_id))
            dbsession.delete(obj.one())
        except NoResultFound:
            self.request.session.flash("The %s to be deleted was "
                                       "not found!" % title.lower(),
                                       "error"
                                       )
        except MultipleResultsFound:
            log.error("Multiple %s would have been deleted with the query "
                      "'%s' so the process was aborted."
                      % (title_plural.lower(), obj))
            raise ValueError("Multiple %s were found. This should never "
                             "happen!" % title_plural.lower())
        else:
            self.request.session.flash("%s deleted!" % title)
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
        current_page = self.request.GET.get('page', 1)
        dbsession = DBSession()
        inverse_status_types = {}
        toggle_form = ButtonForm(self.request.POST, csrf_context=self.request)
        redirect = HTTPFound(location=self.request.route_url(route_name, _query={'page': current_page}))
        if not toggle_form.validate():
            self.request.session.flash("Toggle failed.")
            return redirect
        item_id = toggle_form.id.data
        for key, value in status_types.items():
            inverse_status_types[value] = key
        item = (dbsession.query(DatabaseClass).
                filter(DatabaseClass.id == item_id).one())
        status = inverse_status_types[getattr(item, status_variable_name)]
        setattr(item, status_variable_name, status_types[not status])
        self.request.session.flash(status_messages[not status]
                                   % {'title': title.lower()})
        return redirect

    @view_config(route_name='admin')
    def admin(self):
        """Root view of admin page, redirect to announcements."""
        return HTTPFound(location=self.request.route_url('admin_news'))

    @view_config(route_name='admin_news', renderer='admin_news.mako')
    @view_config(route_name='admin_news_edit', renderer='admin_news.mako')
    def news(self):
        """
        A view to list, add and edit announcements. Implemented with
        :meth:`_admin_list`.
        """
        # TODO: When an announcement is turned into a general (i.e. no
        # challenge ID) it gets deleted. Why?
        return self._admin_list('admin_news', NewsForm, News, "Announcement")

    @view_config(route_name='admin_news_delete')
    def news_delete(self):
        """
        A view to delete an announcement. Implemented with
        :meth:`_admin_delete`.
        """
        return self._admin_delete('admin_news', News,
                                  "Announcement", "Announcements")

    @view_config(route_name='admin_news_toggle_status')
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

    @view_config(route_name='admin_challenges_delete')
    def challenge_delete(self):
        """
        A view to delete a challenge. Implemented with :meth:`_admin_delete`.
        """
        return self._admin_delete('admin_challenges', Challenge,
                                  "Challenge", "Challenges")

    @view_config(route_name='admin_challenges_toggle_status')
    def challenge_toggle_status(self):
        """
        A view to toggle the online/offline status of a challenge.
        Implemented with :meth:`_admin_toggle_status`.
        """
        return self._admin_toggle_status('admin_challenges', Challenge,
                                         "Challenge")

    @view_config(route_name='admin_teams',
                       renderer='admin_teams.mako')
    @view_config(route_name='admin_teams_edit',
                       renderer='admin_teams.mako')
    def teams(self):
        """
        List, add or edit a team.
        """
        return self._admin_list('admin_teams', TeamForm, Team, "Team")

    @view_config(route_name='admin_teams_delete')
    def team_delete(self):
        """Delete a team."""
        return self._admin_delete('admin_teams', Team, "Team", "Teams")

    @view_config(route_name='admin_teams_activate')
    def team_activate(self):
        """De-/Activate a team."""
        return self._admin_toggle_status('admin_teams', Team, "Team",
                                         {True: True, False: False},
                                         'active',
                                         {False: 'Deactivated %(title)s',
                                          True: 'Activated %(title)s'}
                                         )

    @view_config(route_name='admin_teams_toggle_local')
    def team_toggle_local(self):
        """Toggle the local attribute of a team."""
        return self._admin_toggle_status(
            'admin_teams', Team, status_types={True: True, False: False},
            status_variable_name='local',
            status_messages={False: 'Set team as a remote team',
                             True: 'Set team as a local team'}
            )

    @view_config(route_name='admin_submissions',
                 renderer='admin_submissions.mako')
    @view_config(route_name='admin_submissions_edit',
                       renderer='admin_submissions.mako')
    def submissions(self):
        """
        List, add or edit a submission. This is different because it consists
        of composite foreign keys and thus needs separate though similar logic.
        But in the end it is basically the same functionality as with the other
        list views.
        """
        # TODO: Possibly we need a way to distinguish between someone selecting
        # an existing Challenge/Team combo and clicking the "Edit" button.
        # Currently the former is somewhat buggy...
        dbsession = DBSession()
        submissions = (dbsession.query(Submission).
                             options(joinedload('challenge')).
                             options(joinedload('team')))
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(submissions, page=current_page, url=page_url,
                    items_per_page=5, item_count=submissions.count())
        redirect = HTTPFound(
                       location=self.request.route_url(
                           'admin_submissions', _query={'page': page.page}))
        challenge_id = None
        team_id = None
        edit = "button" in self.request.POST
        if self.request.method == 'POST' and edit:
            edit_form = SubmissionButtonForm(self.request.POST,
                                             csrf_context=self.request)
            if not edit_form.validate():
                # Error, most likely CSRF
                return redirect
            challenge_id = edit_form.challenge_id.data
            team_id = edit_form.team_id.data
        if challenge_id is None or team_id is None:
            form = SubmissionForm(self.request.POST, csrf_context=self.request)
        else:
            db_item = (dbsession.query(Submission).
                       filter(Submission.team_id == team_id).
                       filter(Submission.challenge_id == challenge_id).
                       one())
            form = SubmissionForm(self.request.POST if not edit else None,
                                  db_item, csrf_context=self.request)
        retparams = {'items': page.items,
                     'form': form,
                     'is_new': True,
                     'page': page,
                     'ButtonForm': SubmissionButtonForm,
                     }
        if self.request.method == 'POST' and "button" not in self.request.POST:
            if form.submit.data:
                if not form.validate():
                    return retparams

                try:
                    db_item = (dbsession.query(Submission).
                               filter(Submission.challenge_id ==
                                      form.challenge.data.id).
                               filter(Submission.team_id == form.team.data.id).
                               one())
                    is_new = False
                    self.request.session.flash("Submission edited!")
                except NoResultFound:
                    db_item = Submission()
                    dbsession.add(db_item)
                    is_new = True
                    self.request.session.flash("Submission added!")
                form.populate_obj(db_item)
                retparams["is_new"] = is_new
            return redirect
        return retparams

    @view_config(route_name='admin_submissions_delete')
    def sbumissions_delete(self):
        """Delete a submission."""
        delete_form = SubmissionButtonForm(self.request.POST,
                                           csrf_context=self.request)
        current_page = self.request.GET.get('page', 1)
        dbsession = DBSession()
        redirect = HTTPFound(
                       location=self.request.route_url(
                           'admin_submissions',
                           _query={'page': current_page},
                           )
                         )
        if not delete_form.validate():
            self.request.session.flash("Delete failed.")
            return redirect
        challenge_id = delete_form.challenge_id.data
        team_id = delete_form.team_id.data
        submission = (dbsession.query(Submission).
                        filter(Submission.challenge_id == challenge_id).
                        filter(Submission.team_id == team_id))
        try:
            dbsession.delete(submission.one())
        except NoResultFound:
            self.request.session.flash("The Submission to be deleted was "
                                       "not found!",
                                       "error"
                                       )
        except MultipleResultsFound:
            log.error("Deleted multiple Submissions with query %s"
                      % submission)
            raise ValueError("Multiple Submissions were found and deleted. "
                             "This should not be possible!")
        else:
            self.request.session.flash("Submission deleted!")
        return redirect

    @view_config(route_name='admin_massmail',
                       renderer='admin_massmail.mako')
    def massmail(self):
        """
        Send a massmail to all users in the system. It also stores the sent
        mail and its recipients in the database to keep a permanent record of
        sent messages.
        """
        # TODO: CSRF for massmail
        dbsession = DBSession()
        form = MassMailForm(self.request.POST, csrf_context=self.request)
        if not form.from_.data:
            settings = self.request.registry.settings
            form.from_.data = settings["mail.default_sender"]
        mail_query = dbsession.query(MassMail)
        current_page = self.request.GET.get('page', 1)
        page_url = PageURL_WebOb(self.request)
        page = Page(mail_query, page=current_page, url=page_url,
                    items_per_page=5, item_count=mail_query.count())
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
            dbsession.add(mail_record)
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
        dbsession = DBSession()
        mail = dbsession.query(MassMail).filter(MassMail.id == id_).one()
        return {'mail': mail}
