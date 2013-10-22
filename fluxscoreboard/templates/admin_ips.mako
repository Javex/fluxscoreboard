<%inherit file="base.mako"/>
<h1>Find a team by IP address!</h1>
<form action="${request.route_url('admin_ip_search')}" method="POST">
    ${form.term}
    ${form.csrf_token}
    ${form.submit}
</form>

% if results:
    The following teams were found:
    <ul>
    % for team in results:
        <li>${team.name}</li>
    % endfor
    </ul>
% else:
    % if request.method == 'POST':
        <em>No result found for search term ${form.term.data}</em>
    % endif
% endif

