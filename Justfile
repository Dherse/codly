root := justfile_directory()

# Set the shell on Windows to using PowerShell.
set windows-shell := ["powershell.exe", "-c"]

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# run the complete suite, including diagnostics, PDF/UA, and package checks
test:
	python3 tests/run.py

# run selected rendering/assertion tests quickly
test-focused *args:
	tt run --no-fail-fast --font-path ./fonts {{ args }}

# compile fixtures with the installed Typst CLI (including minimum-version CI)
test-compat:
	python3 tests/run.py --compile-only

# build and smoke-test a temporary release artifact
package-check:
	python3 tests/tooling.py

# render the curated README gallery
examples:
	python3 scripts/examples.py

# verify that gallery sources and committed PNGs agree
examples-check:
	python3 scripts/examples.py --check

# update test cases
update *args:
	tt update --font-path ./fonts {{ args }}

# format Typst library, tests, and documentation sources
fmt:
	typstyle --inplace --line-width 100 --indent-width 2 --no-reorder-import-items codly.typ src tests examples

# verify Typst formatting without changing files
fmt-check:
	typstyle --check --line-width 100 --indent-width 2 --no-reorder-import-items codly.typ src tests examples

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

# Benchmark codly
bench-release *args:
	python3 scripts/benchmark.py {{ args }}

# Legacy benchmarks (requires crityp)
bench *args:
	crityp bench/test-codly-12/main.typ --bench-output .
	crityp bench/test-codly-main/main.typ --root . --bench-output .

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: fmt-check test
