<%inherit file="base.mako"/>
<table id="scoreboard" class="table sortable">
    <thead>
        <tr>
            <th>#</th>
            <th class="avatar">Avatar</th>
            <th>Team</th>
            <th>Location</th>
            <th>Local</th>
            % for challenge in challenges:
                <th class="challenge" title="${challenge.title}">${challenge.title}</th>
            % endfor
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
            <td>${team.name}</td>
            <td>${team.country}</td>
            <td class="text-${'success' if team.local else 'danger'}">
                ${'Yes' if team.local else 'No'}
            </td>
            % for challenge in challenges:
                <td class="challenge">
                    % if challenge in [s.challenge for s in team.submissions]:
                        ${challenge.points + [s for s in team.submissions if s.challenge == challenge][0].additional_pts}
                    % elif challenge.dynamic:
                        ${challenge.module.get_points(team)}
                    % else:
                        -
                    % endif
                </td>
            % endfor
            <td>${points}</td>
        </tr>
    % endfor
    </tbody>
</table>
