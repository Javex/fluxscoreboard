<%inherit file="base.mako"/>
<h1>Find a team by IP address!</h1>
<form action="${request.route_url('admin_ip_search')}" method="POST">
    ${form.term}
    ${form.csrf_token}
    ${form.submit}
</form>

% if results:
    % if request.method == 'POST':
        <em>Search result for ${form.term.data}</em>
    % else:
        <em>All IPs that are currently registered</em>
    % endif
    <table class="table sortable">
        <tr>
            <th>Team ID</th>
            <th>Team Name</th>
            <th>IP Address</th>
        </tr>
        % for team in results:
            % for ip in team.ips:
                <tr>
                    <td>${team.id}</td>
                    <td>${team.name}</td>
                    <td>${ip}</td>
                </tr>
            % endfor
        % endfor
    </table>
% else:
    % if request.method == 'POST':
        <em>No result found for search term ${form.term.data}</em>
    % else:
        <em>No IPs yet</em>
    % endif
% endif
