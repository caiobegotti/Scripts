#!/bin/bash -e
#
# caio begotti <caio1982@gmail.com> on Mon Aug 17 11:46:50 BRT 2009
#
# script created to automatically fetch all issues ever published
# of the new yorker magazine (since 1925), username and password required.

# get the issues list by year
# http://archives.newyorker.com/global/content/GetArchive.aspx?pid=1012&type=IssuesForYear&Year=1999&var&rnd=0.7633019806586238
# lynx -dump --nolist 'http://archives.newyorker.com/global/content/GetArchive.aspx?pid=1012&type=IssuesForYear&Year=1925' | cut -d: -f3 | sed '/_/!d;s/"//g;s/,.*$//'

# get a specific page, ready for printing
# http://archives.newyorker.com/djvu/Conde%20Nast/New%20Yorker/2009_08_24/webimages/page0000001_print.jpg

. /Users/caio1982/.bashrc

function get_issues_by_year() {
	for year in $(seq 1925 $(date +%Y)); do
		url=http://archives.newyorker.com/global/content/GetArchive.aspx\?pid=1012\&type=IssuesForYear\&Year=${year}
		lynx -dump --nolist ${url} | cut -d: -f3 | sed '/_/!d;s/"//g;s/,.*$//'
	done | sort -u
}

function get_pages_from_issue() {
	for issue in get_issues_by_year; do
		mkdir -p ${issue}
		for page in $(seq -w 0000001 0000300); do
			wget -q http://archives.newyorker.com/djvu/Conde%20Nast/New%20Yorker/${issue}/webimages/page${page}_print.jpg
		done

		echo "LOG: issue ${issue} fully fetched with $(find ${issue} -type f -iname "*_print.jpg" | wc -l) pages"
	done
}

function main() {
	get_pages_from_issue
}


main
exit 0
