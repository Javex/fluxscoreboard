<%inherit file="base.mako"/>

<div class="col-2"></div>
<div class="col-8">
    <form class="form-horizontal" method="POST" action="${request.route_url('login')}">
        <legend>Login</legend>
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
            ${form.password.label(class_="col-4 control-label")}
            <div class="col-8">
                ${form.password(class_="form-control", placeholder=form.password.label.text, required=True)}
                % for msg in form.errors.get("password", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="col-4"></div>
        <div class="col-8">
            ${form.login(class_="btn btn-primary")}
        </div>
    </form>
</div>
<div class="col-2"></div>
