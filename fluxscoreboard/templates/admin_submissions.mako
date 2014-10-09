<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<%namespace name="form_funcs" file="_form_functions.mako"/>
<h1>Submissions</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>Team (ID)</th>
                <th>Challenge (ID)</th>
                <th>Timestamp (UTC)</th>
                <th>Additional Points</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
    % for submission in items:
            <tr class="${'success' if form.challenge.data == submission.challenge and form.team.data == submission.team else ''}">
                <td>${submission.team} (${submission.team_id})</td>
                <td>${submission.challenge} (${submission.challenge_id})</td>
                <td>${submission.timestamp.strftime("%Y-%m-%d %H:%M:%S")}</td>
                <td>${submission.additional_pts}</td>
                <td class="btn-group">
                    <button type="button" class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">
                        Action <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            ${form_funcs.render_submission_button_form(request.route_url('admin_submissions', _query=dict(page=page.page)), submission.challenge_id, submission.team_id, "Edit", request)}
                        </li>
                        <li class="confirm-delete">
                            ${form_funcs.render_submission_button_form(request.route_url('admin_submissions_delete', _query=dict(page=page.page)), submission.challenge_id, submission.team_id, "Delete", request)}
                        </li>
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

${admin_funcs.display_admin_form('admin_submissions_edit', form, "Submission", is_new, page.page)}
