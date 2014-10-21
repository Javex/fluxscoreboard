<%
from fluxscoreboard.util import now
%>
% if challenge.text:
    <p>${challenge.text}</p>
% endif
% if not request.settings.archive_mode and challenge.online and not request.settings.submission_disabled and not now() > request.settings.ctf_end_date:
    <form method="POST" action="${request.route_url('dynamic_protocols', id=challenge.id)}">
        ${form.flag(placeholder="Enter flag here...")}
        ${form.csrf_token}
        ${form.submit}
    </form>
% elif request.settings.archive_mode:
    <p class="text-warning text-center">This challenge cannot be solved in archive mode.</p>
% elif request.settings.ctf_ended:
    <p class="text-danger text-center">The CTF is over. You cannot submit any more solutions.</p>
% elif request.settings.submission_disabled:
    <p class="text-info text-center">Submission of solution is currently disabled, sorry.</p>
% elif not challenge.online:
    <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
% else:
    <p class="text-danger text-center">Something is seriously wrong here! Contact FluxFingers fluxfingers@rub.de</p>
% endif
<ul class="protocols">
% for protocol in protocols:
    <li class="${'true' if request.team and protocol in [p.protocol for p in request.team.protocols] else ''}">${protocol.name}</li>
% endfor
</ul>

