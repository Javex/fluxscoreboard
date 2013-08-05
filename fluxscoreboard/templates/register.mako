<%inherit file="base.mako"/>

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
                ${form.timezone(class_="form-control select2", **{'data-placeholder': 'Please choose a timezone'})}
                % for msg in form.errors.get("timezone", []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
        </div>
        <div class="col-4"></div>
        <div class="col-8">
            ${form.submit(class_="btn btn-primary")}
        </div>
    </form>
</div>
<div class="col-2"></div>
