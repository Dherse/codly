root := justfile_directory()

# Use PowerShell on Windows.
set windows-shell := ["powershell.exe", "-c"]

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# Run rendering tests, diagnostics, PDF/UA checks, and package checks.
test:
	python3 tests/run.py

# Run selected rendering and assertion tests.
test-focused *args:
	tt run --no-fail-fast --font-path ./fonts {{ args }}

# Compile compatible fixtures with the installed Typst CLI.
test-compat:
	python3 tests/run.py --compile-only

# Build a temporary package and compile a smoke test against it.
package-check:
	python3 tests/tooling.py

# Render the README gallery.
examples:
	python3 scripts/examples.py

# Check that gallery PNGs match their sources.
examples-check:
	python3 scripts/examples.py --check

# Update test references.
update *args:
	tt update --font-path ./fonts {{ args }}

# Format Typst library, test, and example sources.
fmt:
	typstyle --inplace --line-width 100 --indent-width 2 --no-reorder-import-items codly.typ src tests examples

# Check Typst formatting.
fmt-check:
	typstyle --check --line-width 100 --indent-width 2 --no-reorder-import-items codly.typ src tests examples

# Package the library into the specified folder.
package target:
  ./scripts/package "{{target}}"

# Install the library with the "@local" prefix.
install: (package "@local")

# Install the library with the "@preview" prefix for pre-release testing.
install-preview: (package "@preview")

# Legacy benchmarks (requires crityp)
bench *args:
	crityp bench/test-codly-12/main.typ --bench-output .
	crityp bench/test-codly-main/main.typ --root . --bench-output .

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# Uninstall the library from the "@local" prefix.
uninstall: (remove "@local")

# Uninstall the library from the "@preview" prefix.
uninstall-preview: (remove "@preview")

# Run formatting and test checks.
ci: fmt-check test

docs-setup:
	just --justfile docs/justfile setup

docs-build:
	just --justfile docs/justfile build

docs-check:
	just --justfile docs/justfile check

docs-dev:
	just --justfile docs/justfile dev

docs-serve:
	just --justfile docs/justfile serve

docs-site:
	just --justfile docs/justfile site

docs-serve-site:
	just --justfile docs/justfile serve-site

docs-deploy:
	gh workflow run pages.yml --ref main
