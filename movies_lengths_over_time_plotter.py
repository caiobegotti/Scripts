#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

from matplotlib import pyplot

import numpy
import pandas

columns = ['titles', 'years', 'runtimes', 'links']
dtype = {'titles': numpy.object, 'years': numpy.int64, 'runtimes': numpy.int64, 'links': numpy.object}
data = pandas.read_csv('imdb.txt', sep='\t', names=columns, dtype=dtype)
years = list(data.years)
runtimes = list(data.runtimes)

fig = pyplot.figure(figsize=(50, 10), dpi=100)

# all movies plotted -------------------------
m = fig.add_subplot(121)
m.scatter(years, runtimes, marker='x', s=50, linewidths=0.25, alpha=0.25)

# we have only a few releases over 300 minutes
# of length, they would pollute the plot
m.set_xlim([1900, 2015])
m.set_ylim([0, 300])

# averages per year --------------------------
releases = {}
for t in sorted(set(years)):
    thisyear = []
    for y, r in zip(years, runtimes):
        if y == t:
            thisyear.append(r)
    total = len(thisyear)
    releases[t] = sum(thisyear) / total

a = fig.add_subplot(121)
a.plot(releases.keys(), releases.values(), color='w', linestyle='-', linewidth=5)
a.plot(releases.keys(), releases.values(), color='r', linestyle='-', linewidth=3)

# labels
pyplot.title('Movies runtimes over the years (~153k films)')
pyplot.xlabel('Year of release')
pyplot.ylabel('Length (in minutes)')
pyplot.grid(True)

# increase x time resolution
yearsticks = sorted(set([int(x) for x in years if x % 10 == 0]))
pyplot.xticks(yearsticks)

pyplot.savefig('imdb.png', bbox_inches='tight', dpi=100)
