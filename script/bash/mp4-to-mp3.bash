#!/bin/bash
if [ -z "$1" ];then echo "Please give ARG1 as mp4 file name";exit 1;fi

out=$(echo $1 | awk -F".mp4" '{print $1}')
out="${out}.mp3"

ffmpeg -i "$1" -vn \
       -acodec libmp3lame -ac 2 -qscale:a 4 -ar 48000 \
        "$out"
