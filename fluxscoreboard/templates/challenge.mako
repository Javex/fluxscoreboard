<%inherit file="base.mako"/>
<%namespace name="announcements" file="announcements.mako"/>
<%
from fluxscoreboard.util import now, nl2br, display_design
import uuid
%>
% if display_design(request):


    <div class="paper paper-curl">
        <h2>${challenge.title}</h2>
        % if challenge.category or challenge.author:
            <h3>
                % if challenge.author:
                    by ${challenge.author}
                % endif
                % if challenge.category:
                    (${challenge.category})
                % endif
            </h3>
        % endif
        % if not challenge.dynamic:
            <small class="points">${challenge.base_points} (+${challenge.points - challenge.base_points}) Points</small>
            <p>${challenge.text | n}</p>
            % if request.settings.archive_mode:
                <p class="text-warning">Scoreboard is in archive mode. You can submit solutions and will receive feedback, but won't be able to compete in the scoreboard.</p>
            % endif

            % if (not is_solved and challenge.online and not challenge.manual and not request.settings.submission_disabled and not now() > request.settings.ctf_end_date) or request.settings.archive_mode:
                <form method="POST" action="${request.route_url('challenge', id=challenge.id)}">
                    ${form.solution(required=True, placeholder='Enter flag here...')}
                    % for msg in getattr(form.solution, 'errors', []):
                        <div class="alert alert-danger">${msg}</div>
                    % endfor
                    ${form.csrf_token}
                    ${form.submit()}
                </form>
            % elif is_solved:
                <p class="text-success text-center">Congratulations! You have already solved this challenge.</p>
            % elif now() > request.settings.ctf_end_date:
                <p class="text-danger text-center">The CTF is over. You cannot submit any more solutions.</p>
            % elif challenge.manual:
                <p class="text-warning text-center">This challenge is evaluated manually, you cannot submit a solution for it.</p>
            % elif request.settings.submission_disabled:
                <p class="text-info text-center">Submission of solutions is currently disabled, sorry.</p>
            % elif not challenge.online:
                <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
            % else:
                <p class="text-danger text-center">Something is seriously wrong here! Contact FluxFingers fluxfingers@rub.de</p>
            % endif
        % else:
            ## is a dynamic challenge
            ${challenge.module.render(challenge, request) | n}
        % endif
        % if feedback:
        <div class="row">
            <form method="POST" class="form-horizontal">
                <legend><small>Please provide feedback for this challenge</small></legend>
                <div class="row">
                    <div class="col-2">${feedback.rating.label(class_='control-label')}</div>
                    <div class="col-10">
                    % for item in feedback.rating:
                        ${item.label()} ${item()}
                    % endfor
                    </div>
                </div>
                <div class="row">
                    <div class="col-2">${feedback.note.label(class_='control-label')}</div>
                    <div class="col-10">${feedback.note(class_='form-control', rows=5)}</div>
                </div>
                <div class="row">
                    <div class="col-2"></div>
                    <div class="col-10">
                        ${feedback.csrf_token}
                        ${feedback.submit_feedback(class_='btn btn-default form-contro')}
                    </div>
                </div>
            </form>
        </div>
        % endif
    </div>


% else:


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
                        % if request.settings.archive_mode:
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
                            ${request.team.challenge_token}
                        </code>
                        % endif
                </p>
                <br />
            </div>
            % endif
            <div class="row">
            % if request.settings.archive_mode:
                <p class="text-warning text-center">Scoreboard is in archive mode. You can submit solutions, but you will only receive feedback and are not entered into the scoreboard</p>
            % endif
            </div>
            <div class="row">
            % if (not is_solved and challenge.online and not challenge.manual and not request.settings.submission_disabled and not now() > request.settings.ctf_end_date) or request.settings.archive_mode:
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
                <p class="text-info text-center">Submission of solutions is currently disabled, sorry.</p>
            % elif not challenge.online:
                <p class="text-warning text-center">This challenge is currently offline, check back later.</p>
            % else:
                <p class="text-danger text-center">Something is seriously wrong here! Contact FluxFingers fluxfingers@rub.de</p>
            % endif
            </div>
        % else:
            ${challenge.module.render(challenge, request) | n}
        % endif
        </div>
        <div class="clearfix"></div>
    </div>

% endif


${announcements.render_announcements(challenge.announcements, False, challenge.title)}


