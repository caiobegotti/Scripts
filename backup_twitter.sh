#!/bin/bash

user=${1}
pages=${2}

for number in $(seq 1 ${pages}); do
	sleep 3
	lynx --source --nolist "http://twitter.com/${user}?page=${number}&twttr=true" | sed '/^.*status-body.*/,/^.*meta-data clearfix.*/!d;/ul class/d;s/^.*status-body.*/<\/p>\n<p>/g' | sed 1d
	echo '</p>'
done

exit 0
