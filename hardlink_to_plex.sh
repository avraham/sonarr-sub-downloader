#!/bin/bash
echo "The script you are running has basename `basename "$0"`, dirname `dirname "$0"`"
echo "The present working directory is `pwd`"

declare MLOG_FILE=`dirname $0`/hardlink_to_plex.log

# Sonarr does not show the stdout as part of the log information displayed by the system,
# So I decided to store the log information by my own.
function doMLog {
  echo -e $1
  echo -e $1 >> $MLOG_FILE
}

doMLog "###### Process started at: $(date) ######"

sonarr_completed_dir="/Users/Avr/Downloads/series"
plex_folder="/Users/Avr/plex"

# sonarr_completed_dir="/mnt/data/dietpi_userdata/downloads"
# plex_folder="/mnt/data/dietpi_userdata/plex"
current_dir=$(pwd)
doMLog "current_dir: ${current_dir}"

movies_dir="${plex_folder}/movies"
series_dir="${plex_folder}/tvshows"

doMLog "movies_dir: ${movies_dir}"
doMLog "series_dir: ${series_dir}"

media_dir="$(dirname "$1")"
media_dir_name="$(basename "$media_dir")"
media_dir_name_no_bs="$(basename "$media_dir" | sed -e 's/\\//g' )"
parentdir="$(dirname "$media_dir")"

doMLog "media_dir: ${media_dir}"
doMLog "media_dir_name_no_bs: ${media_dir_name_no_bs}"
doMLog "media_dir_name: ${media_dir_name}"
doMLog "parentdir: ${parentdir}"

if [ "$parentdir" == "${sonarr_completed_dir}/movies" ]; then
  # it's a movie

  #create movie folder
  doMLog "try to create movie folder ${movies_dir}/${media_dir_name}"
  mkdir -p  "${movies_dir}/${media_dir_name}"

  folder="$media_dir"
  doMLog "$folder"

  cd "$folder"

  if [ -e "${media_dir}/.skip_subs" ]; then
    doMLog "skipping_subs"
    for filename in ./*.mkv; do
      doMLog $filename
      filename_name=$(basename $filename)
      doMLog "filename_name: ${filename_name}"
      if [ -e "${movies_dir}/${media_dir_name}/${filename}" ]; then
          doMLog "hard link of $filename already exists"
      else
          f="${filename_name%.*}"
          doMLog "try to hard link of ${filename_name}"
          ln "${media_dir}/${f}.mkv" "${movies_dir}/${media_dir_name}/${f}.mkv"
      fi

    done

  else

    for filename in ./*.srt; do
      doMLog $filename
      filename_name=$(basename $filename)
      doMLog "filename_name: ${filename_name}"
      if [ -e "${movies_dir}/${media_dir_name}/${filename}" ]; then
          doMLog "hard link of $filename already exists"
      else
          f="${filename_name%.*}"
          doMLog "try to hard link of ${filename_name}"
          ln "${media_dir}/${f}.srt" "${movies_dir}/${media_dir_name}/${f}.srt"
          ln "${media_dir}/${f}.mkv" "${movies_dir}/${media_dir_name}/${f}.mkv"
      fi

    done
  fi

  cd $current_dir

else
    # it's a serie
    # season_dir_name="$(basename "$media_dir" | sed -e 's/\\//g' )"
    # tvshow_dir="$(dirname "$media_dir" | sed -e 's/\\//g' )"
    # tvshow_dir_name="$(basename "$parentdir" | sed -e 's/\\//g' )"

    season_dir_name="$(basename "$media_dir")"
    tvshow_dir="$(dirname "$media_dir")"
    tvshow_dir_name="$(basename "$parentdir")"

    doMLog "tvshow_dir: ${media_dir}"
    doMLog "tvshow_dir_name: ${tvshow_dir_name}"
    doMLog "season_dir_name: ${season_dir_name}"

    #create serie folder
    doMLog "try to create tvshow folder ${series_dir}/${tvshow_dir_name}"
    doMLog "try to create season folder ${series_dir}/${tvshow_dir_name}/${season_dir_name}"
    mkdir -p  "${series_dir}/${tvshow_dir_name}"
    mkdir -p  "${series_dir}/${tvshow_dir_name}/${season_dir_name}"

    folder="$media_dir"
    doMLog "$folder"

    cd "$folder"

    if [ -e "${media_dir}/.skip_subs" ]; then
      doMLog "skipping_subs"
      for filename in ./*.mkv; do
        doMLog $filename
        filename_name=$(basename $filename)
        doMLog "filename_name: ${filename_name}"
        if [ -e "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_name}" ]; then
            doMLog "hard link of ${filename_name} already exists"
        else
            f="${filename_name%.*}"
            doMLog "try to hard link of ${filename_name}"
            ln "${parentdir}/${media_dir_name}/${f}.mkv" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.mkv"
        fi

      done

    else

      for filename in ./*.srt; do
        doMLog $filename
        filename_name=$(basename $filename)
        doMLog "filename_name: ${filename_name}"
        if [ -e "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_name}" ]; then
            doMLog "hard link of ${filename_name} already exists"
        else
            f="${filename_name%.*}"
            doMLog "try to hard link of ${filename_name}"
            ln "${parentdir}/${media_dir_name}/${f}.srt" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.srt"
            ln "${parentdir}/${media_dir_name}/${f}.mkv" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.mkv"
            # ln "${parentdir}/${media_dir_name_no_bs}/${filename_name}" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_name}"
        fi

      done
    fi

    cd $current_dir

fi
