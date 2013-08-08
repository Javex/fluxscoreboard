<%namespace name="form_funcs" file="_form_functions.mako"/>
<%def name="display_admin_form(route_name, form, title, is_new, current_page)">
${form_funcs.render_form(request.route_url(route_name, _query=dict(page=current_page)),
                         form,
                         ('New ' if is_new else 'Edit') + ' ' + title,
                         display_cancel=not is_new)
                         }
</%def>

<%def name="display_pagination(page, route_name)">
% if page.page_count > 1:
<div class="text-center">
    <ul class="pagination">
        <li><a href="${request.route_url(route_name, _query=dict(page=(1 if page.page == 1 else page.page - 1)))}">&laquo;</a></li>
        % for page_no in range(1, page.page_count + 1):
            <li class="${'disabled' if page.page == page_no else ''}" >
                <a href="${request.route_url(route_name, _query=dict(page=page_no))}">${page_no}</a>
            </li>
        % endfor
        <li><a href="${request.route_url(route_name, _query=dict(page=(page.last_page if page.page == page.last_page else page.page + 1)))}">&raquo;</a></li>
    </ul>
</div>
% endif
</%def>

<%def name="display_action_list(page, request, id_, routes)">
<button type="button" class="btn btn-primary btn-small dropdown-toggle" data-toggle="dropdown">
    Action <span class="caret"></span>
</button>
<ul class="dropdown-menu">
% for route, title in routes:
    <li>
        ${form_funcs.render_button_form(request.route_url(route, _query=dict(page=page)), id_, title, request)}
    </li>
% endfor
</ul>
</%def>
