<%inherit file="base.mako"/>
<table class="table">
    <thead>
        <tr>
            <th>#</th>
            <th>Team</th>
            <th>Location</th>
            <th>Local</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
    % for index, (team, points) in enumerate(teams, 1):
        <tr>
            <td>${index}</td>
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
