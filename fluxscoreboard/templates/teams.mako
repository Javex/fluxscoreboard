<%inherit file="base.mako"/>
% if teams:
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
                <td>${loop.index + 1}</td>
                <td class="avatar">
                % if team.avatar_filename:
                    <img src="${request.route_url('avatar', avatar=team.avatar_filename)}" class="avatar" title="${team.name}"/>
                % else:
                    &nbsp;
                % endif
                </td>
                <td>${team.name}</td>
                <td>${team.country}</td>
            </tr>
        % endfor
        </tbody>
    </table>
% else:
    <p>No teams have registered, yet!</p>
% endif
