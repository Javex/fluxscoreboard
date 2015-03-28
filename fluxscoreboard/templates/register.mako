<%inherit file="base.mako"/>
<%
from fluxscoreboard.util import tz_str, now
import pytz
%>

% if now() < request.settings.ctf_start_date:
    <div class="alert alert-info">The ${request.registry.settings['competition_type']} starts at ${tz_str(request.settings.ctf_start_date, pytz.utc)} UTC. You can find further information under <a href="${request.route_url('rules')}">${request.route_url('rules')}</a></div>
% endif

<div class="col-2"></div>
<div class="col-8">
    <form class="form-horizontal" method="POST" action="${request.route_url('register')}">
        <legend>Register</legend>
        <div class="form-group">
            ${form.name.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.name(class_="form-control", placeholder=form.name.label.text, required=True)}
                % for msg in form.errors.get("name", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.email.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.email(class_="form-control", placeholder=form.email.label.text, required=True)}
                % for msg in form.errors.get("email", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.email_repeat.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.email_repeat(class_="form-control", placeholder=form.email_repeat.label.text, required=True)}
                % for msg in form.errors.get("email_repeat", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.password.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.password(class_="form-control", placeholder=form.password.label.text, required=True)}
                % for msg in form.errors.get("password", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.password_repeat.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.password_repeat(class_="form-control", placeholder=form.password_repeat.label.text, required=True)}
                % for msg in form.errors.get("password_repeat", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.size.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.size(class_="form-control", placeholder=form.size.label.text)}
                <span class="help-block">
                    For statistical purposes we would like to know how many you are. 
                    There is no limitation on the number of people each team may bring, we just like to know the sizes of teams.
                </span>
                % for msg in form.errors.get("size", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.country.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.country(class_="form-control")}
                % for msg in form.errors.get("country", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.timezone.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.timezone(class_="form-control")}
                % for msg in form.errors.get("timezone", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="form-group">
            ${form.captcha.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.captcha(class_="form-control")}
                % for msg in form.errors.get("captcha", []):
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
