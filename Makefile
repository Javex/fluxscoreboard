
coverage:
	@coverage run --source fluxscoreboard -m py.test tests/
	
cov-html: coverage
	@coverage html
	
test:
	@py.test tests/