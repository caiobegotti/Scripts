#!/usr/bin/env python
#
# this file is under public domain
# python version of my getlat.sh scriptlet <caio1982@gmail.com>
# get latin definitions from wiktionary on your shell

from sys import argv
from sys import exit

from lxml.html import tostring
from lxml import etree

from os import popen
import tempfile
import re

if not len(argv) == 2:
    exit('Usage: ' + argv[0] + " 'your term'")

term = argv[1].replace(' ','_').lower()
parser = etree.HTMLParser()

try:
    tree = etree.parse('http://en.wiktionary.org/wiki/' + term, parser)
    elements = tree.xpath('/html/body/div[3]/div[3]/div[4]')
    html = tostring(elements[0], encoding='utf-8', method='html', pretty_print=True).replace('[edit] ','')
    try:
        # now, this is quite embarassing... i understand how ugly it is to use popen to lynx here
        # the problem is that most scrapping solutions such as scrapy, beautifulsoup and lxml
        # actually do a good job with serialized content and line-by-line scrapping and such
        # but they can't simply render a given block of a page's indented code... lynx does
        # i could also have manually handled this, but if they won't keep indentation and
        # white spaces i guess there's no point in doing it myself

        f = tempfile.NamedTemporaryFile()
        f.write(html)
        f.seek(0)
        
        regex = re.compile('id="Latin">')
        parsed = regex.split(f.read())[1]
        regex = re.compile('<hr>')
        cleaned = regex.split(parsed)[0]
       
        file = tempfile.NamedTemporaryFile()
        filename = file.name 
        file.write(cleaned)
        file.seek(0)
        
        of = popen('cat %s | lynx -assume-charset=UTF-8 -dump -nolist -width=200 -stdin' % filename)
        buffer = of.read().replace(' ">edit] ','').replace('[edit] ','')
        of.close()
        
        print buffer
    except:
        exit('Could not render the page from wiktionary')
except:
    exit('Term not found or wiktionary unavailable now')
