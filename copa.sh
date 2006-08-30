#!/bin/bash
#
# script pra salvar videos de cada partida da copa 2006 na alemanha
# os videos sao streams gratuitos, entao ta beleza salva-los :)
#
# todos eles estao na melhor resolucao disponivel de graca
#
# caio1982 <caio@ueberalles.net> <http://caio.ueberalles.net>
# copyright (c) 2006 caio begotti on Sun, 18 Jun 2006 02:31:48 -0300

dcop=$(which dcop)           || echo 'DCOP não encontrado, instale o pacote "kdelibs-bin"!'
lynx=$(which lynx)           || echo 'Browser texto lynx não encontrado, instale o pacote "lynx"!'
konqueror=$(which konqueror) || echo 'Konqueror não encontrado, instale o pacote "konqueror"!'
mplayer=$(which mplayer)     || echo 'MPlayer não encontrado, instale o pacote "mplayer-nogui"!'

if [ -e ${dcop} -a -e ${lynx} -a -e ${mplayer} -a -e ${konqueror} ]
then
	echo -e "\n-------------------------------------------------------------------------------"
	echo -e "Todos os programas necessários para baixar os streamings foram encontrados"
	echo -e "-------------------------------------------------------------------------------"
	sleep 2s
else
	exit 1
fi

if [ -z ${1} ]
then
	loop="50" # acho que vai dar isso de paginas de videos ate o fim da copa
else
	loop="${1}"
fi

clear

while [ ${loop} -ge "0" -a ! -z ${loop} ]
do
	echo -e "\n-------------------------------------------------------------------------------"
	echo -e "Buscando listagem de dados dos vídeos públicos, página ${loop}"
	echo -e "-------------------------------------------------------------------------------"

	if [ ${loop} = "0" ]
	then
		export loop=""
	fi

	# dados pra baixar os videos (salva lista de cada video listado em cada pagina diaria)
	streaming_source="${lynx} -dump http://copa.esporte.uol.com.br/copa/2006/tv/ultnot/jogos/index${loop}.jhtm"
	${streaming_source} | sed '/[0-9]\. /!d;/ultnot\/jogos/!d;s/^.* http:\/\///g' > /tmp/urls
	
	if [ -s /tmp/urls ]
	then
		while read video_url
		do
			# pega um ambiente limpo de URLs
			rm -rf /tmp/kde-${USER}/konqueror*.tmp

			# se nao tiver um konqueror rodando, inicia um
			${dcop} | grep konqueror &> /dev/null || ${konqueror} & &> /dev/null
			sleep 10s

			# pega um konqueror ja aberto
			konqi=$(${dcop} konqueror-* | tail -n1)
	
			# abre uma nova URL com o streaming pra conectar
			${dcop} ${konqi} konqueror-mainwindow#1 openURL "${video_url}"
			${dcop} ${konqi} konqueror-mainwindow#1 minimize
			sleep 10s

			# que feiura...
			killall -9 drkonqi &> /dev/null
			killall -9 kio_uiserver &> /dev/null

			echo -e "\n-------------------------------------------------------------------------------"
			echo -e "Monitorando por dados do streaming para iniciar parsing"
			echo -e "-------------------------------------------------------------------------------\n"

			while true
			do
				# yay, chegou algum dado
				if grep "copa2006/2006" /tmp/kde-${USER}/konqueror*.tmp &> /dev/null
				then
					# beleza, da pra fazer parsing
					if [ -e /tmp/kde-${USER}/konqueror*.tmp ]
					then
						# xunxa dados do streaming e bota filename em variavel
						mv /tmp/kde-${USER}/konqueror*.tmp /tmp/control
						movie=$(sed '/.wmv?/!d;s/^.* \"//;s/\".*$//;s/_be/_bl/' /tmp/control)

						# libera o konqi pra nao carregar o xine pro streaming
						${dcop} ${konqi} konqueror-mainwindow#1 openURL "about:blank"
						${dcop} ${konqi} konqueror-mainwindow#1 minimize

						# nominhos bonitos pra salvar tudo em disco
						video_name=$(echo ${movie} | sed 's/^.*copa2006\///;s/\?.*$//;s/^.\{9\}//;s/_bl//')
						video_dir=$(echo ${video_name} | sed 's/[0-9]\{8\}_//;s/_[0-9]\{2\}.*$//;s/_[Xx]\?/_vs_/;s/__/_/')
				
						# se nao existir, cria diretorio de cada partida
						test -d ${video_dir} || mkdir -p $(dirname $0)/${video_dir}
						video_path="${video_dir}/${video_name}"
		
						# faz dump do stream se ja nao for um video normal
						# pode dar pau o dump, entao rodar isso 2x nao tem problema
						if ! file ${video_path} | grep ASF
						then
							echo -e "\n-------------------------------------------------------------------------------"
							echo -e "Salvando streaming como ${video_name}"
							echo -e "-------------------------------------------------------------------------------\n"
							${mplayer} -dumpvideo -dumpaudio -dumpstream -dumpfile "${video_path}" "${movie}" &>/dev/null
						fi
					fi

					break 1
				fi
			done
		done < /tmp/urls
	fi

	# ate a proxima pagina de videos
	let "loop=loop-1"
done

quantidade=$(find . -type f -iname '*.wmv' | wc -l)
tamanho=$(du -hsc $(find . -type f | grep '.wmv' ) | tail -n1 | sed 's/\t.*$//')

echo -e "\n-------------------------------------------------------------------------------"
echo -e "Download finalizado: ${quantidade} vídeos gravados em ${tamanho}"
echo -e "-------------------------------------------------------------------------------\n"

find . -mindepth 1 -type d | while read dir; do echo "partida ${dir:2} tem $(ls ${dir}/*.wmv | wc -l)/12 videos"; done | sort

beep=0
while [ ${beep} -le 4 ]
do
	echo -e \\a && sleep 1
	let "beep=beep+1"
done

exit 0
