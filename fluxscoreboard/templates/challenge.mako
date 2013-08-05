<%inherit file="base.mako"/>
<%namespace name="announcements" file="announcements.mako"/>
<div class="panel panel-primary">
    <div class="panel-heading">
        <h3 class="panel-title">${challenge.title}</h3>
    </div>
    <div class="col-12">
        <div class="row">
            ${challenge.text}
        </div>
        <div class="row">&nbsp;</div>
        <div class="row">
        % if not is_solved and challenge.published and not challenge.manual and not request.registry.settings["submission_disabled"]:
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
        % elif is_solved:
            <p class="text-success text-center">Congratulations! You have already solved this challenge.</p>
        % elif challenge.manual:
            <p class="text-warning text-center">This challenge is evaluated manually, you cannot submit a solution for it.</p>
        % elif request.registry.settings["submission_disabled"]:
            <p class="text-info text-center">Submission of solution is currently disabled, sorry.</p>
        % elif not challenge.published:
            <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
        % else:
            <p class="text-error text-center">Something is seriously wrong here! Contact FluxFingers hacklu@fluxfingers.net</p>
        % endif
        </div>
    </div>
    <div class="clearfix"></div>
</div>

${announcements.render_announcements(challenge.announcements, False)}

