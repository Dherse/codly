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
    "alias-theme": "explicit string `raw.theme`",
    "alias-syntax": "explicit string `raw.syntaxes`",
    "callout-pointer-negative": "pointer must be non-negative",
    "callout-pointer-past-end": "pointer exceeds source line length",
    "callout-negative-size": "pointer size and bubble radius must be non-negative",
    "callout-negative-width": "bubble width must be non-negative",
    "callout-negative-inset": "bubble inset and outset must be non-negative",
    "callout-negative-gap": "bubble gap must be non-negative",
    "callout-negative-gap-y": "bubble gap must be non-negative",
    "callout-gap-keys": "bubble gap accepts only x and y",
    "callout-gap-type": "bubble gap axes must be lengths",
    "callout-negative-pointer-height": "pointer height and width must be non-negative",
    "callout-negative-pointer-width": "pointer height and width must be non-negative",
    "bubble-negative-height": "pointer height and width must be non-negative",
}


def run_accessibility(output):
    """Compile the accessibility fixture as PDF/UA and check text extraction."""
    result = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), "--pdf-standard", "ua-1",
         "--font-path", str(ROOT / "fonts"),
         str(ROOT / "tests/accessibility/test.typ"), str(output)],
        cwd=ROOT, capture_output=True, text=True,
    )
    passed = result.returncode == 0
    if passed:
        extracted = subprocess.run(
            ["pdftotext", "-layout", str(output), "-"],
            capture_output=True, text=True,
        )
        passed = extracted.returncode == 0 and all(
            text in extracted.stdout
            for text in ("plain source", "fn main()", "return 1", "Returns one", "outside", "Remark", "guided source", "guided child", "wrapped source", "bubble source", "Accessible bubble", "Above left", "Above right")
        )
        if not passed:
            result = extracted
    print(f"{'pass' if passed else 'FAIL'} accessibility/pdf-ua", flush=True)
    if not passed:
        print(result.stderr or result.stdout)
    return passed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--errors-only", action="store_true")
    args = parser.parse_args()
    failed = False
    if not args.errors_only:
        result = subprocess.run(
            ["tt", "run", "--no-fail-fast", "--font-path", "fonts"], cwd=ROOT
        )
        failed = result.returncode != 0
    with tempfile.TemporaryDirectory(prefix="codly-tests-") as temporary:
        if not args.errors_only:
            failed |= not run_accessibility(Path(temporary) / "accessibility.pdf")
        for case, expected in LAYOUT_ERRORS.items():
            result = subprocess.run(
                ["typst", "compile", "--root", str(ROOT), "--font-path",
                 str(ROOT / "fonts"), "--input", f"case={case}",
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
