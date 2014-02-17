#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

from bs4 import BeautifulSoup as bs

import simplejson as json

from codecs import open
from glob import glob

files = glob('*.html')
moviedict = {}
for file in files:
    with open(file, 'r') as f:
        soup = bs(f.read())
        entries = soup('td', class_='title')
        for entry in entries:
            movie = entry('a', href=True)[0]
            rowdict = moviedict[movie.text] = {}

            # for more information
            rowdict['link'] = 'http://www.imdb.com' + movie['href']

            # so we can get poster images, votes, cash flow
            parent = entry.parent

            # movies posters
            for par in parent('td', class_='image'):
                rowdict['thumbnail'] = par.a.img['src']

            # users votes and box office numbers
            for par in parent('td', class_='sort_col'):
                if '$' in par.text:
                    rowdict['boxoffice'] = par.text
                else:
                    rowdict['votes'] = par.text

            # running time, in minutes
            runtime = entry('span', class_='runtime')
            if len(runtime) == 0:
                rowdict['runtime'] = 'N/A'
            else:
                rowdict['runtime'] = runtime[0].text.replace(' mins.', '')

            # year date
            release = entry('span', class_='year_type')
            if len(release) == 0:
                rowdict['release'] = 'N/A'
            else:
                ret = release[0].text.replace(')', '')
                ret = ret.replace('(', '')
                rowdict['release'] = ret

            # main (first) genre only
            genres = entry('span', class_='genre')
            if len(genres) == 0:
                rowdict['genre'] = 'N/A'
            else:
                for genre in genres:
                    rowdict['genre'] = genre.a.text

            # certificate
            certs = entry('span', class_='certificate')
            for cert in certs:
                if cert.span:
                    rowdict['certificate'] = cert.span['title']
                else:
                    rowdict['certificate'] = 'N/A'

            # rating
            rates = entry('span', class_='value')
            for rate in rates:
                if '-' in rate.text:
                    rowdict['rating'] = 'N/A'
                else:
                    rowdict['rating'] = rate.text

        # some debugging
        print moviedict
    f.close()

with open('imdb.json', 'a', 'utf8') as f:
    f.seek(0)
    dump = json.dumps(moviedict, indent=4, sort_keys=True)
    f.write(dump)
    f.close()
