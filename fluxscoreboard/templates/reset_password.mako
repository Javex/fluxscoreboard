<%inherit file="base.mako"/>
<div class="col-2"></div>
<div class="col-8">
    <form class="form-horizontal" method="POST" action="${request.route_url('reset-password', token=token)}">
        <legend>Reset Password</legend>
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
        <div class="col-4"></div>
        <div class="col-8">
            ${form.csrf_token}
            ${form.submit(class_="btn btn-primary")}
        </div>
    </form>
</div>
<div class="col-2"></div>
