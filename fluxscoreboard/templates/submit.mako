<%inherit file="base.mako"/>
<%
from fluxscoreboard.util import now, display_design
%>
% if request.settings.archive_mode:
    <p class="text-warning text-center">Scoreboard is in archive mode. You can submit solutions, but you will only receive feedback and are not entered into the scoreboard</p>
% endif
% if (not request.settings.submission_disabled and list(form.challenge) and not now() > request.settings.ctf_end_date) or request.settings.archive_mode:
    % if display_design(request):

    <div class="paper paper-curl">
        <h2>Submit Solution</h2>
        <form method="POST" action="${request.route_url('submit')}">
            <div class="form-group">
                ${form.solution(class_='form-control', required=True, placeholder='Enter flag here...')}
                % for msg in getattr(form.solution, 'errors', []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            <div class="form-group">
                ${form.challenge(class_='form-control')}
                % for msg in getattr(form.challenge, 'errors', []):
                    <div class="alert alert-danger">${msg}</div>
                % endfor
            </div>
            ${form.submit()}
            ${form.csrf_token}
        </form>
    </div>


    % else:

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

    % endif
% elif now() > request.settings.ctf_end_date:
    <div class="alert alert-danger">The ${request.registry.settings['competition_type']} is over. You cannot submit any more solutions.</div>
% elif request.settings.submission_disabled:
    <div class="alert alert-info">Sorry, but submission of solutions is currently disabled.</div>
% elif not list(form.challenge):
    <div class="alert alert-info">Right now, there are no challenges to submit solutions for.</div>
% endif
