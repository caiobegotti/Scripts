#!/bin/bash -xev
#
# Tue, 29 Aug 2006 20:16:44 -0300
# caio begotti <caio@ueberalles.net>

url=http://www.malvados.com.br

rm -rf tirinhas/* paginas/* pdf/* temp/* grupos/*

for num in $(seq 200 210)
do
	tirinha=$(lynx --nolist -dump ${url}/index${num}.html | sed '/^$/d;s/[[:blank:]]\+//;/\[tir/!d;s/[][]\+//g')
	# arquivo=$(echo ${tirinha} | sed 's/tiramalvados/tirinha/;s/tirainicial/tirinha1/;s/tirinhar/tirinha/')

	arquivo=$(date +%Y%m%d%H%M%S).raw
	wget -N -q -c ${url}/${tirinha} -O tirinhas/${arquivo}
	echo "... baixando imagem ${arquivo} que era ... ${tirinha}"
done

for tira in tirinhas/*; do file ${tira} | grep HTML && rm -rf ${tira}; done

find tirinhas/ -iname "*.raw" > tirinhas/cruas.txt

while read cur in
do
	convert -resize 591x188! ${cur} ${cur}.tmp
	convert ${cur}.tmp -mattecolor white -frame 50x20+1+1 $(echo ${cur} | sed 's/...$/png/')
done < tirinhas/cruas.txt

ls -1 tirinhas/*.png > tirinhas/todas.txt

while [ -s "tirinhas/todas.txt" ]
do
	sed '5q' tirinhas/todas.txt > grupos/$(echo $((RANDOM))).txt
	sed -i '1,5d' tirinhas/todas.txt
done

exit 0

# tamanho das tirinhas: 591 x 188, formato .png

# 1. baixa lista de tirinhas do site (nomes variam)	OK
# 2. baixa as tirinhas possiveis do site		OK
# 3. pega informacoes de todas as tirinhas		OK
# 4. deixa todas as tirinhas com o mesmo tamanho	OK
# 5. cria lista de tirinhas e separa em grupos de 5	OK
# 6. monta paginas inteiras cruas com as 5 tiras
# 7. cria moldura delas com labels de (tm) e numero
# 8. insere cada pagina em um folha do PDF
# 9. gerar o PDF final com capa, intro 

# pra botar borda branca na tira individual
convert input.gif -mattecolor white -frame 50x50+1+1 output.png

# juntar varias tiras em uma imagem
convert 1.jpg 2.jpg 3.jpg -append malvados.jpg

# botar legenda na pagina cheia de tirinhas
convert pagina.png -gravity North -background White -splice 0x18 -draw "text 0,0 'Malvados é criação de André Dahmer (www.malvados.com.br). Todos os direitos reservados ao autor original.'" final.png

# adicionar notas de copyright as paginas
montage -geometry +0+0 -background Black -fill white -label "- PÁGINA 7 -" final.png ok.png

# pegar tamanho das imagens no formato do imagemagick
identify tirinha300.gif | cut -d" " -f4
identify 20060830223050.raw | cut -d" " -f4 | sed 's/x.*$//'
identify 20060830223050.raw | cut -d" " -f4 | sed 's/^.*x//;s/+.*$//'

# pegar a data de modificacao (criacao) do arquivo
stat tirinha300.gif | sed '/[Mm]odify/!d;s/^.\{8\}//;s/ .*$//'

# pega o numero da tirinha (do arquivo real)
echo tirinha25.gif | sed 's/[[:alpha:]]\+//;s/....$//'
