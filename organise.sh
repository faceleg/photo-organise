#!/bin/bash

usage() {
cat << EOF
usage: $0 options

OPTIONS:
  -t	the directory files should be moved TO
  -f	the directory files should be moved FROM
EOF
}

# http://stackoverflow.com/a/17076258/187954
function abs_path {
  (cd "$(dirname '$1')" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}

TO_DIRECTORY=
FROM_DIRECTORY=
while getopts "t:f:" OPTION
do
  case $OPTION in
    f)
      TO_DIRECTORY=$OPTARG
      ;;
    t)
      FROM_DIRECTORY=$OPTARG
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

exiftool -r -d "$TO_DIRECTORY/%Y/%Y-%m-%d/%Y-%m-%d_%H:%M:%S.%%e" "-filename<datetimeoriginal" "$FROM_DIRECTORY"
