#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Populate defaults
[[ -n $GITHUB_ACTION_PATH ]] || GITHUB_ACTION_PATH=$(pwd)

if [[ -f ".semgrep.yml" ]]
then
  echo "ℹ️ Copying .semgrep.yml file to repo root directory"
  cp "$GITHUB_ACTION_PATH"/semgrep/semgrep.yml .semgrep.yml
else
  echo "ℹ️ Local .semgrep.yml file detected skipping overwrite"
fi

if [[ -f ".semgrepignore" ]]
then
  echo "ℹ️ Copying .semgrepignore file to repo root directory"
  cp "$GITHUB_ACTION_PATH"/semgrep/.semgrepignore .semgrepignore
else
  echo "ℹ️ Local .semgrepignore file detected skipping overwrite"
fi

if [[ -f ".golangci.yml" ]]
then
  echo "ℹ️ Copying .golangci.yml file to repo root directory"
  cp "$GITHUB_ACTION_PATH"/golangci-lint/.golangci.yml .golangci.yml
else
  echo "ℹ️ Local .golangci.yml file detected skipping overwrite"
fi
