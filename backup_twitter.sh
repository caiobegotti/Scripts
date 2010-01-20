#!/bin/bash

user=${1}
pages=${2}

for number in $(seq 1 ${pages}); do
	sleep 3
	lynx --source --nolist "http://twitter.com/${user}?page=${number}&twttr=true" | sed '/span class="entry-content/,/<span>from/!d;/meta entry-meta/d;s/            /<\/p>\n<p>\n  /g' | sed '1d'
	echo "</p>"
done

exit 0
