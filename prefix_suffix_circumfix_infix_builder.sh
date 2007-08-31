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
echo -e "Ok then, now type some circumfixes with '-' as delimiter (e.g. 'ar-tuO'):" && read circumfix
echo -e "To finish it, give me one or two infixes if you want (e.g. 'Eng Ri '):" && read infix

function main()
{
	for circ in ${circumfix}
	do
		circbeg=$(echo ${circumfix} | cut -d- -f1)
		circend=$(echo ${circumfix} | cut -d- -f2)

		for mid in ${base}
		do
			# lista base
			echo "${mid}"

			# lista base com circumfixo
			echo "${circbeg}${mid}${circend}"

			for left in ${prefix}
			do
				# lista prefixo na base
				echo "${left}${mid}"

				# lista prefixo na base com circumfixo
				echo "${circbeg}${left}${mid}${circend}"

				for right in ${sufix}
				do
					# lista base com sufixo
					echo "${mid}${right}"

					# lista base com sufixo e circumfixo
					echo "${circbeg}${mid}${right}${circend}"
	
					# lista base com prefixo e sufixo
					echo "${left}${mid}${right}"

					# lista base com prefixo, sufixo e circumfixo
					echo "${circbeg}${left}${mid}${right}${circend}"
				done
			done
		done
	done
}

main | sort -u

exit 0
