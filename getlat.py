#!/usr/bin/env python
#
# this file is under public domain
# python version of my getlat.sh scriptlet <caio1982@gmail.com>
# get latin definitions from wiktionary on your shell

from sys import argv
from sys import exit

from lxml.html import tostring
from lxml import etree

if not len(argv) == 2:
    exit('Usage: ' + argv[0] + " 'your term'")

term = argv[1].replace(' ','_').lower()
parser = etree.HTMLParser()

try:
    tree = etree.parse('http://en.wiktionary.org/wiki/' + term, parser)
    elements = tree.xpath('/html/body/div[3]/div[3]/div[4]')
except:
    exit('Term not found or wiktionary unavailable now')
    
for div in elements:
    res = tostring(div, encoding='utf-8', method='text', pretty_print=True)
    print res.replace('[edit] ','').replace('\n\n','\n')
