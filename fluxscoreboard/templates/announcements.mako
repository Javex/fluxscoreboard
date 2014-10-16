<%
from fluxscoreboard.util import now, display_design
%>
<%inherit file="base.mako"/>


${render_announcements(announcements)}


<%def name="render_announcements(announcements, display_item_title=True, challenge_title=None)">
    <%
        from fluxscoreboard.util import tz_str
    %>
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
                        <small>(Published on ${tz_str(news.timestamp, request.team.timezone if request.team else None)})</small>
                    </h4>
                <p>${news.message | n}</p>
                </div>
            % endfor
        % else:
            <p>No announcements have been published yet!</p>
        % endif
    </div>
</%def>