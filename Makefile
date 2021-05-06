SHELL := /bin/bash

# Determine files to test by lookng into test_data/*
TEST_FILES ?= $(wildcard ./test_data/*)

# Determine file basenames without the stripping out the dir names
BASENAMES := $(foreach file,${TEST_FILES},$(notdir ${file}))

test:
	@echo "=== $(INTEGRATION) === [ test ]: Running unit tests..."
	@sh ./test/test_local.sh

.PHONY: test

