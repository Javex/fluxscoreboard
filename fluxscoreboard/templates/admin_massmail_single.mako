<%inherit file="base.mako"/>
<%namespace name="admin_funcs" file="_admin_functions.mako"/>
<% from fluxscoreboard.util import nl2br %>
<h1>Mass Mail "${mail.subject}"</h1>

<div class="col-2"></div>
<div class="col-8">
    <div class="row">
        <div class="col-4">ID</div>
        <div class="col-8">${mail.id}</div>
    </div>
    <div class="row">
        <div class="col-4">Subject</div>
        <div class="col-8">${mail.subject}</div>
    </div>
    <div class="row">
        <div class="col-4">Message</div>
        <div class="col-8">${mail.message | n,nl2br}</div>
    </div>
    <div class="row">
        <div class="col-4">Timestamp</div>
        <div class="col-8">${mail.timestamp.strftime('%Y-%m-%d %H:%M:%S')}</div>
    </div>
    <div class="row">
        <div class="col-4">From</div>
        <div class="col-8">${mail.from_}</div>
    </div>
    <div class="row">
        <div class="col-4">Recipients</div>
        <div class="col-8">${", ".join(mail.recipients)}</div>
    </div>
    <div class="row">
        <div class="col-4"></div>
        <div class="col-8">
            <a class="btn btn-default" href="${request.route_url('admin_massmail')}">Back</a>
        </div>
    </div>
</div>
<div class="col-2"></div>
