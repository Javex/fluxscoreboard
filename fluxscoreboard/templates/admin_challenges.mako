<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Challenges</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Category</th>
                <th>Solution</th>
                <th>Points</th>
                <th>Author(s)</th>
                <th>Manual</th>
                <th>Online</th>
                <th>Dynamic</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        % for challenge in items:
            <tr class="${'success' if form.id.data == challenge.id else ''}">
                <td>${challenge.id}</td>
                <td>${challenge.title}</td>
                <td>
                % if challenge.category:
                    ${challenge.category}
                % else:
                    <em>None</em>
                % endif
                </td>
                <td><em>Hidden</em></td>
                <td>${'dynamic' if challenge.dynamic else challenge.points}</td>
                <td>
                % if challenge.author:
                    ${challenge.author}
                % else:
                    <em>None</em>
                % endif
                </td>
                <td class="text-${'success' if challenge.manual else 'danger'}">
                    ${'Yes' if challenge.manual else 'No'}
                </td>
                <td class="text-${'success' if challenge.online else 'danger'}">
                    ${'Yes' if challenge.online else 'No'}
                </td>
                <td class="text-${'success' if challenge.dynamic else 'danger'}">
                    ${'Yes' if challenge.dynamic else 'No'}
                </ts>
                <td class="btn-group">
                    ${admin_funcs.display_action_list(page.page, request, challenge.id,
                                                      [('admin_challenges', "Edit"),
                                                       ('admin_challenges_delete', "Delete"), 
                                                       ('admin_challenges_toggle_status', "Take Challenge " + ("offline" if challenge.online else "online"))])}
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

${admin_funcs.display_admin_form('admin_challenges_edit', form, "Challenge", is_new, page.page)}
