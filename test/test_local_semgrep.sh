#!/usr/bin/env bash

set -o errexit

HAS_FAILED="false"

for file in test/data/*
do
    RESULT=$(diff  "./."$(basename $file) $file) || true
    if [ "$RESULT" == "" ]; then
        echo "✅ The generated file $(basename $file) is as expected"
    else
        if [ $(basename $file) != "semgrep.yml" ]; then
            echo "❌ The aagenerated file $(basename $file) is not as expected"
            HAS_FAILED="true"
        else
            EXISTS_LOCAL=$(cat "./."$(basename $file) | grep "invented-policy" | wc -l)
            if [ $EXISTS_LOCAL > 0 ]; then
                echo "✅ The generated file $(basename $file) is as expected"
            else
                echo "❌ The generated file $(basename $file) doesn't contain the local config"
                HAS_FAILED="true"
            fi
        fi
    fi
done

if [ "$HAS_FAILED" == "true" ]; then
  exit 1
fi
