#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

from __future__ import division
from matplotlib import pyplot

import csv

INPUT='./imdb.csv'

def getColumn(filename, column):
    results = csv.reader(open(filename), delimiter="|")
    return [result[column] for result in results]

def normalizeBoxoffice(value):
    ret = value
    if '.' in ret:
        if 'K' in ret:
            ret = ret.replace('K', '00')
            ret = ret.replace('.', '')
        elif 'M' in ret:
            ret = ret.replace('M', '00000')
            ret = ret.replace('.', '')
    else:
        if 'K' in ret:
            ret = ret.replace('K', '000')
        elif 'M' in ret:
            ret = ret.replace('M', '000000')
    return ret

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

    year_list = [int(x) for x in year_list]
    runtime_list = [int(x) for x in runtime_list]

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
    yearsticks = sorted(set([x for x in year_list if x % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotReleasesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    year_list = [int(x) for x in year_list]

    per_year_count = {}
    for y in sorted(set(year_list)):
        per_year_count[y] = year_list.count(y)

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
    yearsticks = sorted(set([x for x in year_list if x % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotBoxofficePerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    gross_list = getColumn(INPUT, 4)
    gross_list = filterNotAvailable(gross_list, '0')

    year_list = [int(x) for x in year_list]
    gross_list = [int(normalizeBoxoffice(x)) for x in gross_list]

    fig = pyplot.figure(figsize=(25, 25), dpi=100)

    m = fig.add_subplot(211)
    m.bar(year_list, gross_list, color='#64BE3F')
    m.set_xlim([1900, 2016])

    # labels
    pyplot.title('Total boxoffice gross (~286k films)')
    pyplot.xlabel('Year')
    pyplot.ylabel('Boxoffice')
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([x for x in year_list if x % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotStackedRuntimesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    runtime_list = getColumn(INPUT, 3)
    runtime_list = filterNotAvailable(runtime_list, '0')

    year_list = [int(x) for x in year_list]
    runtime_list = [int(x) for x in runtime_list]

    # here be dragons!
    # close your eyes and they disappear
    per_year_buckets = {}
    for y in sorted(set(year_list)):
        bucket = {}
        b30 = b60 = b90 = b120 = b180 = b300 = 0
        for row in zip(year_list, runtime_list):
            if row[0] == y:
                r = row[1]
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
    # import json
    # print json.dumps(per_year_buckets, indent=4, sort_keys=True)

    # still dragons around here
    percentage_per_year = {}
    for y in sorted(set(year_list)):
        total_of_year = sum(per_year_buckets[y].values())
        bucket_percentages = {}
        for bucket in per_year_buckets[y].keys():
            total_of_bucket = per_year_buckets[y][bucket]
            percentage = float((total_of_bucket / total_of_year ) * 100)
            bucket_percentages[bucket] = percentage
        percentage_per_year[y] = bucket_percentages

    # debugging
    # import json
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

    fig = pyplot.figure(figsize=(25, 25), dpi=100)
    ind = sorted(set(year_list))
    m = fig.add_subplot(211)

    s90b = [sum(a) for a in zip(*[s30, s60])]
    s120b = [sum(a) for a in zip(*[s30, s60, s90])]
    s180b = [sum(a) for a in zip(*[s30, s60, s90, s120])]
    s300b = [sum(a) for a in zip(*[s30, s60, s90, s120, s180])]

    s1 = m.bar(ind, s30, width=1, edgecolor='none', color='#8484D5') # purple
    s2 = m.bar(ind, s60, width=1, edgecolor='none', color='#DA8CD0', bottom=s30) # red
    s3 = m.bar(ind, s90, width=1, edgecolor='none', color='#65CC87', bottom=s90b) # green
    s4 = m.bar(ind, s120, width=1, edgecolor='none', color='#E4E4B1', bottom=s120b) # yellow
    s5 = m.bar(ind, s180, width=1, edgecolor='none', color='#8AB0D8', bottom=s180b) # blue
    s6 = m.bar(ind, s300, width=1, edgecolor='none', color='#000000', bottom=s300b) # black

    m.set_xlim([1900, 2016])
    m.set_ylim([0, 100])

    # legend box setup
    colors = [s1, s2, s3, s4, s5, s6]
    labels = ['< 30 min', 'up to 60 min', 'up to 90 min', 'up to 2 hours', 'up to 3 hours', '> 3 hours']
    pyplot.legend(colors, labels, fancybox=True, loc="lower center")

    # labels
    pyplot.title('Percentages of runtimes buckets per year (~286k films)')
    pyplot.xlabel('Runtimes per year')
    pyplot.ylabel('Percentages of runtimes buckets')
    pyplot.margins(0, 0)
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([x for x in year_list if x % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

def plotLongOnesPerYear(filename):
    year_list = getColumn(INPUT, 1)
    year_list = filterNotAvailable(year_list, '2015')

    runtime_list = getColumn(INPUT, 3)
    runtime_list = filterNotAvailable(runtime_list, '0')

    year_list = [int(x) for x in year_list]
    runtime_list = [int(x) for x in runtime_list]

    # here be dragons!
    # close your eyes and they disappear
    per_year_buckets = {}
    for y in sorted(set(year_list)):
        bucket = {}
        b30 = b60 = b90 = b120 = b180 = b300 = 0
        for row in zip(year_list, runtime_list):
            if row[0] == y:
                r = row[1]
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
    # import json
    # print json.dumps(per_year_buckets, indent=4, sort_keys=True)

    # still dragons around here
    percentage_per_year = {}
    for y in sorted(set(year_list)):
        total_of_year = sum(per_year_buckets[y].values())
        bucket_percentages = {}
        for bucket in per_year_buckets[y].keys():
            total_of_bucket = per_year_buckets[y][bucket]
            try:
                percentage = float((total_of_bucket / total_of_year ) * 100)
            except ZeroDivisionError:
                percentage = 0
            bucket_percentages[bucket] = percentage
        percentage_per_year[y] = bucket_percentages

    # debugging
    # import json
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

    s120 = stacks_per_bucket[120]
    s180 = stacks_per_bucket[180]

    fig = pyplot.figure(figsize=(25, 25), dpi=100)
    ind = sorted(set(year_list))
    m = fig.add_subplot(211)

    m.plot(ind, s120, label="Between 2h-3h", linestyle="-", linewidth=10, color='r')
    m.plot(ind, s180, label="Over 3h", linestyle="-", linewidth=1, color='b')

    m.set_xlim([1990, 2016])
    m.set_ylim([0, 50])

    # labels
    pyplot.legend(loc='upper left')
    pyplot.title('Percentages of runtimes buckets per year (~286k films)')
    pyplot.xlabel('Runtimes per year')
    pyplot.ylabel('Percentages of runtimes buckets')
    pyplot.margins(0, 0)
    pyplot.grid(True)

    # increase x time resolution
    yearsticks = sorted(set([x for x in year_list if x % 5 == 0]))
    pyplot.xticks(yearsticks)
    pyplot.savefig(filename, bbox_inches='tight', dpi=100)

#print 'plotReleasesPerYear'
#plotReleasesPerYear('imdb_releases_per_year.png')

#print 'plotBoxofficePerYear'
#plotBoxofficePerYear('imdb_boxoffice_per_year.png')

#print 'plotRuntimesPerYear'
#plotRuntimesPerYear('imdb_runtimes_per_year.png')

#print 'plotStackedRuntimesPerYear'
#plotStackedRuntimesPerYear('imdb_runtimes_per_year_stacked.png')

print 'plotLongOnesPerYear'
plotLongOnesPerYear('imdb_long_ones_per_year.png')
