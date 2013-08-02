<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Challenges</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Solution</th>
                <th>Points</th>
                <th>Manual</th>
                <th>Published</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
    % for challenge in items:
            <tr class="${'success' if form.id.data == challenge.id else ''}">
                <td>${challenge.id}</td>
                <td>${challenge.title}</td>
                <td>${challenge.solution}</td>
                <td>${challenge.points}</td>
                <td class="text-${'success' if challenge.manual else 'danger'}">
                    ${'Yes' if challenge.manual else 'No'}
                </td>
                <td class="text-${'success' if challenge.published else 'danger'}">
                    ${'Yes' if challenge.published else 'No'}
                </td>
                <td class="btn-group">
                    <button type="button" class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">
                        Action <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a href="${request.route_url('admin_challenges_edit', id=challenge.id)}">Edit</a></li>
                        <li><a href="${request.route_url('admin_challenges_delete', id=challenge.id)}">Delete</a></li>
                        <li>
                            <a href="${request.route_url('admin_challenges_toggle_status', id=challenge.id)}">
                                % if challenge.published:
                                    Unpublish Challenge
                                % else:
                                    Publish Challenge
                                % endif
                            </a>
                        </li>
                    </ul>
                </td>
            </tr>
    % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_challenges')}
% else:
    <div class="text-center text-info lead">
        <em>No challenges yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_challenges', form, "Challenge", is_new)}
