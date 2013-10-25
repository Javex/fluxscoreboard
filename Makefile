
coverage:
	@coverage run --source fluxscoreboard,tests/template/cache -m py.test tests/
	
cov-html: coverage
	@coverage html
	
test:
	@py.test tests/
