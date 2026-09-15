#!/usr/bin/env python3
"""Run visual/assertion tests and check errors raised during deferred layout."""
import argparse
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
LAYOUT_ERRORS = {
    "range-conflict": "cannot specify both `range` and `ranges`",
    "annotation-overlap": "overlapping annotations",
    "annotation-touching": "overlapping annotations",
    "annotation-label": "require `block-label`",
    "highlight-label": "contained within a figure",
    "item-without-tag": "tag is required for item reference",
    "missing-offset": "expected a unique code block label",
    "duplicate-info": "expected a unique code block label",
    "info-without-code": "no code block found after",
    "missing-reference": "does not exist in the document",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--errors-only", action="store_true")
    args = parser.parse_args()
    failed = False
    if not args.errors_only:
        result = subprocess.run(
            ["tt", "run", "--no-fail-fast", "--font-path", "docs/fonts"], cwd=ROOT
        )
        failed = result.returncode != 0
    with tempfile.TemporaryDirectory(prefix="codly-tests-") as temporary:
        for case, expected in LAYOUT_ERRORS.items():
            result = subprocess.run(
                ["typst", "compile", "--root", str(ROOT), "--font-path",
                 str(ROOT / "docs/fonts"), "--input", f"case={case}",
                 str(ROOT / "tests/errors/layout.typ"), str(Path(temporary) / "test.pdf")],
                cwd=ROOT, capture_output=True, text=True,
            )
            passed = result.returncode == 1 and expected in result.stderr
            print(f"{'pass' if passed else 'FAIL'} layout/{case}", flush=True)
            if not passed:
                print(result.stderr or f"Expected a diagnostic containing: {expected}")
                failed = True
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
