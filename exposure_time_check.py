#!/usr/bin/env python
#
# based on http://www.fabrizio-branca.de/lightroom-plugin-detect-blurry-images.html
# this is the python version of my exposure_time_check.sh
# caio begotti <caio1982@gmail.com> - public domain

from __future__ import division

from sys import argv
from sys import exit
from os.path import exists

from ExifTags import TAGS as tags
import Image as image

def get_exif(fn):
    ret = {}
    i = image.open(fn)
    info = i._getexif()
    for tag, value in info.items():
        decoded = tags.get(tag, tag)
        ret[decoded] = value
    return ret

def calc_factor(input):
    image = get_exif(input)
    fl = image['FocalLength']
    et = image['ExposureTime']
    factor = ( et[0] / et[1] ) / ( 1 / ( fl[0] / fl[1] ) )
    return factor

def input_loop(argv):
    for file in argv[1:]:
        if not exists(file):
            exit('No such file or directory: ' + file)
        print file + ": " + str(calc_factor(file))

if len(argv) >= 2:
    input_loop(argv)
else:
    exit('Usage: ' + argv[0] + ' <photograph filenames>')
