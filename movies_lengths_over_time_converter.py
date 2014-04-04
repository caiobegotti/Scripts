#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

import json
from codecs import open

rows = []
with open('imdb.json', 'r', 'utf8') as f:
    loaded = json.loads(f.read())
    f.close()
    lens = {}
    for entry in loaded:
        x = loaded[entry]
        # it's a bit funny the only decent char i've found
        # to use as delimeter is also the current year
        row = u'\u2014'.join(x.values()) + '\n'
        rows.append(row)

with open('csv.imdb', 'a', 'utf8') as csv:
    csv.seek(0)
    # u'rating', u'votes', u'certificate', u'title',
    # u'boxoffice', u'director', u'cast', u'genre',
    # u'release', u'runtime', u'thumbnail'
    csv.write('\n'.join(rows))
    csv.close()
