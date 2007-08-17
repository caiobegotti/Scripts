#!/bin/bash
#
# given imaginary prefixes and suffixes this script can easily
# build every word possible in LaTeX/IPA using a few word bases.
# Thu Aug 16 22:31:53 BRT 2007 caio1982 <caio@ueberalles.net>
#
# a few samples to play with:
#
# base="de kiRa lOmE Ni pubOda"
# prefix="didE i po ut Zatepu"
# sufix="minE om pRi tizaRu tSe"

echo -e "Write down a few word bases separated by space (e.g. 'kiRa lOmE'):" && read base
echo -e "Now gimme some prefixes to use, also separated by space (e.g. 'po ut'):" && read prefix
echo -e "Then, separated by space, type a bunch of suffixes (e.g. 'om pRi'):" && read sufix
echo -e "---------------------------------------------------------------------\n"

for mid in ${base}
do
	echo "${mid}"
	for left in ${prefix}
	do
		echo "${left}${mid}"
		for right in ${sufix}
		do
			echo "${mid}${right}"
			echo "${left}${mid}${right}"
		done
	done
done | sort -u

exit 0
