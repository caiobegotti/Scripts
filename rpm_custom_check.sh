#!/bin/bash -xv
#
# checks every package to be upgraded to find out
# whether they have any local customization or not.
#
# copyright caio begotti <caio1982@gmail.com> on Wed, 15 Aug 2007 06:17:51 -0700
#
# RPM's checking output:
#
# S file size differs
# M file mode differs
# 5 md5 sum differs
# D major/minor number mismatch
# L readlink path mismatch
# U user ownership differs
# G group ownership differs
# T mtime differs

temp=$(mktemp)
yes n | LC_ALL=C urpmi --auto-select | sort -u > ${temp}
sed -i 's/-[0-9]\+.*$//g;/^.roceed with/d;/^.o satisfy/d' ${temp}

while read rpm; do
	echo -e "CUSTOM ${rpm}:\t"
	rpm -qV $(rpm -qa ${rpm} | head -1)
	rpm -qV $(rpm -qa ${rpm}* | head -1)
done < ${temp}

exit 0
