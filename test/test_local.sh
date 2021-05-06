#!/usr/bin/env bash

set -o errexit

HAS_FAILED="false"

mkdir -p test/tmp

for file in test/data/*
do
    RESULT=$(diff  "./."$(basename $file) $file) || true
    if [ "$RESULT" == "" ]; then
        echo "✅ The generated file $(basename $file) is as expected"
    else
        echo "❌ The generated file $(basename $file) is not as expected"
        HAS_FAILED="true"
    fi

    # the yml files are copied to a tmp folder for yamllint action
    if [ "${file: -4}" == ".yml" ]
    then
        cp "./."$(basename $file) "test/tmp/."$(basename $file)
    fi
done

if [ "$HAS_FAILED" == "true" ]; then
  exit 1
fi
