#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>
#
# total: 285334
# no movies this year: //div[@class='content_none']//text()
# listing: http://www.imdb.com/search/title?at=0&sort=moviemeter,asc&start=1&title_type=feature&year=1900,2015
# pagination: //span[@class="pagination"]/a/@href (51, 101, 151...)
# runtime: //span[@class='runtime']//text()
# year: //span[@class="year_type"]/text()
# title: //td[@class="title"]/a/text()
# link: //td[@class="title"]/a/@href
# rating: 
# director: 
# cast: 
# categories: 
# stars: 
# votes: 
# boxoffice: 

import re

from codecs import open
from lxml import etree
from lxml import html
from glob import glob

files = glob('*.html')

data = []
for file in files:
    with open(file, 'r') as f:
        parser = etree.HTMLParser()
        tree = html.fromstring(f.read())
        titles = tree.xpath('//td[@class="title"]/a/text()')
        years = tree.xpath('//span[@class="year_type"]/text()')
        runtimes = tree.xpath('//span[@class="runtime"]//text()')
        hrefs = tree.xpath('//td[@class="title"]/a/@href')
        row = zip(titles, years, runtimes, hrefs)
        data.extend(row)
    f.close()

with open('imdb.txt', 'a', 'utf8') as f:
    f.seek(0)
    f.write('Title\tYear\tRuntime\tLink\n')
    year_regex = re.compile('.([12][0-9]{3}).')
    for entry in data:
        title = entry[0]
        year = ''.join(year_regex.findall(entry[1]))
        runtime = entry[2].replace(' mins.', '')
        href = 'http://www.imdb.com' + entry[3]
        csvline = '%s\t%s\t%s\t%s\n' % (title, year, runtime, href)
        f.write(csvline)
    f.close()
