TEMPLATE=src/template.html
RESULT_FILES=style.css index.html

all : ${RESULT_FILES:%=build/%}

build/%.html : src/%.md $(TEMPLATE) build
	pandoc $< -s --template=$(TEMPLATE) -t html5 -o $@

build/%.css : src/%.css build
	cp $< $@

deploy/% : build/% deploy/.htaccess
	cp $< $@

deploy/.htaccess :
	mkdir -p deploy
	test -f $@ || curlftpfs 210149.w49.wedos.net deploy

build :
	mkdir -p build
	touch $@

deploy : ${RESULT_FILES:%=deploy/%}

.PHONY : deploy build.dir all
