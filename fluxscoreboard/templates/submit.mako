<%inherit file="base.mako"/>
<%
from fluxscoreboard.models import settings
from fluxscoreboard.util import now
%>
% if not settings.get().submission_disabled and list(form.challenge) and not now() > settings.get().ctf_end_date:
<form class="form-horizontal" method="POST" action="${request.route_url('submit')}">
    <legend>Enter solution for challenge</legend>
    <div class="form-group">
        ${form.solution.label(class_='control-label col-2')}
        <div class="col-6">
            ${form.solution(class_='form-control', required=True, placeholder=form.solution.label.text)}
            % for msg in getattr(form.solution, 'errors', []):
                <div class="alert alert-danger">${msg}</div>
            % endfor
        </div>
    </div>
    <div class="form-group">
        ${form.challenge.label(class_='control-label col-2')}
        <div class="col-6">
            ${form.challenge(class_='form-control')}
            % for msg in getattr(form.challenge, 'errors', []):
                <div class="alert alert-danger">${msg}</div>
            % endfor
        </div>
    </div>
    <div class="form-group">
        <div class="col-2"></div>
        <div class="col-2">
            ${form.csrf_token}
            ${form.submit(class_='form-control btn btn-default')}
        </div>
    </div>
</form>
% elif now() > settings.get().ctf_end_date:
    <div class="alert alert-danger">The CTF is over. You cannot submit any more solutions.</div>
% elif settings.get().submission_disabled:
    <div class="alert alert-info">Sorry, but submission of solutions is currently disabled.</div>
% elif not list(form.challenge):
    <div class="alert alert-info">Right now, there are no challenges to submit solutions for.</div>
% endif
