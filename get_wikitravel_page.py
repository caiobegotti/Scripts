#!/usr/bin/env python
#
# this file is under public domain
# python + lxml + xpath scriptlet to fetch wikitravel's pages
# caio begotti <caio1982@gmail.com>

from sys import argv
from sys import exit

from lxml.html import tostring
from lxml import etree

if not len(argv) == 2:
    exit('Usage: ' + argv[0] + " 'wikitravel's page name'")

term = argv[1].replace(' ','_').lower()
parser = etree.HTMLParser()

tree = etree.parse('http://wikitravel.org/en/' + term, parser)
elements = tree.xpath('//div[@id="bodyContent"]/table/tr/td[1]')

html = []
for e in elements:
    s = tostring(e, method='html', pretty_print=True)
    s = s.replace('\n', '')
    s = s.replace('\t', '')
    html.append(s)

print '<html>'
print '<head><title>Wikitravel: %s</title></head>' % term.title()
print '<body style="font-family: sans-serif; width: 75%; margin-left: auto; margin-right: auto;">'
print ' '.join(html)
print '</body>'
print '</html>'
