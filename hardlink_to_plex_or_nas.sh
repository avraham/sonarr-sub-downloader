#!/bin/bash
echo "The script you are running has basename `basename "$0"`, dirname `dirname "$0"`"
echo "The present working directory is `pwd`"

nas_folder="/mnt/data/dietpi_userdata/nas"
plex_folder="/mnt/data/dietpi_userdata/plex"

declare MLOG_FILE=`dirname $0`/hardlink_to_plex_or_nas.log
declare PENDING_MOVIES_NAS_LOG_FILE="${nas_folder}/movies/_pending.log"
declare PENDING_TV_NAS_LOG_FILE="${nas_folder}/tvshows/_pending.log"
# declare MOVIE_TITLE="$1"

# Sonarr does not show the stdout as part of the log information displayed by the system,
# So I decided to store the log information by my own.
function doMLog {
  echo -e $1
  echo -e $1 >> $MLOG_FILE
}

doMLog "###### Process started at: $(date) ######"


doMLog "source: $1"

filename_source=$(basename "$1")
filename_to_link="${filename_source%.*}"
media_dir="$(dirname "$1")"

doMLog "filename_source: ${filename_source}"
doMLog "filename_to_link: ${filename_to_link}"

# sonarr_completed_dir="/mnt/data/dietpi_userdata/downloads"
# plex_folder="/mnt/data/dietpi_userdata/plex"
current_dir=$(pwd)
doMLog "current_dir: ${current_dir}"

copying_to_nas=false
copying_to_both=false

plex_movies_dir=""
plex_series_dir=""
nas_movies_dir=""
nas_series_dir=""

#check if we need to hardlink to plex folder or nas folder
if [[ $media_dir = *to_plex* ]]; then
  doMLog "we need to hardlink to plex folder"
  movies_dir="${plex_folder}/movies"
  series_dir="${plex_folder}/tvshows"
elif [[ $media_dir = *to_nas* ]]; then
  doMLog "we need to hardlink to nas folder"
  movies_dir="${nas_folder}/movies"
  series_dir="${nas_folder}/tvshows"
  copying_to_nas=true
else
  plex_movies_dir="${plex_folder}/movies"
  plex_series_dir="${plex_folder}/tvshows"
  nas_movies_dir="${nas_folder}/movies"
  nas_series_dir="${nas_folder}/tvshows"
  copying_to_both=true
  copying_to_nas=true
fi


doMLog "movies_dir: ${movies_dir}"
doMLog "series_dir: ${series_dir}"


media_dir_name="$(basename "$media_dir")"
media_dir_name_no_bs="$(basename "$media_dir" | sed -e 's/\\//g' )"
parentdir="$(dirname "$media_dir")"
parentdir_name="$(basename "$parentdir")"

doMLog "media_dir: ${media_dir}"
doMLog "media_dir_name_no_bs: ${media_dir_name_no_bs}"
doMLog "media_dir_name: ${media_dir_name}"
doMLog "parentdir: ${parentdir}"

if [ "$parentdir_name" == "movies" ]; then
  # it's a movie


  if [ "$copying_to_both" = true ] ; then

    doMLog "copying_to_both true"
    #create movie folder
    doMLog "try to create movie folder ${plex_movies_dir}/${media_dir_name}"
    mkdir -p  "${plex_movies_dir}/${media_dir_name}"

    doMLog "try to create movie folder ${nas_movies_dir}/${media_dir_name}"
    mkdir -p  "${nas_movies_dir}/${media_dir_name}"

    folder="$media_dir"
    doMLog "$folder"

    cd "$folder"

            f="${filename_to_link}"
            doMLog "try to hard link of ${filename_to_link}"
            ln "${media_dir}/${filename_source}" "${nas_movies_dir}/${media_dir_name}/${filename_source}"
            ln "${media_dir}/${f}.nfo" "${nas_movies_dir}/${media_dir_name}/${f}.nfo"
            ln "${media_dir}/poster.jpg" "${nas_movies_dir}/${media_dir_name}/poster.jpg"
            ln "${media_dir}/fanart.jpg" "${nas_movies_dir}/${media_dir_name}/fanart.jpg"

            ln "${media_dir}/${filename_source}" "${plex_movies_dir}/${media_dir_name}/${filename_source}"


            if [ -e "${media_dir}/.skip_subs" ]; then
              doMLog "skipping_subs"
            else
              ln "${media_dir}/${f}.srt" "${nas_movies_dir}/${media_dir_name}/${f}.srt"

              ln "${media_dir}/${f}.srt" "${plex_movies_dir}/${media_dir_name}/${f}.srt"
            fi

            if [ "$copying_to_nas" = true ] ; then
                echo $filename_source:$media_dir_name:$media_dir >> ${PENDING_MOVIES_NAS_LOG_FILE}
            fi


    cd $current_dir


  else
    #create movie folder
    doMLog "try to create movie folder ${movies_dir}/${media_dir_name}"
    mkdir -p  "${movies_dir}/${media_dir_name}"

    folder="$media_dir"
    doMLog "$folder"

    cd "$folder"

            f="${filename_to_link}"
            doMLog "try to hard link of ${filename_to_link}"
            ln "${media_dir}/${filename_source}" "${movies_dir}/${media_dir_name}/${filename_source}"
            ln "${media_dir}/${f}.nfo" "${movies_dir}/${media_dir_name}/${f}.nfo"
            ln "${media_dir}/poster.jpg" "${movies_dir}/${media_dir_name}/poster.jpg"
            ln "${media_dir}/fanart.jpg" "${movies_dir}/${media_dir_name}/fanart.jpg"

            if [ -e "${media_dir}/.skip_subs" ]; then
              doMLog "skipping_subs"
            else
              ln "${media_dir}/${f}.srt" "${movies_dir}/${media_dir_name}/${f}.srt"
            fi

            if [[ $media_dir = *to_nas_only* ]]; then
              doMLog "We are not keeping this movie here for many days."
              touch "${media_dir}/.nas_only"
            fi

            if [ "$copying_to_nas" = true ] ; then
                echo $filename_source:$media_dir_name:$media_dir >> ${PENDING_MOVIES_NAS_LOG_FILE}
            fi


    cd $current_dir

  fi



