import pytest


class BaseViewTest(object):

    @pytest.fixture(autouse=True)
    def _prepare(self, make_team, make_challenge, dbsession, pyramid_request,
                 login_team, dbsettings):
        self.make_team = make_team
        self.make_challenge = make_challenge
        self.login = login_team
        self.dbsession = dbsession
        self.settings = dbsettings
        self.view = self.view_class(pyramid_request)
        self.request = pyramid_request
        self.request.POST['csrf_token'] = self.request.session.get_csrf_token()
