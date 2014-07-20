<%inherit file="base.mako"/>
<%namespace name="announcements" file="announcements.mako"/>
<%
from fluxscoreboard.util import now, nl2br
import uuid
%>
<div class="panel panel-primary">
    <div class="panel-heading">
        <h3 class="panel-title">
            ${challenge.title}
            % if challenge.category:
            (Category: ${challenge.category})
            % endif
        % if challenge.author:
            <em><small class="pull-right text-white">Author(s): ${challenge.author}</small></em>
        % endif
        </h3>
    </div>
    <div class="col-12">
    % if not challenge.dynamic:
        <div class="row">
            ${challenge.text | n}
        </div>
        <div class="row">&nbsp;</div>
        % if challenge.has_token:
        <div class="row">
            <p class="text-warning">
                    % if view.archive_mode:
                    This challenge requires a token. However, in archive mode
                    tokens are irrelevant. You can use this default token:
                    <br />
                    <code>
                        00000000-0000-0000-0000-000000000000
                    </code>
                    % else:
                    You need to provide a token for this challenge. This is your
                    team's token:
                    <br />
                    <code>
                        ${view.team.challenge_token}
                    </code>
                    % endif
            </p>
            <br />
        </div>
        % endif
        <div class="row">
        % if view.archive_mode:
            <p class="text-warning text-center">Scoreboard is in archive mode. You can submit solutions, but you will only receive feedback and are not entered into the scoreboard</p>
        % endif
        </div>
        <div class="row">
        % if (not is_solved and challenge.online and not challenge.manual and not request.settings.submission_disabled and not now() > request.settings.ctf_end_date) or view.archive_mode:
            <form method="POST" action="${request.route_url('challenge', id=challenge.id)}" class="form-horizontal">
                <legend>Enter solution for challenge</legend>
                ${form.solution.label(class_='control-label col-2')}
                <div class="col-6">
                    ${form.solution(class_='form-control', required=True, placeholder=form.solution.label.text)}
                    % for msg in getattr(form.solution, 'errors', []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                </div>
                <div class="col-2">
                    ${form.csrf_token}
                    ${form.submit(class_='form-control btn btn-default')}
                </div>
            </form>
        % elif is_solved:
            <p class="text-success text-center">Congratulations! You have already solved this challenge.</p>
        % elif now() > request.settings.ctf_end_date:
            <p class="text-danger text-center">The CTF is over. You cannot submit any more solutions.</p>
        % elif challenge.manual:
            <p class="text-warning text-center">This challenge is evaluated manually, you cannot submit a solution for it.</p>
        % elif request.settings.submission_disabled:
            <p class="text-info text-center">Submission of solution is currently disabled, sorry.</p>
        % elif not challenge.online:
            <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
        % else:
            <p class="text-danger text-center">Something is seriously wrong here! Contact FluxFingers fluxfingers@rub.de</p>
        % endif
        </div>
    % else:
        ${challenge.module.display(challenge, request) | n}
    % endif
    </div>
    <div class="clearfix"></div>
</div>

${announcements.render_announcements(challenge.announcements, False, challenge.title)}

