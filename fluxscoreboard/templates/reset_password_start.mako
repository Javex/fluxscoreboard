<%
from fluxscoreboard.util import display_design
%>
<%inherit file="base.mako"/>
% if display_design(request):

    <div class="paper paper-curl">
        <h2>Forgot Passowrd?</h2>
        <form method="POST" action="${request.route_url('reset-password-start')}">
            <div class="form-group">
                    ${form.email(class_="form-control", placeholder=form.email.label.text, required=True)}
                % for msg in form.errors.get("email", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            ${form.submit()}
            ${form.csrf_token}
        </form>
    </div>

% else:

    <div class="col-2"></div>
    <div class="col-8">
        <form class="form-horizontal" method="POST" action="${request.route_url('reset-password-start')}">
            <legend>Forgot Password?</legend>
            <div class="form-group">
                ${form.email.label(class_="col-4 control-label")}
                <div class="col-8">
                    ${form.email(class_="form-control", placeholder=form.email.label.text, required=True)}
                    % for msg in form.errors.get("email", []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                </div>
            </div>
            <div class="col-4"></div>
            <div class="col-8">
                ${form.csrf_token}
                ${form.submit(class_="btn btn-primary")}
            </div>
        </form>
    </div>
    <div class="col-2"></div>

% endif