<%
from fluxscoreboard.util import display_design
%>
<%inherit file="base.mako"/>
<table id="scoreboard" class="table sortable${' paper paper-curled listing' if display_design(request) else ''}">
    <thead>
        <tr>
            <th>#</th>
            <th class="avatar">Avatar</th>
            <th>Teamname</th>
            <th>Location</th>
            <th>Local</th>
            <th>Base Points</th>
            <th>Bonus Points</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
    % for team, points, rank in teams:
        <tr class="${'success bold' if request.team and team.id == request.team.id else ''}">
            <td>${rank}</td>
            <td class="avatar">
            % if team.avatar_filename:
                <img src="${request.route_url('avatar', avatar=team.avatar_filename)}" class="avatar" title="${team.name}"/>
            % else:
                &nbsp;
            % endif
            </td>
            <td class="lefty">${team.name}</td>
            <td class="lefty">${team.country}</td>
            <td class="text-${'success' if team.local else 'danger'}">
                ${'Yes' if team.local else 'No'}
            </td>
            <td>base</td>
            <td>bonus</td>
            <td>${points}</td>
        </tr>
    % endfor
    </tbody>
</table>