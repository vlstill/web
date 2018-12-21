TEMPLATE=src/template.html
RESULT_FILES=style.css index.html .htaccess

all : build

build : ${RESULT_FILES:%=_build/%}

_build/%.html : src/%.md $(TEMPLATE) _build
	pandoc $< -s --template=$(TEMPLATE) -t html5 -o $@

_build/%.css : src/%.css _build
	cp $< $@

_build/.htaccess : src/.htaccess _build
	cp $< $@

_build :
	mkdir -p _build
	touch $@

deploy : build
	cd _build && find -type f -exec curl -n --ftp-create-dirs --ssl-reqd -T {} ftp://210149.w49.wedos.net/{} \;

.PHONY : build deploy all
