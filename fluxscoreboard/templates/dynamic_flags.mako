% if challenge.text:
    <p>${challenge.text}</p>
% endif
<p>
    This challenge is a special challenge. You can collect some minor extra 
    points here by visiting that you are truly international player. Each time
    you visit your reference URL from a different country, that flag will be
    activated and you gain an additional point. There is nothing more to it,
    just something to keep you busy when you are stuck everywhere else. Oh and
    for the record: You already have ${"%d/%d" % flag_stats} points.
</p>
<p>To collect points for that challenge, use this URL: <a href="${request.route_url('ref', ref_id=team.ref_token)}">${request.route_url('ref', ref_id=team.ref_token)}</a></p>
<p class="text-danger">
    <b>Disclaimer:</b> Please do <em>not</em> attempt to hack real-world systems for
    a single point. That is illegal and we assure you it is not worth a single
    point! Also, there is a way to still collect all flags. However, we believe
    that this is also not worth a single point.
</p>
<div class="flag-container">
% for flag_row in flags:
    <div class="row">
    % for flag, visited in flag_row:
        <div style="float:left;margin:3px" class="flag ${flag} ${'inactive' if not visited else ''}" title="${flag}"></div>
    % endfor
    </div>
% endfor
</div>
