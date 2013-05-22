HTML = doc/out/index.html
PRODJS = mam-pre1-min.js

all: library doc

doc: $(HTML)

library: $(PRODJS)

$(HTML): doc/README.md doc/out/pandoc.css
	pandoc -s -t html5 -S -c pandoc.css --toc -o $(HTML) doc/README.md

$(PRODJS): mam.js
	uglifyjs mam.js -m -c -o $(PRODJS)

mam.js: mam.coffee
	coffee -c mam.coffee

.PHONY: all library doc
