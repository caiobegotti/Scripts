#!/bin/bash -xev

find . -type f -iname '*.[hc]' | while read i; do cat $i | sed -e
'/^#include/!d' -e 's/^.* //' -e 's/[><"*]//g' -e '/^[[:alnum:]]/!d';
done | sort -u  > foo
while read i; do find /usr/include /opt/local/include -iname "$i"; done < foo

while read i; do find /usr/include | grep "/$i"; done < foo > foo1

while read i; do LC_ALL=C rpm -qf $i; done < foo1 | sort -u | grep -v
'not owned'

while read i; do LC_ALL=C urpmf $i; done < foo1 | sed 's/:.*$//' | sort -u

find . -type f -iname '*.[hc]' | while read i; do cat $i | sed -e
'/^#include </!d' -e 's/^.* //' -e 's/[><"*]//g' -e
'/^[[:alnum:]]/!d'; done | sort -u

exit 0
