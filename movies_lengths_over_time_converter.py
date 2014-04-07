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
    for entry in loaded:
        x = loaded[entry]
        row = '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s' % (entry,
                                                       x['release'],
                                                       x['title'],
                                                       x['runtime'],
                                                       x['boxoffice'],
                                                       x['votes'],
                                                       x['rating'],
                                                       x['certificate'],
                                                       x['genre'],
                                                       x['director'],
                                                       x['cast'],
                                                       x['thumbnail'])
        rows.append(row)

with open('imdb.csv', 'a', 'utf8') as csv:
    csv.seek(0)
    csv.write('\n'.join(rows))
    csv.close()
