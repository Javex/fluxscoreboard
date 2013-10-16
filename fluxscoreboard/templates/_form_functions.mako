<%def name="render_form(action, form, legend, display_cancel=True, enctype='application/x-www-form-urlencoded')">
<% from fluxscoreboard.forms.validators import required_validator %>
<% from fluxscoreboard.forms.fields import IntegerOrEvaluatedField %>
<% from wtforms.fields.core import IntegerField %>
<% from wtforms.fields.simple import TextAreaField, TextField, FileField %>
<% from wtforms.fields.html5 import EmailField, IntegerField as IntegerFieldHtml5 %>
<form method="POST" action="${action}" class="form-horizontal" enctype="${enctype}">
    <legend>${legend}</legend>
    % for field in [item for item in form if item.name not in ["id", "submit", "cancel", "csrf_token"]]:
    <div class="form-group">
        ${field.label(class_="col-4 control-label")}
        <div class="col-8">
## This is a really ugly solution to a limitation of WTForms. It would be a lot nicer to rebuild the form fields so they do this automatically.
            <% 
            field_kwargs = {}
            if required_validator in field.validators:
                field_kwargs["required"] = "required"
            for type_ in [TextField, TextAreaField, EmailField, IntegerField, IntegerOrEvaluatedField, IntegerFieldHtml5]:
                if isinstance(field, type_):
                    field_kwargs["placeholder"] = field.label.text
                    break
            if field.name == "solution":
                field_kwargs["autocomplete"] = "off"
            %>
            ${field(class_="form-control" if not isinstance(field, FileField) else "", **field_kwargs)}
            % if field.description:
                <span class="help-block">${field.description}</span>
            % endif
            % for msg in getattr(field, 'errors', []):
                <div class="alert alert-danger">${msg}</div>
            % endfor
        </div>
    </div>
    % endfor
    <div class="col-4"></div>
    <div class="col-8">
        ${form.csrf_token}
        % if getattr(form, 'id', None) is not None:
            ${form.id()}
        % endif
        ${form.submit(class_="btn btn-primary")}
        % if display_cancel and hasattr(form, 'cancel'):
            ${form.cancel(class_="btn btn-default")}
        % endif
    </div>
</form>
</%def>

<%def name="render_button_form(action, id_, title, request)">
<%
from fluxscoreboard.forms.admin import ButtonForm 
from webob.multidict import MultiDict
form = ButtonForm(MultiDict(id=id_), csrf_context=request, title=title)
%>
<form method="POST" action="${action}">
    ${form.button(class_="btn btn-primary")}
    ${form.csrf_token}
    ${form.id}
</form>
</%def>

<%def name="render_submission_button_form(action, challenge_id, team_id, title, request)">
<%
from fluxscoreboard.forms.admin import SubmissionButtonForm 
from webob.multidict import MultiDict
form = SubmissionButtonForm(MultiDict(challenge_id=challenge_id, team_id=team_id), csrf_context=request, title=title)
%>
<form method="POST" action="${action}">
    ${form.button(class_="btn btn-primary")}
    ${form.csrf_token}
    ${form.challenge_id}
    ${form.team_id}
</form>
</%def>
