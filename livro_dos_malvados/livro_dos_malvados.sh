#!/bin/bash
#
# Tue, 29 Aug 2006 20:16:44 -0300
# caio begotti <caio@ueberalles.net>

for num in $(seq 1 999)
do
	lynx --nolist -dump http://www.malvados.com.br/index${num}.html | sed '/^$/d;s/[[:blank:]]\+//;/\[tir/!d;s/[][]\+//g'
done

exit 0

# 1. baixa lista de tirinhas do site (nomes variam)
# 2. baixa as tirinhas possiveis do site
# 3. pega informacoes de todas as tirinhas
# 4. deixa todas as tirinhas com o mesmo tamanho
# 5. cria lista de tirinhas e separa em grupos de 5
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

# pegar a data de modificacao (criacao) do arquivo
stat tirinha300.gif | sed '/[Mm]odify/!d;s/^.\{8\}//;s/ .*$//'
