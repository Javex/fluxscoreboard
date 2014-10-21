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
                    <td>
                        % if submission.challenge.manual:
                            ${submission.additional_points}
                        % else:
                            ${submission.challenge.base_points + submission.additional_pts}
                        % endif
                    </td>
                    <td>
                        % if submission.challenge.manual:
                            ${submission.challenge.points}
                        % else:
                            ${submission.challenge.points - submission.challenge.base_points}
                        % endif
                    </td>
                </tr>
            % endfor
        </tbody>
    </table>
</div>