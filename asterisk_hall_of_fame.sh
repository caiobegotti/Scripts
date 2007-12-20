#!/bin/bash -xv
#
# this should be a script that makes some analysis on
# svn blame outputs and rank developers by line written
# caio begotti <caio@ueberalles>

astdir=${1}
rm -rf /tmp/${0}.*

find ${astdir} -type f -exec svn blame {} \;

exit 0
