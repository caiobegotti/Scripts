#!/bin/bash -ev
#
# Tue, 29 Aug 2006 20:16:44 -0300
# caio begotti <caio@ueberalles.net>
#
# tamanhos de papel pra posicionamento das tirinhas
# http://upload.wikimedia.org/wikipedia/commons/b/b8/A_size_illustration.gif
# livro do calvin e hobbes tem 830 de largura por 870 de altura

url=http://www.malvados.com.br

rm -rf tirinhas/* 
rm -rf paginas/* 
rm -rf pdf/* 
rm -rf temp/* 
rm -rf grupos/*

for num in $(seq 1 999)
do
	tirinha=$(lynx --nolist -dump ${url}/index${num}.html | sed '/^$/d;s/[[:blank:]]\+//;/\[tir/!d;s/[][]\+//g')
	# arquivo=$(echo ${tirinha} | sed 's/tiramalvados/tirinha/;s/tirainicial/tirinha1/;s/tirinhar/tirinha/')

	arquivo=$(date +%Y%m%d%H%M%S).foo
	wget -N -q -c ${url}/${tirinha} -O tirinhas/${arquivo}
	echo "... baixando imagem ${arquivo} que era ... ${tirinha}"
done

for tira in tirinhas/*; do file ${tira} | grep HTML && rm -rf ${tira}; done

find tirinhas/ -iname "*.foo" > tirinhas/cruas.txt

while read cur in
do
	convert -resize 591x188! ${cur} ${cur}.ok
	sleep 1

	convert ${cur}.ok -mattecolor white -frame 50x20-0-0 ${cur}.png
	sleep 1

done < tirinhas/cruas.txt

ls -1 tirinhas/*.png > tirinhas/todas.txt

while [ -s "tirinhas/todas.txt" ]
do
	sed '3q' tirinhas/todas.txt > grupos/$(echo $((RANDOM))).txt
	sed -i '1,3d' tirinhas/todas.txt
done

for monte in grupos/*
do
	for tira in "$(cat ${monte})"
	do
		arquivo=$(echo $((RANDOM)))

		convert ${tira} -append paginas/${arquivo}.tudo
		sleep 1

		convert paginas/${arquivo}.tudo -mattecolor white -frame 0x20-0-0 paginas/${arquivo}.page
		sleep 1

		convert paginas/${arquivo}.page -fill white -box '#000000' -gravity North -annotate +0+0 '   MALVADOS   ' paginas/${arquivo}.copy
		sleep 1

		convert paginas/${arquivo}.copy -gravity South -background White -splice 0x0 -draw "text 0,0 'Malvados é criação de André Dahmer. Todos os direitos reservados.'" paginas/${arquivo}.borda
		sleep 1

		convert paginas/${arquivo}.borda -mattecolor white -frame 10x10+0+1 paginas/${arquivo}.pdf
		sleep 1

	done
done

pdftk paginas/*.pdf cat output pdf/$(date +%Y%m%d).pdf

exit 0

# tamanho das tirinhas: 591 x 188, formato .png

# 1. baixa lista de tirinhas do site (nomes variam)	OK
# 2. baixa as tirinhas possiveis do site		OK
# 3. pega informacoes de todas as tirinhas		OK
# 4. deixa todas as tirinhas com o mesmo tamanho	OK
# 5. cria lista de tirinhas e separa em grupos de 5	OK
# 6. monta paginas inteiras cruas com as 5 tiras	OK
# 7. cria moldura delas com labels de (tm) e numero	OK
# 8. insere cada pagina em um folha do PDF
# 9. gerar o PDF final com capa, intro 

# pra botar borda branca na tira individual
convert input.gif -mattecolor white -frame 50x20-0-0 output.png

# juntar varias tiras em uma imagem
convert 1.png 2.png * -append malvados.jpg

# bota bordinha "style", soh pra dizer que tem
convert final.png -mattecolor white -frame 50x50+0+1 final.png

# adiciona pagina na parte de cima
convert 1.png -fill white -box '#000000' -gravity North -annotate +0+0 '   024   ' final.png

# botar copyright na pagina cheia de tirinhas
convert foo.png -gravity South -background White -splice 0x0 -draw "text 0,0 'Malvados é criação de André Dahmer. Todos os direitos reservados.'" final.png

# gera um pdf a partir do template HTML com paginas
pdftk *.pdf cat output caio.pdf
