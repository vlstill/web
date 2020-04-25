#!/usr/bin/env python3

import yaml
import sys
import re
import sys
import os.path

pdfdir = None
if len(sys.argv) >= 2:
    pdfdir = sys.argv[1]

def get_pdf(ref):
    if pdfdir is None:
        return False
    pdf = os.path.join(pdfdir, ref['id']) + ".pdf"
    if os.path.islink(pdf):
        return os.readlink(pdf)
    if os.path.isfile(pdf):
        return pdf[len(pdfdir) + 1:]


SPAN = re.compile(r'^<span[^>]*>')

orig = yaml.load(sys.stdin)['references']
by_year_dict = {}
for e in orig:
    year = e['issued'][0]['year']
    if year not in by_year_dict:
        by_year_dict[year] = []
    pdf = get_pdf(e)
    if pdf is not None:
        e['pdf'] = pdf
    by_year_dict[year].append(e)

by_year = []
for k, v in reversed(sorted(by_year_dict.items(), key = lambda e: e[0])):
    by_year.append({'year': k, 'data': sorted(v, key = lambda e: SPAN.sub("", e['title']))})

print('---')
print(yaml.dump({'references': by_year}))
print('---')
