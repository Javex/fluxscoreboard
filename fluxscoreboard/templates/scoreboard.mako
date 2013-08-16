<%inherit file="base.mako"/>
<table class="table sortable">
    <thead>
        <tr>
            <th>#</th>
            <th>Avatar</th>
            <th>Team</th>
            <th>Location</th>
            <th>Local</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
    % for index, (team, points) in enumerate(teams, 1):
        <tr class="${'success bold' if request.team and team.id == request.team.id else ''}">
            <td>${index}</td>
            <td>
            % if team.avatar_filename:
                <img src="${request.static_url('fluxscoreboard:static/images/avatars/%s' % team.avatar_filename)}" class="avatar" title="${team.name}"/>
            % endif
            </td>
            <td>${team.name}</td>
            <td>${team.country}</td>
            <td class="text-${'success' if team.local else 'danger'}">
                ${'Yes' if team.local else 'No'}
            </td>
            <td>${points}</td>
        </tr>
    % endfor
    </tbody>
</table>
