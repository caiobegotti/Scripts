#!/bin/bash

ano=$(date +%Y); while [ $ano -ge 2000 ]; do mes=12; while [ $mes -gt 01 ]; do dia=31; while [ $dia -ge 01 ]; do test $mes -ge 10 && mesx=$mes || mesx=0${mes}; test $dia -ge 10 && diax=$dia || diax=0${dia} ; echo ${diax}${mesx}${ano} && let dia-- ; done && let mes-- ; done && let ano-- ; done | tac | while read i; do wget -c --timeout=60 --tries=6 http://www1.folha.uol.com.br/fsp/images/cp${i}.jpg; done

exit 0
