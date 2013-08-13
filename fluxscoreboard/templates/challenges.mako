<%inherit file="base.mako"/>
<% from fluxscoreboard.models.challenge import manual_challenge_points%>
<table class="table sortable">
    <thead>
        <tr>
            <th>#</th>
            <th>Title</th>
            <th>Category</th>
            <th>Points</th>
            <th>#Solved</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
    % for index, (challenge, team_solved, solved_count) in enumerate(challenges, 1):
        <tr class="${'success' if team_solved else ''}">
            <td>${index}</td>
            <td>
                <a href="${request.route_url('challenge', id=challenge.id)}">${challenge.title}</a>
            </td>
## The 'z'*20 solution is veeeery ugly: We should fix it so sorttable treats it as special somehow
            <td sorttable_customkey="${challenge.category or 'z'*20}">
            % if challenge.category:
                ${challenge.category}
            % else:
                <em>None</em>
            % endif
            </td>
            <td>
                % if challenge.points is manual_challenge_points:
                    <em>${challenge.points}</em>
                % else:
                    ${challenge.points}
                % endif
            </td>
            <td>${solved_count}</td>
            <td class="text-${'success' if challenge.published else 'danger'}">
                ${'online' if challenge.published else 'offline'}
            </td>
        </tr>
    % endfor
    </tbody>
</table>
