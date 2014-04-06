#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

from __future__ import division
from matplotlib import pyplot

import csv
import json
import numpy

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

    m = fig.add_subplot(211)
    m.plot(year_list, runtime_list, 'x', alpha=0.25, color='#45036F')

    # we have only a few releases over 300 minutes
    # of length, they would pollute the plot
    m.set_ylim([0, 300])
    m.set_xlim([1900, 2016])

    pyplot.title('Movies releases and runtimes per year (~286k films)')
    pyplot.xlabel('Year of release')
    pyplot.ylabel('Runtime in minutes')
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([int(x) for x in year_list if int(x) % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotReleasesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    runtime_list = getColumn(INPUT, 3)
    runtime_list = filterNotAvailable(runtime_list, '0')

    per_year_count = {}
    for y in sorted(set(year_list)):
        per_year_count[int(y)] = int(year_list.count(y))

    fig = pyplot.figure(figsize=(25, 25), dpi=100)

    m = fig.add_subplot(211)
    m.bar(per_year_count.keys(), per_year_count.values(), color='#00665E')
    m.set_xlim([1900, 2016])

    # labels
    pyplot.title('Total of releases year (~286k films)')
    pyplot.xlabel('Year')
    pyplot.ylabel('Movies released')
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

    # here be dragons!
    # close your eyes and they disappear
    per_year_buckets = {}
    for y in sorted(set(year_list)):
        bucket = {}
        b30 = b60 = b90 = b120 = b180 = b300 = 0
        for row in zip(year_list, runtime_list):
            if row[0] == y:
                r = int(row[1])
                if r <= 30:
                    b30 += 1
                if r > 31 and r <= 60:
                    b60 += 1
                if r > 61 and r <= 90:
                    b90 += 1
                if r > 91 and r <= 120:
                    b120 += 1
                if r > 121 and r <= 180:
                    b180 += 1
                if r > 181:
                    b300 += 1
                bucket[30] = b30
                bucket[60] = b60
                bucket[90] = b90
                bucket[120] = b120
                bucket[180] = b180
                bucket[300] = b300
        per_year_buckets[y] = bucket

    # debugging
    # print json.dumps(per_year_buckets, indent=4, sort_keys=True)

    # still dragons around here
    percentage_per_year = {}
    for y in sorted(set(year_list)):
        total_of_year = int(sum(per_year_buckets[y].values()))
        bucket_percentages = {}
        for bucket in per_year_buckets[y].keys():
            total_of_bucket = int(per_year_buckets[y][bucket])
            percentage = float((total_of_bucket / total_of_year ) * 100)
            bucket_percentages[bucket] = percentage
        percentage_per_year[y] = bucket_percentages

    # debugging
    # print json.dumps(percentage_per_year, indent=4, sort_keys=True)

    stacks_per_year = []
    for y in sorted(set(year_list)):
        stacks_per_year.append(percentage_per_year[y].values())

    stacks_per_bucket = {}
    for p in percentage_per_year[y].keys():
        points = []
        for y in percentage_per_year.keys():
            points.append(percentage_per_year[y][p])
        stacks_per_bucket[p] = points

    s30 = stacks_per_bucket[30]
    s60 = stacks_per_bucket[60]
    s90 = stacks_per_bucket[90]
    s120 = stacks_per_bucket[120]
    s180 = stacks_per_bucket[180]
    s300 = stacks_per_bucket[300]

    # number of buckets in stacked bars
    ind = numpy.arange(116)
    width = 5

    fig = pyplot.figure(figsize=(25, 25), dpi=100)

    m = fig.add_subplot(211)
    m.bar(ind, s30, width, color='r', yerr=s60)
    m.bar(ind, s60, width, color='g', bottom=s30, yerr=s90)
    m.bar(ind, s90, width, color='b', bottom=s60, yerr=s120)
    m.bar(ind, s120, width, color='r', bottom=s90, yerr=s180)
    m.bar(ind, s180, width, color='g', bottom=s120, yerr=s300)
    m.bar(ind, s300, width, color='b', bottom=s180, yerr=s30)
    m.set_xlim([1900, 2016])

    # labels
    pyplot.title('Runtimes percentage per year (~286k films)')
    pyplot.xlabel('Year')
    pyplot.ylabel('Runtimes buckets')
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([int(x) for x in year_list if int(x) % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

print 'plotReleasesPerYear'
plotReleasesPerYear('imdb_releases_per_year.png')

print 'plotRuntimesPerYear'
plotRuntimesPerYear('imdb_runtimes_per_year.png')

print 'plotStackedRuntimesPerYear'
plotStackedRuntimesPerYear('imdb_runtimes_per_year_stacked.png')
