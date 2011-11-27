#!/bin/bash
#
# based on http://www.fabrizio-branca.de/lightroom-plugin-detect-blurry-images.html
# caio begotti <caio1982@gmail.com>

for f in ${@}; do
	exp_time=$(identify -format "%[EXIF:*]" ${f} | sed '/exif:ExposureTime=/!d;s/^.*=//')
	focal_len=$(identify -format "%[EXIF:*]" ${f} | sed '/exif:FocalLength=/!d;s/^.*=//')
	factor=$(echo "( ${exp_time} ) / ( 1 / ( ${focal_len} ) )" | bc -l)
	
	echo ${f}:${factor}
done

exit 0
