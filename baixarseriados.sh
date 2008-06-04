#!/bin/bash
#
# script que baixa legendas e seriados populares via torrent automagicamente
# caio begotti <caio@ueberalles.net> on Tue, 30 Jan 2007 14:57:51 +0000
#
# TODO: e quando estourar o limite diario do snarf-it? e o opensubtitles.org?

login_name="${1}"
login_pass="${2}"
subtitle="${3}"

bolachinhas=$(mktemp)

function do_cry()
{
    echo -e "${1}"
}

function do_login()
{
    do_cry "Logando no site de legendas e salvando as bolachinhas..."
    wget -q --keep-session-cookies --save-cookies ${bolachinhas} --post-data="txtLogin=${login_name}&txtSenha=${login_pass}&entrar.x=0&entrar.y=0" http://legendas.tv/login_verificar.php -O /dev/null
}

function do_sub_get()
{
    data="${1}"
    list="${2}"

    # sanity check
    sed -i 's/[[:cntrl:]]//g' ${list}

    do_cry "Fazendo o download de todas as legendas compactadas..."
    
    while read current
    do
        # pega o ID numerico da legenda para baixa-la
        id=$(grep ${current} ${data} | sed "s/^.*abredown(//;s/)/\n/g;s/'//g" | head -1)
        # baixa o .zip ou .rar ou whatever...
        echo wget --load-cookies ${bolachinhas} "http://legendas.tv/info.php?d=${id}&c=1" -O "${current}".pack
        wget --load-cookies ${bolachinhas} "http://legendas.tv/info.php?d=${id}&c=1" -O "${current}".pack

    done < ${list}
}

function do_sub_extract()
{
    do_cry "Descompactando as legendas baixadas...\n"

    for file in *.pack
    do
        if file ${file} | grep -iq 'rar archive'
        then
            # pega soh a legenda, exclui o resto e renomeia
            sub=$(unrar l ${file} | sed '/.srt/!d;s/  .*$//g;s/^ \+//g')
            unrar -x ${file} "${sub}" &> /dev/null && rm -rf ${file}
            mv -fu "${sub}" $(echo ${file} | sed 's/.pack$//').srt &>/dev/null
        else
            # pega soh a legenda, exclui o resto e renomeia
            sub=$(unzip -l ${file} |  sed '/.srt$/!d;s/^.*  //;s/^ \+//g')
            unzip -o ${file} "${sub}" &> /dev/null && rm -rf ${file}
            mv -fu "${sub}" $(echo ${file} | sed 's/.pack$//').srt &> /dev/null
        fi
    done
}

function do_search()
{
    search_res=$(mktemp)

    do_cry "Pesquisando titulos mais novos e populares de '${subtitle}'..."

    # como resultados bons pode ter sido paginados...
    # vamos aumentar a lista deles
    for paging in $(seq 0 4)
    do
        # baixa uma pagina de resultados pra filtrar
	wget -q --load-cookies ${bolachinhas} --post-data="txtLegenda=${subtitle}&selTipo=1&int_idioma=1&btn_buscar.x=32&btn_buscar.y=5" "http://legendas.tv/index.php?opcao=buscarlegenda&row=${paging}" -O ${search_res}.${paging}

        # limpa a sujeirada que voltou da pesquisa meio que por cima somente...
        grep -C 6 -i 'gold\|prata\|bronze' ${search_res}.${paging} | sed "s/^.*alt='//g;s/<[^>]*>//g" | sed '/[Rr]elease:/!d;s/^.*: //g' | sort -u > ${search_res}.${paging}.raw
    done
    
    # concatena todas as paginas em uma soh
    cat ${search_res}*.raw | sort -u | sort -n > ${search_res}
    cat ${search_res}.[0-4] > ${search_res}.raw
    
    do_cry "Processando os videos encontrados abaixo:\n"
    do_cry "$(cat ${search_res})\n"

    # naturalmente, a funcao que baixa tudo...
    do_sub_get "${search_res}.raw" "${search_res}"
}

function do_fetch()
{
    while read current
    do
        temp=$(mktemp)

        # busca e ordena por numero de downloads o hit do torrent... pra baixar o mais "pop"
        do_cry "Buscando arquivos .torrent ${current} no site de indices..."
        lynx --nolist -source "http://thepiratebay.org/search/${current}/0/99/0" > ${temp}
        
        # filtra a URL do torrent do site The Pirate Bay e baixa o bendito arquivo
        do_cry "Filtrando os melhores arquivos .torrent pra baixar..."
        url=http://thepiratebay.org/tor/$(sed '/href="\/tor\//!d;s/" class.*$//;s/^.*\/tor\///' /root/tmp/tmp.HYNEK29637 ${temp} | head -1)
        
        if [ -z ${url} ]
        then
            do_cry 'Opa, opa! O endereco pra download estava vazio...\n'
        else
	    lynx --nolist -source ${url} > ${temp}
	    remotefile=$(sed '/torrents.thepiratebay.org.*.TPB.torrent/!d;s/^.*http:\/\///;s/".*$//' ${temp} | head -1)
	
            do_cry "Baixando o .torrent do video ${current}\n"
            wget -q ${remotefile} -O "${current}.torrent"
        fi

    done < ${search_res}
}

clear

do_login
do_search
do_fetch
do_sub_extract

exit 0
