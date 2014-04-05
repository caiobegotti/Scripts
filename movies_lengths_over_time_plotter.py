#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

import csv

from matplotlib import pyplot

INPUT='./imdb.csv'

def getColumn(filename, column):
    results = csv.reader(open(filename), delimiter="|")
    return [result[column] for result in results]


def filterNotAvailable(list, dummy):
    for index, entry in enumerate(list):
        if 'N/A' in entry:
            list[index] = dummy
    return list

def plotRuntimesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    runtime_list = getColumn(INPUT, 3)
    runtime_list = filterNotAvailable(runtime_list, '0')

    fig = pyplot.figure(figsize=(25, 25), dpi=100)

    # all movies plotted -------------------------
    m = fig.add_subplot(211)

    m.plot(year_list, runtime_list, 'bx', alpha=0.25)

    # we have only a few releases over 300 minutes
    # of length, they would pollute the plot
    m.set_xlim([1900, 2015])
    m.set_ylim([0, 300])

    # labels
    pyplot.title('Movies releases and runtimes per year (~286k films)')
    pyplot.xlabel('Year of release')
    pyplot.ylabel('Runtime in minutes')
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([int(x) for x in year_list if int(x) % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotStackedRuntimesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    runtime_list = getColumn(INPUT, 3)
    runtime_list = filterNotAvailable(runtime_list, '0')

    per_year_count = {}
    for y in sorted(set(year_list)):
        print y

# averages per year --------------------------
#averages = {}
#for t in sorted(set(years)):
#    thisyear = []
#    for y, r in zip(years, runtimes):
#        if y == t:
#            thisyear.append(r)
#    total = len(thisyear)
#    thisyear = [float(x) for x in thisyear]
#    averages[t] = int(sum(thisyear) / total)
#
#for key in sorted(averages.iterkeys()):
#    print key, averages[key]
#
#a = fig.add_subplot(211)
#a.plot(averages.keys(), averages.values(), color='w', linestyle='-', linewidth=5)
#a.plot(averages.keys(), averages.values(), color='r', linestyle='-', linewidth=3)
#
# total number of releases per year ----------
#releases = {}
#for t in sorted(set(years)):
#    thisyear = []
#    for y, r in zip(years, runtimes):
#        if y == t:
#            thisyear.append(r)
#    releases[t] = len(thisyear)
#
#r = fig.add_subplot(211)
#r.set_xlim([1900, 2014])
#r.plot(releases.keys(), releases.values(), color='g', linestyle='-', linewidth=5)
#
# stacked bars of common lengths -------------
#stacked = {}
#for t in sorted(set(years)):
#    t1, t2, t3, t4 = 0, 0, 0, 0
#    for y, r in zip(years, runtimes):
#        if r <= 60 and y == t:
#            t1 += 1
#        if r > 60 and r <= 120 and y ==t:
#            t2 += 1
#        if r > 120 and r <= 180 and y == t:
#            t3 += 1
#        if r > 180 and y == t:
#            t4 += 1
#    stacked[t] = (t1, t2, t3, t4)
#
# i can simply plot.ly for the stacked bars instead
#with open('plotly.csv', 'a') as f:
#    f.seek(0)
#    for y in sorted(set(years)):
#        row = '%s; %s; %s; %s; %s\n' % (y, stacked[y][0], stacked[y][1], stacked[y][2], stacked[y][3])
#        f.write(row)
#    f.close()

plotRuntimesPerYear('imdb_runtimes_per_year.png')
plotStackedRuntimesPerYear('imdb_runtimes_per_year_stacked.png')
