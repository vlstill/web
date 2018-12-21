TEMPLATE=src/template.html
RESULT_FILES=style.css index.html .htaccess

all : ${RESULT_FILES:%=build/%}

build/%.html : src/%.md $(TEMPLATE) build
	pandoc $< -s --template=$(TEMPLATE) -t html5 -o $@

build/%.css : src/%.css build
	cp $< $@

build/.htaccess : src/.htaccess build
	cp $< $@

build :
	mkdir -p build
	touch $@

deploy : all
	cd build && find -type f -exec curl -n --ftp-create-dirs --ssl-reqd -T {} ftp://210149.w49.wedos.net/{} \;

.PHONY : build all
