SHELL := /bin/bash

test-local:
	@echo "Running test with local files..."
	@bash ./test/test_local.sh

test-local-semgrep:
	@echo "Running test with local files and semgrep_append..."
	@bash ./test/test_local_semgrep.sh

test-default:
	@echo "[ test ]: Running test with no local files..."
	@bash ./test/test_default.sh

.PHONY: test-local test-local-semgrep test-default

