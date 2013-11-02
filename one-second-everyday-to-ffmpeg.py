#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# this file is under public domain <caio1982@gmail.com>
# ffmpeg + manual processing of videos from iPhone's app 1SE
#
# reference:
# special case for the damn 1SE app on iphone
# which does not offer an option to disable overlays
# nor change the date format, nor hide its logos
# mencoder -forceidx -ovc copy -oac pcm $(rtw-one-second-video-list | sort | cut -d: -f2) -o /tmp/foo.mov
# function rtw-one-second-video-list() {
#	originallist=STORED_ONE_SECOND_VIDEOS_ARRAY_FILE_PATH_1364504029_1364504029
#	indexlist=/tmp/${originallist}.plist
#	pathslist=/tmp/${originallist}.paths
#	dateslist=/tmp/${originallist}.dates
#	test -e ${originallist} || echo 'stored_one_second_videos_array_file_path 404'
#	cp ${originallist} ${indexlist}
#	plutil -i ${indexlist} -o ${indexlist}.txt
#	sed '/<string>2013-/!d;s/^.*>2013/2013/g;s/<.*$//g' ${indexlist}.txt > ${dateslist}
#	sed '/<string>file:\/\/localhost/!d;s/^.*Documents\///g;s/<\/string>//g' ${indexlist}.txt > ${pathslist}
#	paste -d: ${dateslist} ${pathslist} | sort
# }
