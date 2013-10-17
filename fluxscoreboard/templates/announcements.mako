<%inherit file="base.mako"/>
<h1>Welcome to the hack.lu 2013 CTF!</h1>
${render_announcements(announcements)}

<%def name="render_announcements(announcements, display_item_title=True, challenge_title=None)">
<% from fluxscoreboard.util import tz_str %>
<div class="panel panel-info">
    <div class="panel-heading">
        <h3 class="panel-title">
            Announcements
            % if challenge_title:
                for ${challenge_title}
            % endif
        </h3>
    </div>
% if announcements:
    % for news in announcements:
        <div class="list-group">
            <h4>
            % if display_item_title:
                % if news.challenge:
                    <a href="${request.route_url('challenge', id=news.challenge_id)}">"${news.challenge.title}"</a>
                % else:
                    General Announcement
                % endif
            % endif
                <small>(Published on ${tz_str(news.timestamp, view.team.timezone)})</small>
            </h4>
        <p>${news.message}</p>
        </div>
    % endfor
% else:
    <p>No announcements have been published yet!</p>
% endif

</div>
</%def>
