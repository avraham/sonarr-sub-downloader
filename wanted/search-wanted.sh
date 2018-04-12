#!/bin/bash

declare WANTED_FILE=`dirname $0`/subs.wanted

hardlink_to_plex_folder="/Users/Avr/Downloads/sonarr-sub-downloader-0.4"

declare MISSED=""
echo "###### Process started at: $(date) ######"

while read -r line; do
  IFS=':'
  MAP_ARRAY=($(echo "$line"))
  SOURCE=${MAP_ARRAY[0]}
  SRT=${MAP_ARRAY[1]}
  LANG=`es-MX`
  # LANG=`echo $SRT | sed -e "s/\.srt//g" -e "s/.*\(..\)/\1/"`
  echo "subliminal download -l $LANG -p subdivx -s $SOURCE"
  subliminal download -l $LANG $SOURCE
  if [[ ! -f $SRT ]]; then
    IFS=''
    MISSED="$SOURCE:$SRT\n$MISSED"
    echo "Subtitle still not available"
  else
    echo "Great! we have found $SRT"
    doLog "Subtitle ${SUB_FILE} found!!!"
    doLog "Calling ./hardlink_to_plex.sh"
    #call custom script to hardlink file and sub to plex folder
    ${hardlink_to_plex_folder}/hardlink_to_plex.sh "${SOURCE}"
  fi
done < "$WANTED_FILE"

echo "Saving not found subtitles"
echo -en $MISSED > $WANTED_FILE
