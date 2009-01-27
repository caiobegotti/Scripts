#!/bin/bash
# copyright caio begotti <caio1982@gmail.com>
# give it a try by using 'otorhinolaryngologist'
# or get my words file transcribed to IPA chars at
# http://caio.ueberalles.net/linux.words.phonetics

file=$(mktemp)
raw=$(lynx -source --nolist http://dictionary.reference.com/browse/${1} > ${file})
grep '<span class="prondelim">' ${file} | tidy -wrap 9999 -i -c -q -utf8 -b 2> /dev/null > ${file}
matches=$(cat ${file} | sed '/noscript/!d;s/<[^>]*>//g;s/\ //g' | sed 's/AudioHelp//g;s/PronunciationKey//g;s/ShowSpelledPronunciation//g;s/ShowIPAPronunciation//g' | cut -d/ -f2 | head -1)

echo ${matches}

exit 0
