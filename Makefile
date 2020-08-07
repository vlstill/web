TEMPLATE=src/template.html
IMGS=$(wildcard img/*.svg)
RESULT_FILES=style.css .htaccess $(IMGS) \
	index.html publications.html \
	phd/index.html publications/2020/hsExprTest/index.html
YEAR != date '+%Y'
YEARS != if [ "2018" = "$(YEAR)" ]; then echo $(YEAR); else echo "2018–$(YEAR)"; fi
PANDOC = pandoc -V year=$(YEAR) -V years=$(YEARS) -s --template=$(TEMPLATE) -t html5

PUB_PDF != find pub/pdf -type f -name '*.pdf'
PUB_PDF_REF != find pub/pdf -type l -name '*.pdf'
PUB_BIB != find pub/bib -name '*.bib'
PUB_PROCESS = pub/process.py
PUB_SPLIT = pub/bibsplit.py
PUB_TEMPLATE = src/pub-template.html
TMPDIR ?= _tmp

all : build

build : ${RESULT_FILES:%=_build/%}

_build/%.html : src/%.md $(TEMPLATE)
	mkdir -p $(dir $@)
	$(PANDOC) -V level=$(shell echo $(dir $(<:src/%.md=%)) | sed -e 's,/$$,,' -e 's/[^/.]\+/../g') $< -o $@

_build/%.css : src/%.css
	cp $< $@

_build/%.svg : src/%.svg
	cp $< $@

_build/.htaccess : src/.htaccess
	cp $< $@

_build/publications/%.pdf : pub/pdf/%.pdf
	mkdir -p $(dir $@)
	cp $< $@

_build/publications.html : ${TMPDIR}/publications.yml $(TEMPLATE) \
						   ${PUB_SPLIT} ${PUB_TEMPLATE}
	mkdir -p _build
	pandoc $< --metadata title=Publications --template ${PUB_TEMPLATE} -t html5 -f markdown+smart \
		| $(PANDOC) -V level=. --metadata title=Publications -f html -o $@
	mkdir -p _build/publications/bib
	${PUB_SPLIT} _build/publications/bib ${PUB_BIB}

${TMPDIR}/publications.yml : $(PUB_BIB) $(PUB_PROCESS) \
							${PUB_PDF:pub/pdf/%=_build/publications/%} ${PUB_PDF_REF}
	mkdir -p ${TMPDIR}
	pandoc-citeproc --bib2yaml ${PUB_BIB} | ${PUB_PROCESS} pub/pdf > $@

deploy : build
	cd _build && find -type f -print -exec curl -n --ftp-create-dirs --ssl-reqd -T {} ftp://210149.w49.wedos.net/{} \;

install-prereq :
	pip3 install --user bibtexparser

.PHONY : build deploy all install-prereq
