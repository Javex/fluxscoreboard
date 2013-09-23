<%
from pyramid.security import authenticated_userid, has_permission
from fluxscoreboard.util import display_design
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/jquery.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/bootstrap.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/hacklu.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/sorttable.js')}"></script>
        % if request.path.startswith('/admin'):
            <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/admin.js')}"></script>
        % endif
        
        ## Here, we display different stylesheets based on routes to not give away the design before contest has started.
        ## We also load this for the admin backend as we don't need a super-duper design there.
        % if display_design(request):
            <link href="${request.static_url('fluxscoreboard:static/css/hacklu-base.min.css')}" rel="stylesheet" />
        % else:
            <link href="${request.static_url('fluxscoreboard:static/css/bootstrap.min.css')}" rel="stylesheet" />
        % endif
        <link href="${request.static_url('fluxscoreboard:static/css/hacklu.css')}" rel="stylesheet" />
        
        <title>Hack.lu 2013 CTF</title>
    </head>
    <body class="container">
        <div id="menu" class="navbar ${'navbar-admin' if request.path.startswith('/admin') else ''}">
            <ul class="nav navbar-nav">
            % for name, title in view.menu:
                <li class="${'active' if request.path_url.startswith(request.route_url(name)) else ''}">
                    <a href="${request.route_url(name)}">${title}</a>
                </li>
            % endfor
            </ul>
            % if request.path.startswith('/admin'):
            <ul class="nav navbar-nav pull-right">
                <li>
                    <a href="${request.route_url('news')}">Frontpage</a>
                </li>
            </ul>
            % endif
        </div>
        % for queue, css_type in [('', 'info'), ('error', 'danger'), ('success', 'success'), ('warning', '')]:
            ${render_flash(queue, css_type)}
        % endfor
        ${self.body()}
    </body>
</html>

<%def name="render_flash(queue='', css_type='info')">
% for msg in request.session.pop_flash(queue):
<div class="alert ${'alert-%s' % css_type if css_type else ''}">${msg}</div>
% endfor
</%def>
