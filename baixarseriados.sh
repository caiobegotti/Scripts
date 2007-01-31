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
    grep -i 'gold\|bronze' ${search_res} | sed "s/^.*alt='//g;s/<[^>]*>//g" | cut -d"'" -f1 | sed 's/[ /].*$//g' | sort -n | uniq > ${search_res}.new

}

do_login
do_search

exit 0
