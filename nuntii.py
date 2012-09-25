#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain <caio1982@gmail.com>
# news scraper of the latin broadcasts of ephemeris


import tweepy
import tinyurl

from time import sleep
from datetime import date
from sys import exit
from lxml import etree

parser = etree.HTMLParser()

categories = ['inorbe',
              'nuntii',
              'crater',
              'miscellanea',
              'politica',
              'scientiae',
              'medicina',
              'athletica',
              'oeconomia',
              'homines',
              'religio',
              'socialia',
              'percontatio',
              'opiniones',
              'insolita']

for cat in categories:
    tree = etree.parse('http://www.alcuinus.net/ephemeris/archi2012/rubric1.php?categ=' + cat, parser)

    news_titles = []
    for t in tree.xpath('//b/a[@class="a_txt1"]'):
        news_titles.append(t.text.lower())

    news_links = []
    for u in tree.xpath('//b/a[@class="a_txt1"]//@href'):
        tiny = tinyurl.create_one('http://www.alcuinus.net/ephemeris/archi2012/' + u)
        news_links.append(tiny.replace('http://', ''))

    news_dates = []
    for d in tree.xpath('//em'):
        published = d.text.split('-')[1].strip()
        news_dates.append(published)

    data = zip(news_titles, news_links, news_dates)

    tweets = []
    for d in data:
        headline = d[0]
        postlink = d[1]
        postdate = d[2]
        stamp = date.today()
        today = '%d/%d/%d' % (stamp.day, stamp.month, stamp.year)
        if today in postdate:
            if len(headline) > 120:
                headline = headline[:115] + '...'
            text = '%s → %s' % (headline, postlink)
            tweets.append(text)

    for t in tweets:
        auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
        auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
        api = tweepy.API(auth)
        api.update_status(t)
        sleep(2500)
