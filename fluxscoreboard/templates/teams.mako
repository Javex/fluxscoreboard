<%inherit file="base.mako"/>
<table id="teams" class="table">
    <thead>
        <tr>
            <th>#</th>
            <th class="avatar">Avatar</th>
            <th>Team</th>
            <th>Location</th>
        </tr>
    </thead>
    <tbody>
    % for team in teams:
        <tr class="${'success bold' if request.team and team.id == request.team.id else ''}">
            <td>${loop.index}</td>
            <td>
            % if team.avatar_filename:
                <img src="${request.static_url('fluxscoreboard:static/images/avatars/%s' % team.avatar_filename)}" class="avatar" title="${team.name}"/>
            % endif
            </td>
            <td>${team.name}</td>
            <td>${team.country}</td>
        </tr>
    % endfor
    </tbody>
</table>
