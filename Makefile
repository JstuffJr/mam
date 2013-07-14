HTML = doc/out/index.html
JS_GLUE = build/mam-glue.js
JS_LIB = build/mam-pre5p1-min.js

GOOGLE_FONTS = http://fonts.googleapis.com/css?family=

all: doc glue library

clean:
	rm -f $(HTML) $(JS_GLUE) $(JS_LIB) build/mam.js

doc: $(HTML)

glue: $(JS_GLUE)

library: $(JS_LIB)


$(HTML): doc/README.md doc/out/css/pandoc.css
	pandoc -s -t html5 -S \
		-c "$(GOOGLE_FONTS)IM+Fell+English" \
		-c "$(GOOGLE_FONTS)Vollkorn" \
		-c "css/pandoc.css" -c "css/doc.css" \
		-o $(HTML) doc/README.md

$(JS_GLUE): src/mam-glue.js
	uglifyjs src/mam-glue.js -m \
		-b beautify=false,space_colon=false,bracketize=true \
		-o $(JS_GLUE)

$(JS_LIB): build/mam.js
	uglifyjs build/mam.js -m -c -o $(JS_LIB)

build/mam.js: src/mam.coffee
	coffee -c -o build/ src/mam.coffee

.PHONY: all clean doc glue library
