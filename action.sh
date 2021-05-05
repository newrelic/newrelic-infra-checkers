#!/usr/bin/env bash

set -o errexit
set -o pipefail

# folderFile array follows the pattern folder:file
folderFile=(  "semgrep:.semgrep.yml"
              "semgrep:.semgrepignore"
              "golangci-lint:.golangci.yml" )

# Populate defaults
[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)

for folderFile in ${folderFile[@]}
do
   :
    folder="${folderFile%%:*}"
    file="${folderFile##*:}"
    if [[ ! -f "$file" ]]
    then
      echo "ℹ️ Copying $file file to repo root directory"
      cp "$GITHUB_ACTION_PATH/$folder/$file" "$file"
    else
      echo "ℹ️ Local $file file detected skipping overwrite"
    fi
done
