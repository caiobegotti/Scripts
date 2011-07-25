#!/bin/bash
#
# script que baixa todas as capas do jornal folha de sao paulo
# (fac similes publicos) desde 01 de janeiro de 2000 ate o dia atual
# copyright caio begotti <caio1982@gmail.com> on Mon,  9 Oct 2006 23:39:29 -0300
#
# TODO: eh capa pra caralho, seria bom fazer uma galeria decente com o llgal

ano=$(date +%Y); while [ $ano -ge 2000 ]; do mes=12; while [ $mes -gt 01 ]; do dia=31; while [ $dia -ge 01 ]; do test $mes -ge 10 && mesx=$mes || mesx=0${mes}; test $dia -ge 10 && diax=$dia || diax=0${dia} ; echo ${diax}${mesx}${ano} && let dia-- ; done && let mes-- ; done && let ano-- ; done | tail -r | while read i; do wget -c --timeout=60 --tries=6 http://www1.folha.uol.com.br/fsp/images/cp${i}.jpg; done

exit 0
