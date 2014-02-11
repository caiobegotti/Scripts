#!/bin/bash -xv

base_url='http://www.imdb.com/search/title?at=0&count=100&sort=moviemeter,asc&start=99951&title_type=feature&tok=17bd&year=1900,2015'

wget -x --load-cookies cookies.txt ${base_url} -O base_url.html

url=$(sed '/Next/!d;s/^.*="//g;s/".*$//g' base_url.html | head -1)

while true; do
	count=$(echo ${url} | sed 's/^.*start=\([0-9]\{1,\}\)\&.*/\1/g')
	if [ ! -e ${count}.html ]; then
		wget -x --load-cookies cookies.txt "http://www.imdb.com${url}" -O ${count}.html || exit 1
	fi
        url=$(sed '/Next/!d;s/^.*="//g;s/".*$//g' ${count}.html | head -1)
done

exit 0
