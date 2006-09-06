#!/bin/bash -e
#
# Tue, 29 Aug 2006 20:16:44 -0300
# caio begotti <caio@ueberalles.net>
#
# esse script meio porco serviu pra gerar um PDF das tirinhas dos malvados
# usando somente os comandos lynx + wget + imagemagick + pdftk
#
# os sleeps entre comandos sao pra nao dar segfault (nao pergunte o porque)
#
# tamanhos de papel pra posicionamento das tirinhas:
# http://upload.wikimedia.org/wikipedia/commons/b/b8/A_size_illustration.gif
#
# livrao do calvin & hobbes tem 830 de largura por 870 de altura
# tamanho padrao de cada tirinha: 591 x 188, formato .png
#
# pra botar borda branca na tira individual
# convert testeY.png -mattecolor white -frame 50x20-0-0 testeX.png
#
# juntar varias tiras em uma imagem
# convert 1.png 2.png * -append malvados.png
#
# botar bordinha soh pra dizer que tem
# convert finalY.png -mattecolor white -frame 50x50+0+1 finalX.png
#
# adicionar numeracao na parte de cima
# convert 1.png -fill white -box '#000000' -gravity North -annotate +0+0 '25' final.png
#
# botar copyright na pagina cheia de tirinhas
# convert foo.png -gravity South -background White -splice 0x0 -draw "text 0,0 'Malvados é criação de André Dahmer'" bar.png
#
# gerar um PDF unico com multiplas paginas .pdf
# pdftk *.pdf cat output livro.pdf

url="http://www.malvados.com.br"

clear

rm -rf tirinhas
rm -rf paginas
rm -rf grupos
rm -rf pdf

mkdir {tirinhas,paginas,pdf,grupos}

for num in $(seq  1 999)
do
	tirinha=$(lynx --nolist -dump ${url}/index${num}.html | sed '/^$/d;s/[[:blank:]]\+//;/\[tir/!d;s/[][]\+//g')
	arquivo=$(date +%Y%m%d%H%M%S).1

	wget -N -q -c ${url}/${tirinha} -O tirinhas/${arquivo}
	echo "... baixando imagem ${arquivo} que era ... ${tirinha}"
done

for tira in tirinhas/*; do file ${tira} | grep HTML && rm -rf ${tira}; done

find tirinhas/ -iname "*.1" > tirinhas/cruas.txt

while read cur in
do
	convert -resize 591x188! ${cur} ${cur}.2
	sleep 1

	convert ${cur}.2 -mattecolor white -frame 50x20-0-0 ${cur}.3
	sleep 1

	echo "... convertendo tirinha ${cur} e adicionando borda"

done < tirinhas/cruas.txt

ls -1 tirinhas/*.3 > tirinhas/todas.txt
echo "... separando tiras em grupos de 3 por pagina"

while [ -s "tirinhas/todas.txt" ]
do
	arquivo=$(date +%Y%m%d%H%M%S)
	sed '3q' tirinhas/todas.txt > grupos/${arquivo}.txt
	sed -i '1,3d' tirinhas/todas.txt
done

for monte in grupos/*
do
	for tira in "$(cat ${monte})"
	do
		echo "... criando pagina corrente ${tira} com copyright e salvando em PDF"
		arquivo=$(date +%Y%m%d%H%M%S)

		convert ${tira} -append paginas/${arquivo}.4
		sleep 1

		convert paginas/${arquivo}.4 -mattecolor white -frame 0x20-0-0 paginas/${arquivo}.5
		sleep 1

		convert paginas/${arquivo}.5 -fill white -box '#000000' -gravity North -annotate +0+0 '   MALVADOS   ' paginas/${arquivo}.6
		sleep 1

		convert paginas/${arquivo}.6 -gravity South -background White -splice 0x0 -draw "text 0,0 'Malvados é criação de André Dahmer. Todos os direitos reservados.'" paginas/${arquivo}.7
		sleep 1

		convert paginas/${arquivo}.8 -mattecolor white -frame 10x10+0+1 paginas/${arquivo}.pdf
		sleep 1

	done
done

livro_final=$(date +%Y%m%d).pdf
paginas=$(ls -1 paginas/*.pdf)

echo "... juntando todas as paginas em um PDF unico"
pdftk ${paginas} cat output pdf/${livro_final}

echo "... terminando de criar o arquivo livro_dos_malvados.pdf"
convert malvados_livro_capa.png pdf/malvados_livro_capa.pdf
convert malvados_livro_final.png pdf/malvados_livro_final.pdf

pdftk	pdf/malvados_livro_capa.pdf	\
	pdf/${livro_final}		\
	pdf/malvados_livro_final.pdf	\
	cat output pdf/livro_dos_malvados.pdf

rm -rf tirinhas
rm -rf paginas
rm -rf grupos

exit 0
