#!/bin/bash -xev
#
# Tue, 29 Aug 2006 20:16:44 -0300
# caio begotti <caio@ueberalles.net>

for strip in $(seq 1 999)
do
	lynx -dump --nolist http://www.malvados.com.br/index${strip}.html | sed '/^$/d;/.gif\|.jpg/!d;/tir/!d;s/[][ ]\+//g'
done

exit 0

# pra botar borda branca na tira individual
convert input.gif -mattecolor white -frame 50x50+1+1 output.png

# juntar varias tiras em uma imagem
convert 1.jpg 2.jpg 3.jpg -append malvados.jpg

# botar legenda na pagina cheia de tirinhas
convert pagina.png -gravity North -background White -splice 0x18 -draw "text 0,0 'Malvados é criação de André Dahmer (www.malvados.com.br). Todos os direitos reservados ao autor original.'" final.png

# adicionar notas de copyright as paginas
montage -geometry +0+0 -background Black -fill white -label "- PÁGINA 7 -" final.png ok.png
