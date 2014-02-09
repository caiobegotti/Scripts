#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# bad astronomy's author phil plait constantly comes up with
# new different verbs when describing pictures or incredible photographs
# on posts, such as "click to coriolisenate" etc — this script serves
# to document them all and gather basic stats about such weird verbs
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

import os
import re

from codecs import open as open

from lxml import etree
from lxml import html

from urllib import urlretrieve
from urlparse import urlsplit

from glob import glob

# documented posts and pages
TOTAL_POSTS = 7123
PAGES = range(1, 714)

def parse_tree(url):
    parser = etree.HTMLParser()
    try:
        return etree.parse(url, parser)
    except:
        raise Exception('Etree creation failed!')

def fetch_all_pages():
    for page_number in PAGES:
        page_url = 'http://blogs.discovermagazine.com/badastronomy/page/%s' % page_number
        print 'Working page %s' % page_url
        for url in get_urls(page_url):
            get_url_data(url)

def all_pages():
    return glob('*_badastronomy_*.html')

def get_urls(page):
    blog_links = []
    tree = parse_tree(page)
    return tree.xpath('//h2/a/@href')

def get_url_data(url):
    filename = urlsplit(url).path
    filename = '%s.html' % filename.replace('/', '_')
    if not os.path.isfile(filename):
        try:
            print 'Saving %s' % url
            urlretrieve(url, filename)
        except:
            raise Exception('Could not retrieve data')
        return filename
    else:
        print 'Skipping %s' % filename

def contains(lines, term):
    return [x for x in lines if term in x]

def extract_verbs(htmlfile):
    with open(htmlfile, 'r') as data:
        tree = html.fromstring(data.read())
        try:
            match = tree.xpath('//p/text()')
            return contains(match, 'Click to')
        except UnicodeDecodeError:
            pass

def save_verbs():
    if len(all_pages()) == TOTAL_POSTS:
        print 'Hold on, this will take a while...'
        results = []
        for file in all_pages():
            hit = extract_verbs(file)
            if hit is not None:
                results.extend(hit)
            print results
        with open('phil_plait_verbs.txt', 'a', 'utf8') as saved:
            saved.seek(0)
            saved.write('\n'.join(results))
            saved.close()
            print 'Done!'
    else:
        ret = raw_input('Confirm if you want to recheck all downloaded data first, or abort now!')
        if ret is '':
            fetch_all_pages()

def parse_verbs():
    with open('phil_plait_verbs.txt', 'r', 'utf8') as saved:
        lines = saved.readlines()
        saved.close()
        regex = re.compile("[Cc]lick to (\w+( \w+)?)")
        verbs = []
        for line in lines:
            got = regex.findall(line)
            verbs.extend(got)
        return list(set([x[0].lower() for x in verbs]))

# fetch_all_pages()
# save_verbs()
for verb in parse_verbs():
    print 'to', verb
