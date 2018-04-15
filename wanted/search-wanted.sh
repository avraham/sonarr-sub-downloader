#!/bin/bash

hardlink_to_plex_or_nas_folder="/Users/Avr/Downloads/sonarr-sub-downloader-0.4"
declare WANTED_FILE=`dirname $0`/subs.wanted



declare MISSED=""
echo "###### Process started at: $(date) ######"

while read -r line; do
  IFS=':'
  MAP_ARRAY=($(echo "$line"))
  SOURCE=${MAP_ARRAY[0]}
  SRT=${MAP_ARRAY[1]}
  LANG=`es-MX`
  # LANG=`echo $SRT | sed -e "s/\.srt//g" -e "s/.*\(..\)/\1/"`

  file_folder="$(dirname "${SOURCE}")"

  if [ -e "${file_folder}/.skip_subs" ]; then
    doLog "skipping subs for ${SOURCE} from search-wanted"
    doLog "hardlink_to_plex_or_nas.sh for ${SOURCE} from search-wanted"
    ${hardlink_to_plex_or_nas_folder}/hardlink_to_plex_or_nas.sh "${SOURCE}"

  else
    echo "subliminal download -l $LANG -p subdivx -s $SOURCE"
    subliminal download -l $LANG $SOURCE
    if [[ ! -f $SRT ]]; then
      IFS=''
      MISSED="$SOURCE:$SRT\n$MISSED"
      echo "Subtitle still not available"
    else
      echo "Great! we have found $SRT"
      doLog "Subtitle ${SUB_FILE} found!!!"
      doLog "hardlink_to_plex_or_nas.sh for ${SOURCE} from search-wanted"
      #call custom script to hardlink file and sub to plex folder
      ${hardlink_to_plex_or_nas_folder}/hardlink_to_plex_or_nas.sh "${SOURCE}"
    fi

  fi


done < "$WANTED_FILE"

echo "Saving not found subtitles"
echo -en $MISSED > $WANTED_FILE
