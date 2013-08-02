<% from pyramid.security import authenticated_userid, has_permission %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/jquery.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/bootstrap.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/hacklu.js')}"></script>
        
        <link href="${request.static_url('fluxscoreboard:static/css/bootstrap.min.css')}" rel="stylesheet" />
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
            <ul class="nav navbar-nav pull-right">
                <li>
                % if request.path.startswith('/admin'):
                    <a href="${request.route_url('news')}">Frontpage</a>
                % else:
                    <a href="${request.route_url('admin_news')}">Admin</a>
                % endif
                </li>
            </ul>
        </div>
        % for msg in request.session.pop_flash():
        <div class="alert alert-info">${msg}</div>
        % endfor
        % for msg in request.session.pop_flash("warning"):
        <div class="alert">${msg}</div>
        % endfor
        % for msg in request.session.pop_flash("error"):
        <div class="alert alert-danger">${msg}</div>
        % endfor
        ${self.body()}
    </body>
</html>
