#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

import matplotlib.pyplot as plt
import pandas

columns = ['titles', 'years', 'runtimes', 'links']
data = pandas.read_csv('imdb.txt', sep='\t', names=columns)
years = list(data.years)
runtimes = list(data.runtimes)

fig = plt.figure(figsize=(50, 10), dpi=100)
g = fig.add_subplot(121)
g.scatter(years, runtimes, color='blue', edgecolor='none', s=5, lw=5)

# we have only a few releases over 300 minutes
# of length, they would pollute the plot
g.set_xlim([1900, 2015])
g.set_ylim([0, 300])

# labels
plt.title('Movies runtimes over the years (~122k films)')
plt.xlabel('Year of release')
plt.ylabel('Length (in minutes)')
plt.grid(True)

# increase x time resolution
yearsticks = sorted(set([int(x) for x in years if x % 10 == 0]))
plt.xticks(yearsticks)

plt.savefig('imdb.png', bbox_inches='tight', dpi=100)
