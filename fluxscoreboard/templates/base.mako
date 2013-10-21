<%
from pyramid.security import authenticated_userid, has_permission
from fluxscoreboard.util import display_design, tz_str
import pytz
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <link rel="shortcut icon" href="${request.static_url('fluxscoreboard:static/images/favicon.ico')}" />
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/jquery.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/bootstrap.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/sorttable.js')}"></script>
        % if request.path.startswith('/admin'):
            <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/admin.js')}"></script>
        % else:
            <script type="text/javascript" src="${request.static_url('fluxscoreboard:static/js/hacklu.js')}"></script>
        % endif
        
        ## Here, we display different stylesheets based on routes to not give away the design before contest has started.
        ## We also load this for the admin backend as we don't need a super-duper design there.
        % if display_design(request):
            <link href="${request.static_url('fluxscoreboard:static/css/hacklu-base.min.css')}" rel="stylesheet" />
        % else:
            <link href="${request.static_url('fluxscoreboard:static/css/bootstrap.min.css')}" rel="stylesheet" />
        % endif
        <link href="${request.static_url('fluxscoreboard:static/css/hacklu.css')}" rel="stylesheet" />
        <link href="${request.static_url('fluxscoreboard:static/css/flags16.css')}" rel="stylesheet" />
        
        <title>Hack.lu 2013 CTF</title>
    </head>
    % if display_design(request):
    <body>
        <header>
        <div id="top">
            <h1>hack.lu CTF v.2013</h1>
        </div>
        </header>
        <div id="head-wrap">
            <div id="stats">
                <div id="stats-wrapper">
                    ${orb("Web")}
                    ${orb("Reversing")}
                    ${orb("Internals")}
                    <div id="stats-middle">
                        <div id="lgraph">
                            ctf timer progress<br>
                            <img src="${request.static_url('fluxscoreboard:static/images/lgraph_%s.png' % (int(view.ctf_progress * 10) * 10))}">
                        </div>
                        <div id="timer">
                            <div>seconds until end</div>
                            <span id="timer-seconds">${view.seconds_until_end}</span>
                        </div>
                        <div id="rgraph">
                            overall completion<br>
                            <img src="${request.static_url('fluxscoreboard:static/images/rgraph_%s.png' % (int(round(view.team.get_overall_stats(), 1) * 100) if view.team else 0))}">
                        </div>
                    </div>
                    ${orb("Crypto")}
                    ${orb("Exploiting")}
                    ${orb("Misc")}
                </div>
            </div>
            <div id="middle">
                <div id="middle-wrapper">
                    <div id="bar">
                        rank
                        <div class="bar-val">${view.team.rank if view.team else '-'}</div>
                        <hr>
                        players
                        <div class="bar-val">${view.team.size if view.team and view.team.size else '-'}</div>
                        <hr>
                        score
                        <div class="bar-val">${view.team.score if view.team else '-'}</div>
                    </div>
                    <nav>
                        <ul class="menu">
                        % for name, title in view.menu:
                            % if name and title:
                                <li class="${name} ${'active' if request.path_url.startswith(request.route_url(name)) else ''}">
                                    <a href="${request.route_url(name)}">${title}</a>
                                </li>
                            % else:
                                <li class="inactive"><a href="#">&nbsp;</a></li>
                            % endif
                        % endfor
                        </ul>
                        <div id="teamname">${view.team.name if view.team else '-'}</div>
                    </nav>
                    <img src="${request.static_url('fluxscoreboard:static/images/middle.png')}" id="orb">
                    <div id="announcements">
                        <h3>announcements</h3>
                        <div id="announce-items">
                        % for news in view.announcements:
                            <p>
                                <span>[${tz_str(news.timestamp, view.team.timezone if view.team else pytz.utc)}]</span>
                                % if news.challenge_id:
                                    <em>[${news.challenge.title}]</em>
                                % endif
                                ${news.message | n}
                            </p>
                        % endfor
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="content">
            <h2 id="scoreboard">${view.title}</h2>
            <div id="content-wrapper">
                % for queue, css_type in [('', 'info'), ('error', 'danger'), ('success', 'success'), ('warning', '')]:
                    ${render_flash(queue, css_type)}
                % endfor
                ${self.body()}
            </div>
        </div>
    </body>
    % else:
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
                    <a href="${request.route_url('test_login')}">[Test-Login]</a>
                </li>
                <li>
                    <a href="${request.route_url('home')}">Frontpage</a>
                </li>
            </ul>
            % endif
        </div>
        % for queue, css_type in [('', 'info'), ('error', 'danger'), ('success', 'success'), ('warning', '')]:
            ${render_flash(queue, css_type)}
        % endfor
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
    <div data-value="${int(round(view.team.get_category_solved(title) * 100, 0)) if view.team else '-'}" class="perc"></div>
    <a href="#">${title}</a>
</div>
</%def>
