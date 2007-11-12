#!/bin/bash

temp=$(mktemp)
sed 's/"/|/g;s/|,|/|/g' ${1} > ${temp}

while read line
do
	date=$(echo ${line} | cut -d'|' -f2)
	value=$(echo ${line}| cut -d'|' -f7)
	desc=$(echo ${line} | cut -d'|' -f4)
	echo -e "${date}\t${value}\t${desc}"

done < ${temp} | iconv -c -t UTF-8 -f ISO-8859-1 | sed '/^[Dd]ata\|S\ \?A \?L \?D \?O/d'

exit 0
