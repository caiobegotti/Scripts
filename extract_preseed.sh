#!/bin/bash -e
#
# script to extract supposed debian-installer's preseed entries
# caio begotti <caio@ueberalles.net> on Wed,  4 Oct 2006 17:06:29 -0300

didir=/root/d-i/packages/
output=/root/preseed.txt

templates=$(find ${didir} -type f | grep .templates$ | sort -u)

rm -rf /tmp/*.sed

for file in ${templates}
do
	base=$(basename ${file})
	sed '/^ /,/^$/d;/^$/d;/^#/d' ${file} > /tmp/${base}.sed
done

for parse in $(ls -1 /tmp/*.sed)
do
	while read i
	do
		if echo ${i} | grep -q '^Template:'
		then
			name=$(echo ${i} | sed 's/^Template:/d-i/')
#			echo ${i} .......... ${name}
		fi
	
		if echo ${i} | grep -q '^Type:'
		then
			 type=$(echo ${i} | sed 's/^Type: //')
#			 echo ${i} ......... ${type}
		fi
	
		if echo ${i} | grep -q '^Default:'
		then
			 value=$(echo ${i} | sed 's/^Default: //')
#			 echo ${i} ......... ${value}
		fi

		if echo ${i} | grep -q '^_Description:'
		then
			 desc=$(echo ${i} | sed 's/^_Description: //' | head -1)
#			 echo ${i} ......... ${desc}
		fi

	test -z "${desc}" && echo -e "\n# (No description found)" || echo -e "\n# ${desc}"
	echo -e "${name} ${type} ${value}"

	done < ${parse}
done         > ${output}

exit 0
