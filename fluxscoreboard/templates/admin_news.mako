<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<%namespace name="form_funcs" file="_form_functions.mako"/>
<h1>Announcements</h1>
% if items:
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Time (UTC)</td>
                <th>Message</td>
                <th>Challenge</td>
                <th>Published</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
    % for news in items:
            <tr class="${'success' if form.id.data == news.id else ''}">
                <td>${news.id}</td>
                <td>${news.timestamp.strftime("%Y-%m-%d %H:%M:%S")}</td>
                <td title="${news.message}">${news.message if len(news.message) <= 50 else news.message[:50] + "..."}</td>
                <td>
                % if news.challenge:
                    <a href="${request.route_url('admin_challenges', id=news.challenge.id)}">${news.challenge.title}</a>
                % else:
                    <em>None</em>
                % endif
                </td>
                <td class="text-${'success' if news.published else 'danger'}">
                    ${'Yes' if news.published else 'No'}
                </td>
                <td class="btn-group">
                    ${admin_funcs.display_action_list(page.page, request, news.id,
                                                      [('admin_news_edit', "Edit"), 
                                                       ('admin_news_delete', "Delete"), 
                                                       ('admin_news_toggle_status', ("Unpublish" if news.published else "Publish") + " Announcement")])}
                </td>
            </tr>
    % endfor
        </tbody>
    </table>
    
    ${admin_funcs.display_pagination(page, 'admin_news')}
% else:
    <div class="text-center text-info lead">
        <em>No announcements yet!</em>
    </div>
% endif

${admin_funcs.display_admin_form('admin_news', form, "Announcement", is_new, page.page)}
