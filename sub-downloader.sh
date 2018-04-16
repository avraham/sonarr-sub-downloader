#!/bin/bash
set -e
echo `dirname $0`
hardlink_to_plex_or_nas_folder="/mnt/data/dietpi_userdata/scripts/sub-downloader"
export PATH="$PATH:/usr/local/bin"

declare LOG_FILE=`dirname $0`/sub-downloader.log
declare WANTED_FILE=`dirname $0`/wanted/subs.wanted

# Sonarr does not show the stdout as part of the log information displayed by the system,
# So I decided to store the log information by my own.
function doLog {
  echo -e $1
  echo -e $1 >> $LOG_FILE
}

function printUsage {
  msg="Usage: sub-downloader.sh [options]\n\n
    -l, --languages <languages-list>:\n
    \t Specify a comma-separated list of languages to download.\n
    \t example: sub-downloader.sh -l es,en\n\n
    -h, --help: print this help"
  doLog "$msg"
  exit 1
}

if [[ $# -eq 0 ]]; then
  printUsage
fi

while [ "$1" != "" ]; do
  case $1 in
    "-l" | "--languages")
      shift
      declare LANGUAGES=$(echo "-l $1" | sed "s/,/ -l /g")
      ;;
    *)
      printUsage
      ;;
  esac
  shift
done


doLog "###### Process started at: $(date) ######"

declare EPISODE_PATH=${sonarr_episodefile_path}

if [[ -z $EPISODE_PATH ]]; then
  doLog "sonarr_episodefile_path environment variable not found"

  declare EPISODE_PATH=${radarr_moviefile_path}

  if [[ -z $EPISODE_PATH ]]; then
    doLog "radarr_episodefile_path environment variable not found"
    exit 1
  fi
fi

file_folder="$(dirname "${EPISODE_PATH}")"


if [ -e "${file_folder}/.skip_subs" ]; then
  doLog "skipping subs for ${EPISODE_PATH}"
  ${hardlink_to_plex_or_nas_folder}/hardlink_to_plex_or_nas.sh "${EPISODE_PATH}"
  exit 1
fi

doLog "PATH : ${PATH}"
doLog "Looking for subtitles for: ${EPISODE_PATH}"

doLog "Executing subliminal"
doLog "subliminal download ${LANGUAGES} -p subdivx -s ${EPISODE_PATH}"
subliminal download ${LANGUAGES} -p subdivx -a 23d -s "${EPISODE_PATH}" >> $LOG_FILE 2>&1

# Look for not found subtitles
declare LANG_ARRAY=($(echo ${LANGUAGES} | sed "s/-l //g"))

for LANG in "${LANG_ARRAY[@]}"; do
  SUB_FILE=$(echo $EPISODE_PATH | sed "s/...$/srt/g")
  if [[ ! -f $SUB_FILE ]]; then
    doLog "Subtitle ${SUB_FILE} not found, adding it to wanted"
    echo $EPISODE_PATH:$SUB_FILE:0 >> ${WANTED_FILE}
  else
    doLog "Subtitle ${SUB_FILE} found!!!"
    doLog "hardlink_to_plex_or_nas.sh for ${EPISODE_PATH} from sub-downloader"
    #call custom script to hardlink file and sub to plex folder
    ${hardlink_to_plex_or_nas_folder}/hardlink_to_plex_or_nas.sh "${EPISODE_PATH}"
  fi
done
