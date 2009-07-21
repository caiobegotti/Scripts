#!/bin/bash -xv

user=${1}
pages=${2}

for number in $(seq 1 ${pages}); do
	sleep 3
	lynx --source --nolist "http://twitter.com/${user}?page=${number}&twttr=true" | \
	sed -e '/<ol /!d'                                                               \
	    -e 's/<span /\n<span /g'                                                    \
	    -e 's/<\/ol>//g'                                                            \
	    -e 's/ \+<ol class=.*"timeline">//g'                                        \
	    -e 's/<li /\n\n<li /g'                                                      \
	    -e 's/<\/li>/\n<\/li>/g'                                                  | \
	sed -e '/<span/s/^/\t/g;/^$/d'
done

exit 0
