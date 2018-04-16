#!/bin/bash

usage() {
cat << EOF
usage: $0 options

OPTIONS:
  -t	the directory files should be moved TO
  -f	the directory files should be moved FROM
  -e the exiftool binary location (defaults to /usr/bin/exiftool)
EOF
}

# http://stackoverflow.com/a/17076258/187954
function abs_path {
  (cd "$(dirname '$1')" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}

TO_DIRECTORY=
FROM_DIRECTORY=
EXIFTOOL_BIN=
while getopts "t:f:" OPTION
do
  case $OPTION in
    t)
      TO_DIRECTORY=$OPTARG
      ;;
    f)
      FROM_DIRECTORY=$OPTARG
      ;;
    e)
      EXIFTOOL_BIN=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done
if [ -z $TO_DIRECTORY ]; then
  usage
  exit
fi
if [ -z $FROM_DIRECTORY ]; then
  usage
  exit
fi
if [ -z $EXIFTOOL_BIN ]; then
  EXIFTOOL_BIN=/usr/bin/exiftool
fi

# Verify arguments are directories, symlinks not allowed
FROM_DIRECTORY=$(abs_path $FROM_DIRECTORY)
if [[ ! -d "$FROM_DIRECTORY" || -L "$FROM_DIRECTORY" ]]; then
  echo "Invalid path (bad path or it is a symlink):"
  echo "$FROM_DIRECTORY"
  exit
fi
TO_DIRECTORY=$(abs_path $TO_DIRECTORY)
if [[ ! -d "$TO_DIRECTORY" || -L "$TO_DIRECTORY" ]]; then
  echo "Invalid path (bad path or it is a symlink):"
  echo "$TO_DIRECTORY"
  exit
fi

$EXIFTOOL_BIN -r \
  -d "$TO_DIRECTORY/%Y/%Y-%m-%d/%Y-%m-%d_%H-%M-%S%%c.%%e" \
  "-filename<datetimeoriginal" \
  "-filename<CreateDate" \
  "-filename<MediaCreateDate" \
  "-filename<FileCreateDate" \
  "$FROM_DIRECTORY"

