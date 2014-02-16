#!/bin/bash -xev
#
# this file is under public domain
# caio begotti <caio1982@gmail.com>

_count() {
	echo $(echo ${1} | sed 's/^.*start=\([0-9]\{1,\}\)\&.*/\1/g')
}

_url() {
	echo $(sed '/Next/!d;s/^.*="//g;s/".*$//g' ${1} | head -1)
}

_cleanup() {
	rm -vf .html *.html imdb.log imdb.search
}

_loop() {
	while true; do
		if [ ! -e "${count}.html" ]; then
			# sometimes it just fails (either by some weird 500 error or just timeouts), so let's retry it
			${mywget} "${imdb}${url}" -O ${count}.html || (rm ${count}.html; ${mywget} "${imdb}${url}" -O ${count}.html)
		fi
		url=$(_url ${count}.html)
	        if [ "${url}" == "" ]; then export url='/search/title?at=0&count=100&sort=moviemeter,asc&start=99851&title_type=feature&tok=17bd&year=1900,2015'; _cleanup; break; break; fi
		count=$(_count ${url})
	        if [ "${count}" == "" ]; then export count='99851'; _cleanup; break; break; fi
	done
}

mywget='wget -t 5 -T 30 -x --load-cookies cookies.txt'

imdb=http://www.imdb.com
startpage=99851
limitpage=285000

search="/search/title?at=0&count=100&sort=moviemeter,asc&start=${startpage}&title_type=feature&tok=17bd&year=1900,2015"
fullsearch="${imdb}${search}"
${mywget} ${fullsearch} -O imdb.search

url="$(sed '/Next/!d;s/^.*="//g;s/".*$//g' imdb.search | head -1)"
count="$(echo ${url} | sed 's/^.*start=\([0-9]\{1,\}\)\&.*/\1/g')"

while [ "${count}" -lt "${limitpage}" ]; do
	_loop
	date >> imdb.log
done

exit 0
