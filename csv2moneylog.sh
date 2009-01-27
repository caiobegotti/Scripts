#!/bin/bash
# it's used to convert an CSV file (from my home banking site
# to aurelio.net's moneylog simple format... have fun with it
# copyright caio begotti <caio1982@gmail.com>

temp=$(mktemp)
sed 's/"/|/g;s/|,|/|/g' ${*} > ${temp}

while read line
do
	fulldate=$(echo ${line} | cut -d'|' -f2)
		month=$(echo ${fulldate} | cut -d/ -f1)
		day=$(echo ${fulldate}   | cut -d/ -f2)
		year=$(echo ${fulldate}  | cut -d/ -f3)
		date=${year}-${month}-${day}

	value=$(echo ${line}| cut -d'|' -f7)
	desc=$(echo ${line} | cut -d'|' -f4)
	echo -e "${date}\t${value}\t${desc}"

done < ${temp} | iconv -c -t UTF-8 -f ISO-8859-1 | sed '/^[Dd]ata\|S\ \?A \?L \?D \?O/d'

exit 0
