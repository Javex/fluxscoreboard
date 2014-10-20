<%
from fluxscoreboard.util import display_design
%>
<%inherit file="base.mako"/>
% if display_design(request):

    <div class="paper paper-curl">
        <h2>Login</h2>
        <form method="POST" action="${request.route_url('login')}">
            <div class="form-group">
                ${form.email(class_="form-control", placeholder=form.email.label.text, required=True, autocomplete="off")}
                % for msg in form.errors.get("email", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            <div class="form-group">
                ${form.password(class_="form-control", placeholder=form.password.label.text, required=True, autocomplete="off")}
                % for msg in form.errors.get("password", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            ${form.login()}
            <a href="${request.route_url('reset-password-start')}" class="small-url">Forgot Password?</a>
            ${form.csrf_token}
        </form>
    </div>

% else:

    <div class="col-2"></div>
    <div class="col-8">
        <form class="form-horizontal" method="POST" action="${request.route_url('login')}">
            <legend>Login</legend>
            <div class="form-group">
                ${form.email.label(class_="col-4 control-label")}
                <div class="col-8">
                    ${form.email(class_="form-control", placeholder=form.email.label.text, required=True, autocomplete="off")}
                    % for msg in form.errors.get("email", []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                </div>
            </div>
            <div class="form-group">
                ${form.password.label(class_="col-4 control-label")}
                <div class="col-8">
                    ${form.password(class_="form-control", placeholder=form.password.label.text, required=True, autocomplete="off")}
                    % for msg in form.errors.get("password", []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                </div>
            </div>
            <div class="col-4"></div>
            <div class="col-8">
                ${form.csrf_token}
                ${form.login(class_="btn btn-primary")}
                <a href="${request.route_url('reset-password-start')}" class="small-url">Forgot Password?</a>
            </div>
        </form>
    </div>
    <div class="col-2"></div>

% endif