<%inherit file="base.mako"/>
<h1>Welcome to the hack.lu 2013 CTF!</h1>

% for news in announcements:
<div>
    ${news.message}
</div>
% endfor
