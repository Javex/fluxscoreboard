<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Submissions</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>Team (ID)</th>
                <th>Challenge (ID)</th>
                <th>Timestamp (UTC)</th>
                <th>Points</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
    % for submission in items:
            <tr class="${'success' if form.challenge.data == submission.challenge and form.team.data == submission.team else ''}">
                <td>${submission.team} (${submission.team_id})</td>
                <td>${submission.challenge} (${submission.challenge_id})</td>
                <td>${submission.timestamp.strftime("%Y-%m-%d %H:%M:%S")}</td>
                <td>${submission.points}</td>
                <td class="btn-group">
                    <button type="button" class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">
                        Action <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a href="${request.route_url('admin_submissions_edit', cid=submission.challenge_id, tid=submission.team_id, _query=dict(page=page.page))}">Edit</a></li>
                        <li><a href="${request.route_url('admin_submissions_delete', cid=submission.challenge_id, tid=submission.team_id, _query=dict(page=page.page))}">Delete</a></li>
                    </ul>
                </td>
            </tr>
    % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_submissions')}
% else:
    <div class="text-center text-info lead">
        <em>No submissions yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_submissions', form, "Submission", is_new, page.page)}
