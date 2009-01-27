#!/bin/bash
# copyright caio begotti <caio1982@gmail.com>
# it is just a proof of concept to ease an asterisk.org
# build on port-based installations (like my own osx)

find ${1} -type f -iname '*.[hc]' | while read i; do cat $i | sed -e '/^#include </!d' -e 's/^.* //' -e 's/[><"*]//g' -e '/^[[:alnum:]]/!d'; done | sort -u > foo

while read i; do LC_ALL=C port provides "${2}/${i}" ; done < foo

exit 0
