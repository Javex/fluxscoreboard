<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<h1>Send Mass Mails</h1>

% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Subject</th>
                <th>Timestamp (UTC)</th>
                <th>#Recipients</th>
                <th>From</th>
            </tr>
        </thead>
        <tbody>
    % for mail in items:
            <tr>
                <td>${mail.id}</td>
                <td>
                    <a href="${request.route_url('admin_massmail_single', id=mail.id)}">${mail.subject}</a>
                </td>
                <td>${mail.timestamp.strftime('%Y-%m-%d %H:%M:%S')}</td>
                <td>${len(mail.recipients)}</td>
                <td>${mail.from_}</td>
            </tr>
    % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_massmail')}
% else:
    <div class="text-center text-info lead">
        <em>No massmails yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_massmail', form, "Mass Mail", True, page.page)}
