#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain <caio1982@gmail.com>

import re

# should match all distances in kilometers
regex = re.compile("[0-9]+[,.]?[0-9]+?[ ]+?km", re.IGNORECASE)

from lxml import etree

parser = etree.HTMLParser()

tree = etree.parse('http://www.trainerassessoria.com.br/calendario-de-eventos/2012/11', parser)

races = []
for r in tree.xpath('//dd[@class="linha_calend"]/a/strong//text()'):
    races.append(r)

dates = []
for d in tree.xpath('//dt//text()'):
    dates.append(d)

dists = []
for r in races:
    dists.append(regex.findall(r))

cal = zip(races, dates, dists)

for c in cal:
   print c
