#!/usr/bin/env bash

set -o errexit

HAS_FAILED="false"

for file in test/data/*
do
    RESULT=$(diff  "./."$(basename $file) $file) || true
    if [ "$RESULT" == "" ]; then
        echo "✅ The generated file $(basename $file) is as expected"
    else
        echo "❌ The generated file $(basename $file) is not as expected"
        HAS_FAILED="true"
    fi
done

if [ "$HAS_FAILED" == "true" ]; then
  exit 1
fi
