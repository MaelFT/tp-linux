#!/bin/bash

if [ -d "downloads/" ];
then
  video_name=$( youtube-dl ${1} -e | tr -s " " "-" )
  mkdir downloads/${video_name}
  youtube-dl -o downloads/${video_name}/${video_name} ${1} > /dev/null 2> /dev/null
  youtube-dl ${1} --get-description > downloads/${video_name}/description.txt
  echo "Video ${1} was downloaded."
  echo "File path : $( readlink -f downloads/${video_name}/${video_name} )"
  if [ -d "/var/log/yt/" ]
  then
    echo "[$( date '+%D %T' )] Video ${1} was downloaded. File path : $( readlink -f downloads/${video_name}/${video_name} )" >> /var/log/yt/download.log
  else
    exit
  fi
else
  exit
fi