else
    # it's a serie
    season_dir_name="$(basename "$media_dir")"
    tvshow_dir="$(dirname "$media_dir")"
    tvshow_dir_name="$(basename "$parentdir")"

    doMLog "tvshow_dir: ${media_dir}"
    doMLog "tvshow_dir_name: ${tvshow_dir_name}"
    doMLog "season_dir_name: ${season_dir_name}"

    if [ "$copying_to_both" = true ] ; then

      doMLog "copying_to_both true"
      #create serie folder
      doMLog "try to create tvshow folder ${plex_series_dir}/${tvshow_dir_name}"
      doMLog "try to create season folder ${plex_series_dir}/${tvshow_dir_name}/${season_dir_name}"
      mkdir -p  "${plex_series_dir}/${tvshow_dir_name}"
      mkdir -p  "${plex_series_dir}/${tvshow_dir_name}/${season_dir_name}"

      doMLog "try to create tvshow folder ${nas_series_dir}/${tvshow_dir_name}"
      doMLog "try to create season folder ${nas_series_dir}/${tvshow_dir_name}/${season_dir_name}"
      mkdir -p  "${nas_series_dir}/${tvshow_dir_name}"
      mkdir -p  "${nas_series_dir}/${tvshow_dir_name}/${season_dir_name}"

      folder="$media_dir"
      doMLog "$folder"

      cd "$folder"

              f="${filename_to_link}"
              doMLog "try to hard link of ${filename_to_link}"

              ln "${parentdir}/${media_dir_name}/${filename_source}" "${plex_series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_source}"

              ln "${parentdir}/${media_dir_name}/${filename_source}" "${nas_series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_source}"

              if [ -e "${media_dir}/.skip_subs" ]; then
                doMLog "skipping_subs"
              else
                ln "${parentdir}/${media_dir_name}/${f}.srt" "${plex_series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.srt"
                ln "${parentdir}/${media_dir_name}/${f}.srt" "${nas_series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.srt"
              fi

              if [ "$copying_to_nas" = true ] ; then
                  echo $filename_source:$tvshow_dir_name:$season_dir_name:$media_dir >> ${PENDING_TV_NAS_LOG_FILE}
              fi


      cd $current_dir
    else



      #create serie folder
      doMLog "try to create tvshow folder ${series_dir}/${tvshow_dir_name}"
      doMLog "try to create season folder ${series_dir}/${tvshow_dir_name}/${season_dir_name}"
      mkdir -p  "${series_dir}/${tvshow_dir_name}"
      mkdir -p  "${series_dir}/${tvshow_dir_name}/${season_dir_name}"

      folder="$media_dir"
      doMLog "$folder"

      cd "$folder"

              f="${filename_to_link}"
              doMLog "try to hard link of ${filename_to_link}"

              ln "${parentdir}/${media_dir_name}/${filename_source}" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${filename_source}"
              if [ -e "${media_dir}/.skip_subs" ]; then
                doMLog "skipping_subs"
              else
                ln "${parentdir}/${media_dir_name}/${f}.srt" "${series_dir}/${tvshow_dir_name}/${season_dir_name}/${f}.srt"
              fi

              if [[ $media_dir = *to_nas_only* ]]; then
                doMLog "We are not keeping this tvshow here for many days."
                touch "${parentdir}/${media_dir_name}/.nas_only"
              fi

              if [ "$copying_to_nas" = true ] ; then
                  echo $filename_source:$tvshow_dir_name:$season_dir_name:$media_dir >> ${PENDING_TV_NAS_LOG_FILE}
              fi


      cd $current_dir
    fi
fi
