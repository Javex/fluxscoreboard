<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Teams</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Country</th>
                <th>Local</th>
                <th>Active</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
    % for team in items:
            <tr class="${'success' if form.id.data == team.id else ''}">
                <td>${team.id}</td>
                <td>${team.name}</td>
                <td>${team.email}</td>
                <td>${team.country}</td>
                <td class="text-${'success' if team.local else 'danger'}">
                    ${'Yes' if team.local else 'No'}
                </td>
                <td class="text-${'success' if team.active else 'danger'}">
                    ${team.active}
                </td>
                <td class="btn-group">
                    <button type="button" class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">
                        Action <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a href="${request.route_url('admin_teams_edit', id=team.id, _query=dict(page=page.page))}">Edit</a></li>
                        <li><a href="${request.route_url('admin_teams_delete', id=team.id, _query=dict(page=page.page))}">Delete</a></li>
                        <li>
                            <a href="${request.route_url('admin_teams_activate', id=team.id, _query=dict(page=page.page))}">
                                % if team.active:
                                    Deactivate Team
                                % else:
                                    Activate Team
                                % endif
                            </a>
                        </li>
                        <li>
                            <a href="${request.route_url('admin_teams_toggle_local', id=team.id, _query=dict(page=page.page))}">
                                % if team.local:
                                    Make Team Remote
                                % else:
                                    Make Team Local
                                % endif
                            </a>
                        </li>
                    </ul>
                </td>
            </tr>
    % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_teams')}
% else:
    <div class="text-center text-info lead">
        <em>No teams yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_teams', form, "Team", is_new, page.page)}
