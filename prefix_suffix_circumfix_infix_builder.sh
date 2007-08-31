#!/bin/bash
#
# build every word possible in LaTeX/IPA using a bunch of morphemes
# Thu Aug 16 22:31:53 BRT 2007 caio1982 <caio@ueberalles.net>
# sed 's/../&x/'

echo -e "\nWrite down a few word bases separated by space (e.g. 'kiRa lOmE'):" && read base
echo -e "\nNow gimme some prefixes to use, also separated by space (e.g. 'po ut'):" && read prefix
echo -e "\nThen, separated by space, type a bunch of suffixes (e.g. 'om pRi'):" && read sufix
echo -e "\nOk, now type some circumfixes with '-' as delimiter (e.g. 'ar-tuO ka-fE'):" && read circumfix
echo -e "\nTo finish it, give me one or two infixes if you want and their rules:"
echo -e "(e.g. 'ing-..$' means 'infix ing before the last two phonemes in all words'"
echo -e " or '^.-jo' that means 'infix jo after the first phoneme of every word')\n" && read infixes


function main()
{
	for circ in ${circumfix}
	do
		circbeg=$(echo ${circ} | cut -d- -f1)
		circend=$(echo ${circ} | cut -d- -f2)
		for mid in ${base}
		do
			echo "${mid}"
			echo "${circbeg}${mid}${circend}"
			for left in ${prefix}
			do
				echo "${left}${mid}"
				echo "${circbeg}${left}${mid}${circend}"
				for right in ${sufix}
				do
					echo "${mid}${right}"
					echo "${left}${mid}${right}"
					echo "${circbeg}${mid}${right}${circend}"
					echo "${circbeg}${left}${mid}${right}${circend}"
				done
			done
		done
	done
}

main | sort -u
exit 0
