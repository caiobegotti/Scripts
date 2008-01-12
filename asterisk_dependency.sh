#!/bin/bash

find . -type f -iname '*.[hc]' | while read i; do cat $i | sed -e '/^#include </!d' -e 's/^.* //' -e 's/[><"*]//g' -e '/^[[:alnum:]]/!d'; done | sort -u > foo

while read i; do LC_ALL=C apt-file search "/usr/include/${i}" ; done < foo

exit 0
