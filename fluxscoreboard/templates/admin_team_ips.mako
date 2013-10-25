<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Team ${team.name} is playing with the following IPs</h1>

% if team.ips:
    <ul>
    % for ip in team.ips:
        <li>${ip}</li>
    % endfor
    </ul>
% else:
    No team login found yet!
% endif
