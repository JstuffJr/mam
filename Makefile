HTML = doc/out/index.html
PRODJS = doc/out/js/mam-pre2-min.js

all: library doc

clean:
	rm -f $(HTML) $(PRODJS) mam.js

doc: $(HTML)

library: $(PRODJS)

$(HTML): doc/README.md doc/out/css/pandoc.css
	pandoc -s -t html5 -S -c "css/pandoc.css" --toc -o $(HTML) doc/README.md

$(PRODJS): mam.js
	uglifyjs mam.js -m -c -o $(PRODJS)

mam.js: mam.coffee
	coffee -c mam.coffee

.PHONY: all library doc clean
