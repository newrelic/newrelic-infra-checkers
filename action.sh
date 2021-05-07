#!/usr/bin/env bash

set -o errexit
set -o pipefail

[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)
[[ -n $SEMGREP_APPEND ]] || SEMGREP_APPEND="false"


find golangci-lint  -type f | while read -r file
do
  fileBasename=$(basename $file)

  if [[ ! -f "$fileBasename" ]]
  then
      echo "ℹ️ Copying $fileBasename file to repo root directory"
      cp "$GITHUB_ACTION_PATH/$file" "$fileBasename"
  else
      echo "ℹ️ Local $fileBasename file detected skipping overwrite"
  fi
done

find semgrep -type f | while read -r file
do
    fileBasename=$(basename $file)

    if [[ $SEMGREP_APPEND == "true" && $fileBasename = ".semgrep.yml" && -f "$fileBasename" ]]
    then
      mv $fileBasename{,.bak}
    fi

    if [[ ! -f "$fileBasename" ]]
    then
      echo "ℹ️ Copying $fileBasename file to repo root directory"
      echo "$GITHUB_ACTION_PATH/$file ## $fileBasename"
      cp "$GITHUB_ACTION_PATH/$file" "$fileBasename"
      echo "xx"
      [[ $fileBasename = ".semgrep.yml" ]] && . "./semgrep.sh" && semgrep_get_policies;
    else
      echo "ℹ️ Local $fileBasename file detected skipping overwrite"
    fi
done

echo "ℹ️ Configuration files correctly copied"
