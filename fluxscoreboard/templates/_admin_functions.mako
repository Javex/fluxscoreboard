<%def name="display_admin_form(route_name, form, title, is_new)">
<% from fluxscoreboard.forms import required_validator %>
<% from wtforms.fields.core import IntegerField %>
<% from wtforms.fields.simple import TextAreaField, TextField %>
<% from wtforms.fields.html5 import EmailField %>
<form method="POST" action="${request.route_url(route_name)}" class="form-horizontal">
    <legend>${('New ' if is_new else 'Edit') + ' ' + title}</legend>
    % for field in [item for item in form if item.name not in ["id", "submit", "cancel"]]:
    <div class="form-group">
        ${field.label(class_="col-4 control-label")}
        <div class="col-8">
            <% 
            field_kwargs = {}
            if required_validator in field.validators:
                field_kwargs["required"] = "required"
            for type_ in [TextField, TextAreaField, EmailField, IntegerField]:
                if isinstance(field, type_):
                    field_kwargs["placeholder"] = field.label.text
                    break
            %>
            ${field(class_="form-control", **field_kwargs)}
            % for msg in getattr(field, 'errors', []):
                <div class="alert alert-danger">${msg}</div>
            % endfor
        </div>
    </div>
    % endfor
    <div class="col-4"></div>
    <div class="col-8">
        % if getattr(form, 'id', None) is not None:
            ${form.id()}
        % endif
        % if not is_new:
            ${form.cancel(class_="btn btn-default")}
        % endif
        ${form.submit(class_="btn btn-primary")}
    </div>
</form>
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
