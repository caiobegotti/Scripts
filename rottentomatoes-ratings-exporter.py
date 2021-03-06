#!/usr/bin/env python3
# public domain

from sys import argv, exit
from lxml import etree

if not len(argv) == 2:
    exit('Usage: ' + argv[0] + ' <saved page with rottentomatoes ratings>')

parser = etree.HTMLParser(huge_tree=True)
tree = etree.parse(argv[1], parser)

movies = tree.xpath('//div[@class="media bottom_divider"]')

print('TITLE, YEAR, RATING')
for m in movies:
    ratings = m.xpath('.//div[@style="color:#F1870A"]')
    titles = m.xpath('.//a[@class="pull-left"]/@title')
    years = m.xpath('.//span[@class="subtle small"]/text()')
    zipped = zip(titles, years, ratings)
    for z in list(zipped):
        rating = len(z[2])
        title = z[0].replace('\\', '')
        year = z[1].translate({ord(i): None for i in '()'})
        print('"{}", {}, {}'.format(title, year, rating))
