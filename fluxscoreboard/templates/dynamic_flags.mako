<%
from fluxscoreboard.util import now
%>

% if challenge.text:
    <p>${challenge.text}</p>
% endif
<p>
    This challenge is a special challenge. You can collect some minor extra
    points here by proving that you are a truly international player. Each time
    you visit your reference URL from a different country, that flag will be
    activated and you gain an additional point. You already have
    ${"%d/%d" % flag_stats} points.
</p>
% if challenge.online and not request.settings.submission_disabled and not now() > request.settings.ctf_end_date:
    <p>To collect points for that challenge, use this URL: <a href="${request.route_url('ref', ref_id=team.ref_token)}">${request.route_url('ref', ref_id=team.ref_token)}</a></p>
% elif now() > request.settings.ctf_end_date:
    <p class="text-danger text-center">The CTF is over. You cannot submit any more solutions.</p>
% elif challenge.manual:
    <p class="text-warning text-center">This challenge is evaluated manually, you cannot submit a solution for it.</p>
% elif request.settings.submission_disabled:
    <p class="text-info text-center">Submission of solution is currently disabled, sorry.</p>
% elif not challenge.online:
    <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
% else:
    <p class="text-danger text-center">Something is seriously wrong here! Contact FluxFingers fluxfingers@rub.de</p>
% endif
<p class="text-danger">
    <b>Disclaimer:</b> Please do <em>not</em> attempt to hack real-world systems for
    a single point. That is illegal and we assure you it is not worth a single
    point!
</p>
<div class="flag-container">
% for flag_row in flags:
    <div class="row">
    % for flag, visited in flag_row:
        <div style="float:left;margin:3px" class="flag ${flag} ${'inactive' if not visited else ''}" title="${flag}"></div>
    % endfor
    </div>
% endfor
</div>
