#!/usr/bin/env bash

set -o errexit
set -o pipefail

. "./semgrep.sh"

# folderFile array follows the pattern folder:file
FOLDER_FILE=( "semgrep:.semgrep.yml"
              "semgrep:.semgrepignore"
              "golangci-lint:.golangci.yml" )
[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)

for folderFile in ${FOLDER_FILE[@]}
do
    folder="${folderFile%%:*}"
    file="${folderFile##*:}"
    if [[ ! -f "$file" ]]
    then
      echo "ℹ️ Copying $file file to repo root directory"
      cp "$GITHUB_ACTION_PATH/$folder/$file" "$file"
      [[ $file = ".semgrep.yml" ]] && semgrep_get_policies;
    else
      echo "ℹ️ Local $file file detected skipping overwrite"
    fi
done
