#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

import pandas

from matplotlib import pyplot

columns = ['titles', 'years', 'runtimes', 'links']
data = pandas.read_csv('imdb.txt', sep='\t', names=columns)
years = list(data.years)
runtimes = list(data.runtimes)

fig = pyplot.figure(figsize=(50, 10), dpi=100)
g = fig.add_subplot(121)
g.scatter(years, runtimes, marker='x', s=50, linewidths=0.25, alpha=0.25, cmap=pyplot.cm.coolwarm)

# we have only a few releases over 300 minutes
# of length, they would pollute the plot
g.set_xlim([1900, 2015])
g.set_ylim([0, 300])

# labels
pyplot.title('Movies runtimes over the years (~153k films)')
pyplot.xlabel('Year of release')
pyplot.ylabel('Length (in minutes)')
pyplot.grid(True)

# increase x time resolution
yearsticks = sorted(set([int(x) for x in years if x % 10 == 0]))
pyplot.xticks(yearsticks)

pyplot.savefig('imdb.png', bbox_inches='tight', dpi=100)
