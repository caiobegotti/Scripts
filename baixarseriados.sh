#!/bin/bash
#
# script que baixa legendas e seriados populares via torrent automagicamente
# caio begotti <caio@ueberalles.net> on Tue, 30 Jan 2007 14:57:51 +0000
#
# 1. logar no site
#
# 2. fazer busca do seriado
#    e filtrar num. de downloads
#
# 3. parsear pra pegar o filename
#    dados e informacoes
#
# 4. busca do filename
#    google, piratebay, torrentspy
#
# 5. baixar o .torrent
#
# 6. renomear arquivos
#
# E o OpenSubtitles.org?

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
    wget -q --keep-session-cookies --save-cookies ${bolachinhas} --post-data="txtLogin=${login_name}&txtSenha=${login_pass}" http://legendas.tv/login_verificar.php -O /dev/null
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
        wget -q --load-cookies ${bolachinhas} --post-data="txtLegenda=${subtitle}&int_idioma=1" "http://legendas.tv/index.php?row=${paging}&opcao=buscarlegenda" -O ${search_res}

        # limpa a sujeirada que voltou da pesquisa meio que por cima somente...
        grep -i 'gold\|prata\|bronze' ${search_res} | sed "s/^.*alt='//g;s/<[^>]*>//g" | cut -d"'" -f1 | sed 's/[ /].*$//g' | sort -n | uniq > ${search_res}
        cp ${search_res} ${search_res}.${paging}
    done
    
    # concatena todas as paginas em uma soh
    cat ${search_res}.* | uniq | sort -n > ${search_res}
    
    do_cry "Processando os videos encontrados abaixo:\n"
    do_cry "$(cat ${search_res})\n"
}

function do_fetch()
{
    while read current
    do
        temp=$(mktemp)

        # busca e ordena por numero de downloads o hit do torrent... pra baixar o mais "pop"
        do_cry "Buscando arquivos .torrent ${current} no site de indices..."
        lynx --nolist -source "http://www.snarf-it.org/pages/search.html?category=0x0&query=${current}&orderBy=3&orderByDir=1" > ${temp}
        
        # filtra a URL do torrent do site Snarf-It.org e baixa o bendito arquivo
        do_cry "Filtrando os melhores arquivos .torrent pra baixar..."
        url=$(sed '/pigbox-small-container"/,/Blog Posts/!d;/list-name-row/!d;s/^.*viewTorrent//g;s/html".*$//;s/$/torrent/;s/^/www.snarf-it.org\/downloadTorrent/' ${temp} | head -1)
        
        if [ -z ${url} ]
        then
            do_cry 'Opa, opa! O endereco pra download estava vazio...\n'
        else
            do_cry "Baixando o .torrent do video ${current}\n"
            wget -q ${url} -O "${current}"
        fi

    done < ${search_res}
}

clear

do_login
do_search
do_fetch

exit 0
