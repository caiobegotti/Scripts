#!/bin/bash -xv
#
# this should be a script that makes some analysis on
# svn blame outputs and rank developers by line written
# caio begotti <caio@ueberalles>

# cat ASTERISK_HALL_OF_FAME.txt | awk '{ print $2}' | sort -u | while read i; do grep $i ASTERISK_HALL_OF_FAME.txt | wc -l && echo $i; done | sed 'N;s/\n/ /'

astdir=${1}
rm -rf /tmp/${0}.*

find ${astdir} -type f -exec svn blame {} \;

exit 0
