<%inherit file="base.mako"/>
<%namespace name="form_funcs" file="_form_functions.mako"/>
${form_funcs.render_form(request.route_url('profile'), form, 'Edit Your Team', True)}
