#!/usr/bin/env bash

set -o errexit
set -o pipefail

BCK_SEMGREP_FILE=".semgrep-bck.yml"

. "./semgrep.sh"

[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)
[[ -n $SEMGREP_APPEND ]] || SEMGREP_APPEND="false"

# List of folders where to look for config files
for file in {semgrep,golangci-lint}/.[^.]*
do
    fileBasename=$(basename $file)

    if [[ $SEMGREP_APPEND == "true" && $fileBasename = ".semgrep.yml" && -f "$file" ]]
    then
      mv ".semgrep.yml" $BCK_SEMGREP_FILE
    fi

    if [[ ! -f "$fileBasename" ]]
    then
      echo "ℹ️ Copying $fileBasename file to repo root directory"
      cp "$GITHUB_ACTION_PATH/$file" "$fileBasename"
      [[ $fileBasename = ".semgrep.yml" ]] && semgrep_get_policies;
    else
      echo "ℹ️ Local $fileBasename file detected skipping overwrite"
    fi
done

echo "ℹ️ Configuration files correctly copied"
