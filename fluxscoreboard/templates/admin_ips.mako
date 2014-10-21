<%inherit file="base.mako"/>
<h1>Find a team by IP address or find an IP by team name!</h1>
<form action="${request.route_url('admin_ip_search')}" method="POST">
    ${form.term}
    ${form.csrf_token}
    ${form.by_ip}
    ${form.by_name}
</form>

% if results:
    % if request.method == 'POST':
        <em>
            Search result for ${form.term.data} by
            % if form.by_ip.data:
                IP
            % elif form.by_name.data:
                team name
            % endif
        </em>
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
        <em>
            No result found for search term ${form.term.data} by
            % if form.by_ip.data:
                IP
            % elif form.by_name.data:
                team name
            % endif
        </em>
    % else:
        <em>No IPs yet</em>
    % endif
% endif
