.PHONY: build open clean

build:
	quarto render index.qmd
	@# Quarto strips the doctype declaration from custom templates; restore it.
	@grep -q '^<!DOCTYPE' index.html || (printf '<!doctype html>\n' | cat - index.html > index.html.tmp && mv index.html.tmp index.html)

open: build
	open index.html

clean:
	rm -f index.html
