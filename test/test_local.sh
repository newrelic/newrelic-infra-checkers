#!/usr/bin/env bash

set -o errexit

for file in test/data/*
do
    RESULT=$(diff  "./."$(basename $file) $file) || true
    if [[ $RESULT = "" ]]; then
        echo "✅ The generated file $(basename $file) is as expected"
    else
        echo "❌ The generated file $(basename $file) is not as expected"
    fi
done