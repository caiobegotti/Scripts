#!/bin/bash
#
# caio1982@gmail.com (originally published at https://gist.github.com/935298)
# get latin definitions from wiktionary on your shell, accepts compounds and latin affixes: getlat 'word'

function getlat() { lynx -source --nolist http://en.wiktionary.org/wiki/${@//[[:space:]]/_} | sed '/<h2>.*Latin/,/<h2>/!d;/<h2>/d' | lynx -width=160 -assume-charset=UTF-8 -stdin -dump --nolist | sed 's/\[edit\] //;s/_//g;/Retrieved/,//d'; }

getlat "${1}"

exit 0
