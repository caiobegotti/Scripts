#!/bin/bash -e
# a tiny script that merges tons of bookmarks.html from mozilla in a single one
# caio begotti <caio@ueberalles.net> on Mon, 19 Mar 2007 11:26:59 -0300

input_file="$*"

function func_print()
{
    echo -e "${1}"
}

temp=$(mktemp)
cat $* > ${temp}

input_list=$(sed '/A HREF/!d;s/^ \+//' ${temp})

while read line
do
    add_date=$(echo ${line} | sed 's/^.* ADD_DATE="//;s/".*$//;s/[[:alpha:][:punct:]]//g')
    last_visit=$(echo ${line} | sed 's/^.* LAST_VISIT="//;s/".*$//;s/[[:alpha:][:punct:]]//g')
    url=$(echo ${line} | sed 's/^.*HREF="//;s/".*$//;s/<[^>]*>//g')
    title=$(echo ${line} | sed 's/<[^>]*>//g')

    func_print "adicionado...: ${add_date}"
    func_print "visitado.....: ${last_visit}"
    func_print "url..........: ${url}"
    func_print "titulo.......: ${title}\n"

done < ${temp}

exit 0
