#!/bin/bash -xev
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

login_name="${1}"
login_pass="${2}"
subtitle="${3}"

bolachinhas=$(mktemp)

function do_login()
{
    wget --keep-session-cookies --save-cookies ${bolachinhas} --post-data="txtLogin=${login_name}&txtSenha=${login_pass}" http://legendas.tv/login_verificar.php -O /dev/null
}

function do_search()
{
    search_res=$(mktemp)

    wget --load-cookies ${bolachinhas} --post-data="txtLegenda=${subtitle}&int_idioma=1" http://legendas.tv/index.php?opcao=buscarlegenda -O ${search_res}
    grep -i 'gold\|bronze' ${search_res} | sed "s/^.*alt='//g;s/<[^>]*>//g" | cut -d"'" -f1 | sed 's/[ /].*$//g' | sort -n | uniq > ${search_res}
    cat ${search_res}
}

function do_fetch()
{
    while read current
    do
        file=$(mktemp)

        download=$(lynx --nolist -dump "http://www.google.com/search?q=${current}&sourceid=mozilla&start=0&start=0&ie=utf-8&oe=utf-8" |  sed '/thepiratebay.org\/tor/!d;s/-.*$//g' | head -1)
        wget "$(echo ${download})" -O ${file}.html

        url=$(grep hashtorrent ${file}.html | head -1 | sed 's/^.*href="//g;s/".*$//g')
        wget ${url}

    done < ${search_res}
}

do_login
do_search
do_fetch

exit 0
