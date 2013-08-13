<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Categories</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        % for category in items:
            <tr class="${'success' if form.id.data == category.id else ''}">
                <td>${category.id}</td>
                <td>${category.name}</td>
                <td class="btn-group">
                    ${admin_funcs.display_action_list(page.page, request, category.id,
                                                      [('admin_categories', "Edit"),
                                                       ('admin_categories_delete', "Delete")])}
                </td>
            </tr>
        % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_categories')}
% else:
    <div class="text-center text-info lead">
        <em>No cate yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_categories_edit', form, "Category", is_new, page.page)}
