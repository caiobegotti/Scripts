#!/usr/bin/env python
#
# this file is under public domain <caio1982@gmail.com>
# python version of my howto_pronounce_in_english_using_ipa.sh
# give it a try by using 'otorhinolaryngologist'

from sys import argv
from sys import exit

from lxml.html import tostring
from lxml import etree

if not len(argv) == 2:
    exit('Usage: ' + argv[0] + " 'your term'")

term = argv[1].lower()
parser = etree.HTMLParser()

try:
    tree = etree.parse('http://phonodict.net/' + term, parser)
    elements = tree.xpath('/html/body/nav/div/span[@id="ipa"]')
except:
    exit('Term not found or Phonodict is unavailable now')

for div in elements:
    res = tostring(div, encoding='utf-8', method='text', pretty_print=True)
    print res
