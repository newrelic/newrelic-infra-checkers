#!/usr/bin/env bash

set -o errexit
set -o pipefail

[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)
[[ -n $SEMGREP_APPEND ]] || SEMGREP_APPEND="true"
[[ -n $GOLANGCI_LINT_LIMITED ]] || GOLANGCI_LINT_LIMITED="true"

golangci_lint_folder="golangci-lint"
if [[ $GOLANGCI_LINT_LIMITED == "true" ]]
then
    golangci_lint_folder="golangci-lint-limited"
fi
echo "Using $golangci_lint_folder golangci-lint configuration folder"

find $GITHUB_ACTION_PATH/$golangci_lint_folder  -type f | while read -r file
do
  fileBasename=$(basename $file)

  if [[ ! -f "$fileBasename" ]]
  then
      echo "ℹ️ Copying $fileBasename file to repo root directory"
      cp "$file" "$fileBasename"
  else
      echo "ℹ️ Local $fileBasename file detected skipping overwrite"
  fi
done

find $GITHUB_ACTION_PATH/semgrep -type f | while read -r file
do
    fileBasename=$(basename $file)

    if [[ $SEMGREP_APPEND == "true" && $fileBasename = ".semgrep.yml" && -f "$fileBasename" ]]
    then
      mv $fileBasename{,.bak}
    fi

    if [[ ! -f "$fileBasename" ]]
    then
      echo "ℹ️ Copying $fileBasename file to repo root directory"
      cp "$file" "$fileBasename"
      if [[ $fileBasename == ".semgrep.yml" ]]; then
        . "$GITHUB_ACTION_PATH/semgrep.sh" && semgrep_get_policies;
      fi
    else
      echo "ℹ️ Local $fileBasename file detected skipping overwrite"
    fi
done

echo "ℹ️ Configuration files correctly copied"
