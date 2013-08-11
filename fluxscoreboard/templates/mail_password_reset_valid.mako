<p>
    You have requested to reset your password. Please click on this link to start the reset process:
    <a href="${request.route_url('reset-password', token=team.reset_token)}">${request.route_url('reset-password', token=team.reset_token)}</a>
</p>
<p>If you did not request a reset, please ignore this mail.</p>
