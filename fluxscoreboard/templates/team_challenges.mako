<%
from fluxscoreboard.util import display_design
%>
<%inherit file="base.mako"/>
<div class="paper paper-curl">
    <h2>Solved Challenges</h2>
    <h3>${team.name}</h3>
    <table class="listing">
        <thead>
            <tr>
                <th>Challenge Name</th>
                <th>Base Points</th>
                <th>Bonus Points</th>
            </tr>
        </thead>
        <tbody>
            % for submission in team.submissions:
                <tr>
                    <td class="lefty">
                        % if request.team:
                            <a href="${request.route_url('challenge', id=submission.challenge.id)}">${submission.challenge.title}</a>
                        % else:
                            ${submission.challenge.title}
                        % endif
                    </td>
                    <td>${submission.challenge.base_points + submission.additional_pts}</td>
                    <td>${submission.challenge.points - submission.challenge.base_points}</td>
                </tr>
            % endfor
        </tbody>
    </table>
</div>