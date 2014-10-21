<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Feedback for Challenge ${challenge.title}</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>Team</th>
                <th>Rating</th>
                <th>Note</th>
            </tr>
        </thead>
        <tbody>
        % for feedback in items:
            <tr>
                <td>${feedback.team.name}</td>
                <td>${feedback.rating}</td>
                <td>${feedback.note}</td>
            </tr>
        % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_challenges')}
% else:
    <div class="text-center text-info lead">
        <em>No feedback for this challenge, yet!</em>
    </div>
% endif
