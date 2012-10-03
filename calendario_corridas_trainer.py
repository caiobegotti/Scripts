#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain <caio1982@gmail.com>

import json
import re

# should match all distances in kilometers
regex = re.compile("\d+[,.]?\d?[ ]?km", re.IGNORECASE)

from lxml import etree
from datetime import date

parser = etree.HTMLParser()
stamp = date.today()

# it might get changed over time, have to keep it up with it somehow
url = 'http://www.trainerassessoria.com.br/calendario-de-eventos/%s/%s' % (stamp.year, stamp.month)

tree = etree.parse(url, parser)

races = list(tree.xpath('//dd[@class="linha_calend"]/a/strong//text()'))
dates = list(tree.xpath('//dt//text()'))
dists = [regex.findall(r) for r in races]

cal = zip(races, dates, dists)

for c in cal:
   print c
