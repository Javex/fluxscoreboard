<%
from fluxscoreboard.util import display_design, tz_str, is_admin_path, now
import pytz
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <link rel="shortcut icon" href="${request.static_url('fluxscoreboard:static/images/favicon.ico')}" />
        <script src="${request.static_url('fluxscoreboard:static/js/jquery.min.js')}"></script>
        
        % if not display_design(request):
            <script src="${request.static_url('fluxscoreboard:static/js/bootstrap.min.js')}"></script>
        % endif

        <script src="${request.static_url('fluxscoreboard:static/js/sorttable.js')}"></script>
        % if is_admin_path(request):
            <script src="${request.static_url('fluxscoreboard:static/js/admin.js')}"></script>
        % else:
            <script src="${request.static_url('fluxscoreboard:static/js/hacklu.js')}"></script>
        % endif
        
        ## Here, we display different stylesheets based on routes to not give away the design before contest has started.
        ## We also load this for the admin backend as we don't need a super-duper design there.
        % if display_design(request):
            <link href="${request.static_url('fluxscoreboard:static/css/wildwildweb.css')}" rel="stylesheet">
        % else:
            <link href="${request.static_url('fluxscoreboard:static/css/bootstrap.min.css')}" rel="stylesheet">
        % endif
        <link href="${request.static_url('fluxscoreboard:static/css/hacklu.css')}" rel="stylesheet">
        
        <title>Hack.lu ${now().year} CTF</title>
    </head>

    % if display_design(request):

        <div class="bg">
            <h1>- HACK.LU CTF 2014 -</h1>
            <nav>
                % for name, title in view.menu:
                    % if name:
                        % if not loop.first:
                            &clubs;
                        % endif
                        <a href="${request.route_url(name)}" class="${'active' if request.path_url.startswith(request.route_url(name)) else ''}">${title}</a>
                    % endif
                % endfor
            </nav>
            <div class="content-wrapper">
                <div class="flash">
                    % for queue, css_type in [('', 'info'), ('error', 'danger'), ('success', 'success'), ('warning', '')]:
                        ${render_flash(queue, css_type)}
                    % endfor
                </div>
                ${self.body()}
            </div>
            <div class="grunge-top-bg"></div>
            <div class="grunge-bottom-bg"></div>
            <div class="sun"></div>
            <a href="https://fluxfingers.net/" target="_blank" class="logo">&nbsp;</a>
            <footer></footer>
        </div>

    % else:

    <body class="container">
        <div id="menu" class="navbar ${'navbar-admin' if is_admin_path(request) else ''}">
            <ul class="nav navbar-nav">
            % for name, title in view.menu:
                <li class="${'active' if request.path_url.startswith(request.route_url(name)) else ''}">
                    <a href="${request.route_url(name)}">${title}</a>
                </li>
            % endfor
            </ul>
            % if is_admin_path(request):
            <ul class="nav navbar-nav pull-right">
                <li>
                    <a href="${request.route_url('test_login')}">[Test-Login]</a>
                </li>
                <li>
                    <a href="${request.route_url('home')}">Frontpage</a>
                </li>
            </ul>
            % endif
        </div>
        <div class="flash">
            % for queue, css_type in [('', 'info'), ('error', 'danger'), ('success', 'success'), ('warning', '')]:
                ${render_flash(queue, css_type)}
            % endfor
        </div>
        ${self.body()}
    </body>

    % endif

</html>


<%def name="render_flash(queue='', css_type='info')">
% for msg in request.session.pop_flash(queue):
<div class="alert ${'alert-%s' % css_type if css_type else ''}">${msg}</div>
% endfor
</%def>


<%def name="orb(title)">
<div class="perc-orb">
    <div data-value="${int(round(request.team.get_category_solved(title) * 100, 0)) if request.team else '-'}" class="perc"></div>
    <a href="#">${title}</a>
</div>
</%def>
