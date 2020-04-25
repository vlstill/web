#!/usr/bin/env python3

import sys
import os
import os.path
import bibtexparser
import bibtexparser.bparser

assert len(sys.argv) >= 3, "has to have at least export directory and one bib file"

out = sys.argv[1]
ins = sys.argv[2:]

def split(bib):
    for e in bib.entries:
        db = bibtexparser.bibdatabase.BibDatabase()
        db.entries = [e]
        path = os.path.join(out, e['ID']) + ".bib"
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w') as h:
            bibtexparser.dump(db, h)
    

parser = bibtexparser.bparser.BibTexParser(interpolate_strings=False, ignore_nonstandard_types=False)
for f in ins:
    with open(f, 'r') as h:
        bib = bibtexparser.load(h, parser=parser)
        split(bib)
