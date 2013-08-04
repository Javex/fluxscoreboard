<%inherit file="base.mako"/>
<h1>Welcome to the hack.lu 2013 CTF!</h1>
${render_announcements(announcements)}


<%def name="render_announcements(announcements)">
% for news in announcements:
<div class="panel panel-info">
    <div class="panel-heading">
        <h3 class="panel-title">
        % if news.challenge:
            <a href="${request.route_url('challenge', id=news.challenge_id)}">Announcement for "${news.challenge.title}"</a>
        % else:
            General Announcement
        % endif
            <small>(Published on ${news.timestamp.strftime('%Y-%m-%d %H:%M:%S')})</small>
        </h3>
    </div>
    ${news.message}
</div>
% endfor
</%def>
