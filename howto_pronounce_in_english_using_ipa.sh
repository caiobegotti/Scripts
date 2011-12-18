#!/bin/bash
# copyright caio begotti <caio1982@gmail.com>
# give it a try by using 'otorhinolaryngologist'
# or get my words file transcribed to IPA chars at
# http://caio.ueberalles.net/linux.words.phonetics

input=${1}
lynx -source --nolist http://dictionary.reference.com/browse/${input:=default} | grep '<span class="prondelim">' | tidy -wrap 9999 -i -c -q -utf8 -b 2> /dev/null | sed '/noscript/!d;s/<[^>]*>//g;s/\ //g' | sed 's/AudioHelp//g;s/PronunciationKey//g;s/ShowSpelledPronunciation//g;s/ShowIPAPronunciation//g' | cut -d/ -f2 | grep -i '[[:alnum:]]' | head -1

exit 0
