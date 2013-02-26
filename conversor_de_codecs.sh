#!/bin/bash
#
# script pra converter audios de uma maquina para todos
# os formatos suportados pelo asterisk via modulos de codecs
#
# caio begotti <caio@ueberalles.net>
# script licenciado sob a GPLv2
#
# Qua Jun  6 02:10:49 BRT 2007

# remove cabecalho do output, apaga possiveis duplicatas e a variacao do g726aal2
# alguem ai sabe como imprimir colunas no sed? esse awk perdido esta feio
codecs=$(sudo asterisk -rx "core show translation" | sed '/-   -/d;1,3d;/aal2/d;/UNIX/d' | awk '{print $1}' | sort -u)

# diretorio dos audios
path=${1}

# formato padrao dos seus audios
default=${2}

for format in ${codecs}
do
	while read file
	do
		test -e ${file} && sudo asterisk -rx "file convert ${file} $(echo ${file} | sed "s/.${default}$/.${format}/")"

	done < <(find ${path} -iname "*.${default}")
done

echo ${codecs}

exit 0
