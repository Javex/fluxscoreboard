<%
from fluxscoreboard.util import display_design
%>
<%inherit file="base.mako"/>
<table class="table sortable${' paper paper-curled listing' if display_design(request) else ''}">
    <thead>
        <tr>
            <th>#</th>
            <th>Title</th>
            <th>Category</th>
            <th>Author(s)</th>
            <th>Points</th>
            <th>#Solved</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
    % for index, (challenge, team_solved, solved_count) in enumerate(challenges, 1):
        <tr class="${'solved-challenge' if team_solved or challenge.dynamic and request.team and challenge.module.is_solved(request.team) else ''}">
            <td>${index}</td>
            <td class="lefty">
                <a href="${request.route_url('challenge', id=challenge.id)}">${challenge.title}</a>
            </td>
## The 'z'*20 solution is veeeery ugly: We should fix it so sorttable treats it as special somehow
            <td sorttable_customkey="${challenge.category or 'z'*20}" class="lefty">
            % if challenge.category:
                ${challenge.category}
            % else:
                <em>None</em>
            % endif
            </td>
            <td>${challenge.author}</td>
            <td sorttable_customkey="${0 if challenge.manual else challenge.base_points}">
                % if challenge.dynamic:
                    ${" / ".join(map(str, challenge.module.get_points(request.team)))}
                % elif challenge.manual:
                    <em>${challenge.points}</em>
                % else:
                    ${challenge.base_points} (+ ${challenge.points - challenge.base_points if challenge.points else 100})
                % endif
            </td>
            <td>
                ${solved_count}
            </td>
            <td class="text-${'success' if challenge.online else 'danger'}">
                ${'online' if challenge.online else 'offline'}
            </td>
        </tr>
    % endfor
    </tbody>
</table>
