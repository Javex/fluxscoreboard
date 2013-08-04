<%inherit file="base.mako"/>
<%namespace name="announcements" file="announcements.mako"/>
<div class="panel panel-primary">
    <div class="panel-heading">
        <h3 class="panel-title">${challenge.title}</h3>
    </div>
    <div class="row">
        ${challenge.text}
    </div>
    <div class="row">
        <form method="POST" action="${request.route_url('challenge', id=challenge.id)}" class="form-horizontal">
            <legend>Enter solution for challenge</legend>
            ${form.solution.label(class_='control-label col-2')}
            <div class="col-6">
                ${form.solution(class_='form-control', required=True, placeholder=form.solution.label.text)}
                % for msg in getattr(form.solution, 'errors', []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            <div class="col-2">${form.submit(class_='form-control btn btn-default')}</div>
        </form>
    </div>
</div>

${announcements.render_announcements(challenge.announcements)}

