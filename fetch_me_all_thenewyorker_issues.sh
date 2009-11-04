#!/bin/bash
#
# caio begotti <caio1982@gmail.com> on Mon Aug 17 11:46:50 BRT 2009
#
# script created to automatically fetch all issues ever published of
# the new yorker magazine (since 1925), you will need cookies (and milk)

test -n ${1} && echo "${0} [year(s)]"

year=${1}

function get_issues_by_year() {
	for year in ${year}; do
		url=http://archives.newyorker.com/global/content/GetArchive.aspx\?pid=1012\&type=IssuesForYear\&Year=${year}
		lynx -dump --nolist ${url} | cut -d: -f3 | sed '/_/!d;s/"//g;s/,.*$//'
	done | sort -u
}

function get_pages_from_issue() {
	for issue in $(get_issues_by_year); do
		test -d ${issue} || mkdir -p ${issue}
		rm -rf urls

		for page in $(seq -w 001 175); do
			echo "http://archives.newyorker.com/djvu/Conde%20Nast/New%20Yorker/${issue}/webimages/page0000${page}_print.jpg" >> urls
		done

		for file in $(cat urls | uniq); do
			output=${issue}/$(echo ${file} | sed 's/^.*\///')
			test -e ${output} || wget --load-cookies ./cookies.txt "${file}" -O ${output} || rm -rf ${output}
		done

		find ${issue} -size 0 -exec rm -rf {} \;
		echo "LOG: issue ${issue} fully fetched with $(find ${issue} -type f -iname "*_print.jpg" | wc -l) pages"
	done
}

function main() {
	get_pages_from_issue
}

main
exit 0
