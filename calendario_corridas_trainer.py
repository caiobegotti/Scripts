#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain <caio1982@gmail.com>

import web
import json
import re

# should match all distances in kilometers
regex = re.compile("\d+[,.]?\d?[ ]?km", re.IGNORECASE)

from lxml import etree
from datetime import date

parser = etree.HTMLParser()
stamp = date.today()

def venues():
    # first we need to get all venues in the current year/month
    domain = 'http://www.trainerassessoria.com.br/'
    url = '%s/calendario-de-eventos/%s/%s' % (domain, stamp.year, stamp.month)
    tree = etree.parse(url, parser)
    venues = [domain + i for i in tree.xpath('//dd[@class="linha_calend"]/a//@href')]
    return venues

def calendar():
    calendar = {}
    for v in venues():
        tree = etree.parse(v, parser)
        keys = tree.xpath('//dt//text()')
        values = tree.xpath('//dd//text()')
        data = zip(keys, values)
        info = {}
        for key, value in data:
            info[key] = value
        calendar[v] = info
    return calendar

urls = (
    '/', 'index'
)

app = web.application(urls, globals(), True)

class index():
    def GET(self):
        data = calendar()
        web.header('content-type', 'application/json')
        return json.dumps(data)

#web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)

if __name__ == "__main__":
    #web.runwsgi = web.runfcgi
    app.run()
