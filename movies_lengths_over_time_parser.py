#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

# i tried to use lxml and it was ultra fast
# however bs4 proved easier for so many corner cases
# using bs4 + lxml didn't make it any faster, btw
from bs4 import BeautifulSoup as bs

# maybe change it to csv?
import simplejson as json

# utf-8 support
from codecs import open

# not optimal but does the job
from glob import glob

# see below
import re

RE_DIRECTOR = re.compile("Dir: (.*)", re.IGNORECASE)
RE_CAST = re.compile("With: (.*)", re.IGNORECASE)
RE_YEAR = re.compile("(\d{4})", re.IGNORECASE)
RE_BOXOFFICE = re.compile("\$(.*[A-Z]?)", re.IGNORECASE)
RE_RATING = re.compile("(\d.?\d)", re.IGNORECASE)
RE_RUNTIME = re.compile("(\d{1,}) mins.", re.IGNORECASE)
RE_VOTES = re.compile("([\d,]{1,})", re.IGNORECASE)

# to be used with {line,memory}_profiler
# @profile
def appfunc():
    files = glob('temp/*.html')
    moviedict = {}
    for file in files:
        with open(file, 'r') as f:
            soup = bs(f.read())
            entries = soup('td', class_='title')
            for entry in entries:
                movie = entry('a', href=True)[0]
                rowdict = {}

                # to ease future updates of movie titles in english-only
                rowdict['title'] = movie.text

                # so we can get poster images, votes, cash flow
                parent = entry.parent

                # movies posters
                for par in parent('td', class_='image'):
                    rowdict['thumbnail'] = par.a.img['src']

                # users votes and box office numbers
                sortcol = parent('td', class_='sort_col')
                if not len(sortcol) == 0:
                    for par in sortcol:
                        boxre = RE_BOXOFFICE.findall(par.text)
                        votesre = RE_VOTES.findall(par.text)
                        if boxre:
                            rowdict['boxoffice'] = boxre[0]
                        elif votesre:
                            rowdict['votes'] = votesre[0]
                        else:
                            rowdict['boxoffice'] = 'N/A'
                            rowdict['votes'] = 'N/A'
                else:
                    rowdict['boxoffice'] = 'N/A'
                    rowdict['votes'] = 'N/A'

                # credits
                credits = entry('span', class_='credit')
                if not len(credits) == 0:
                    for credit in credits:
                        director = RE_DIRECTOR.findall(credit.text)
                        actors = RE_CAST.findall(credit.text)
                        if director:
                            rowdict['director'] = director[0]
                        else:
                            rowdict['director'] = 'N/A'
                        if actors:
                            rowdict['cast'] = actors[0]
                        else:
                            rowdict['cast'] = 'N/A'
                else:
                    rowdict['director'] = 'N/A'
                    rowdict['cast'] = 'N/A'

                # running time, in minutes
                runtime = entry('span', class_='runtime')
                if not len(runtime) == 0:
                    runtime_re = RE_RUNTIME.findall(runtime[0].text)
                    if runtime_re:
                        rowdict['runtime'] = runtime_re[0]
                    else:
                        rowdict['runtime'] = 'N/A'
                else:
                    rowdict['runtime'] = 'N/A'

                # year date
                release = entry('span', class_='year_type')
                if not len(release) == 0:
                    year = RE_YEAR.findall(release[0].text)
                    if year:
                        rowdict['release'] = year[0]
                    else:
                        rowdict['release'] = 'N/A'
                else:
                    rowdict['release'] = 'N/A'

                # main (first) genre only
                genres = entry('span', class_='genre')
                if not len(genres) == 0:
                    for genre in genres:
                        rowdict['genre'] = genre.a.text
                else:
                    rowdict['genre'] = 'N/A'

                # certificate
                certs = entry('span', class_='certificate')
                if not len(certs) == 0:
                    for cert in certs:
                        if cert.span:
                            rowdict['certificate'] = cert.span['title']
                        else:
                            rowdict['certificate'] = 'N/A'
                else:
                    rowdict['certificate'] = 'N/A'

                # rating
                rates = entry('span', class_='value')
                if not len(rates) == 0:
                    for rate in rates:
                        rerate = RE_RATING.findall(rate.text)
                        if rerate:
                            rowdict['rating'] = rerate[0]
                        else:
                            rowdict['rating'] = 'N/A'
                else:
                    rowdict['rating'] = 'N/A'

                # for more information, will also be the key
                link = 'http://www.imdb.com' + movie['href']

                # avoids duplicated, overwritten entries
                if link in moviedict:
                    moviedict[link].update(rowdict)
                else:
                    moviedict[link] = rowdict

            # some debugging
            # print moviedict
        print len(moviedict)
        f.close()

    with open('imdb.json', 'a', 'utf8') as f:
        f.seek(0)
        dump = json.dumps(moviedict, indent=4, sort_keys=True)
        f.write(dump)
        f.close()

if __name__ == '__main__':
    appfunc()
