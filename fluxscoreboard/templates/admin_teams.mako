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
                        ${admin_funcs.display_action_list(page.page, request, team.id,
                                                        [('admin_teams_edit', "Edit"), 
                                                         ('admin_teams_delete', "Delete"), 
                                                         ('admin_teams_activate', ("Deactivate" if team.active else "Activate") + " Team"),
                                                         ('admin_teams_toggle_local', "Make Team " + ("Remote" if team.local else "Local"))])}
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
