#!/usr/bin/env python3
"""Run tests, accessibility checks, and deferred-layout diagnostic checks."""
import argparse
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
LAYOUT_ERRORS = {
    "padding-negative": "padding must be non-negative",
    "padding-axis-negative": "padding must be non-negative",
    "padding-key": "padding accepts only sides",
    "padding-type": "padding values must be lengths",
    "highlight-palette-empty": "highlight color palettes must not be empty",
    "theme-palette-empty": "highlight color palettes must not be empty",
    "theme-derived-palette-empty": "highlight color palettes must not be empty",
    "diff-language": "diff requires one nonempty language",
    "diff-languages": "diff requires one nonempty language",
    "diff-hunk": "invalid unified diff hunk header",
    "diff-incomplete": "incomplete unified diff hunk",
    "diff-counts": "unified diff hunk counts do not match",
    "diff-extra": "unified diff hunk counts do not match",
    "diff-prefix": "unified diff code lines must have",
    "diff-combined": "combined merge diffs are not supported",
    "diff-theme": "explicit string `raw.theme`",
    "diff-syntax": "explicit string `raw.syntaxes`",
    "gutter-negative-width": "gutter width must be non-negative",
    "gutter-negative-ratio": "gutter width must be non-negative",
    "gutter-negative-fraction": "gutter width must be non-negative",
    "gutter-empty-fill": "gutter fill palettes must not be empty",
    "gutter-invalid-value": "gutter values must be content, strings, numbers, or none",
    "theme-name": "unknown theme: does-not-exist",
    "theme-setting": "unknown theme setting: forground",
    "theme-section": "theme header must be a dictionary",
    "theme-base": "a theme must be a name or dictionary",
    "empty-fill": "`fill` palettes must not be empty",
    "filename-position": "file-position must select left/right and top/bottom",
    "language-position": "lang-position must select left/right and top/bottom",
    "filename-missing": "no-such-source.py",
    "range-conflict": "cannot specify both `range` and `ranges`",
    "annotation-overlap": "overlapping annotations",
    "annotation-touching": "overlapping annotations",
    "annotation-label": "require `block-label`",
    "annotation-auto-outside": "require `block-label`",
    "annotation-auto-unlabeled": "require `block-label`",
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
    """Compile the PDF/UA fixture and verify extracted text."""
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
            for text in ("filename source", "accessible.txt", "inline source", "inline.py", "plain source", "fn main()", "return 1", "Returns one", "outside", "Remark", "guided source", "guided child", "wrapped source", "bubble source", "Accessible bubble", "Above left", "Above right", "gutter source", "gutter label", "alternate 1")
        )
        passed &= all(extracted.stdout.count(token) == 1
                      for token in ("deleted_diff_token", "added_diff_token", "context_diff_token"))
        passed &= "padded_accessible_source" in extracted.stdout and "Indented accessible" in extracted.stdout
        if not passed:
            result = extracted
    print(f"{'pass' if passed else 'FAIL'} accessibility/pdf-ua", flush=True)
    if not passed:
        print(result.stderr or result.stdout)
    return passed


def run_listing_accessibility(output):
    """Verify figure-kind hints do not duplicate code in PDF/UA output."""
    result = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), "--pdf-standard", "ua-1",
         "--font-path", str(ROOT / "fonts"),
         str(ROOT / "tests/figure-kind/test.typ"), str(output)],
        cwd=ROOT, capture_output=True, text=True,
    )
    passed = result.returncode == 0
    if passed:
        result = subprocess.run(
            ["pdftotext", "-layout", str(output), "-"],
            capture_output=True, text=True,
        )
        tokens = (
            "raw_listing_token", "string_listing_token", "file_listing_token",
            "wrapped_listing_token", "context_listing_token", "marked_listing_token",
            "override_listing_token", "custom_listing_token", "automatic_listing_token",
            "explicit_auto_listing_token", "old_listing_token", "new_listing_token",
            "styled_listing_token",
        )
        passed = result.returncode == 0 and all(
            result.stdout.count(token) == 1 for token in tokens
        )
        passed &= all(caption in result.stdout for caption in (
            "Listing 1: Raw input", "Listing 10: Caption above", "Figure 3: Second image",
        ))
    print(f"{'pass' if passed else 'FAIL'} accessibility/listing-figures", flush=True)
    if not passed:
        print(result.stderr or result.stdout)
    return passed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--errors-only", action="store_true")
    parser.add_argument("--compile-only", action="store_true",
                        help="compile CLI-compatible fixtures with the installed Typst instead of Tytanic")
    args = parser.parse_args()
    failed = False
    if not args.errors_only and not args.compile_only:
        result = subprocess.run(
            ["tt", "run", "--no-fail-fast", "--font-path", "fonts"], cwd=ROOT
        )
        failed = result.returncode != 0
    with tempfile.TemporaryDirectory(prefix="codly-tests-") as temporary:
        if args.compile_only and not args.errors_only:
            # Tytanic supplies a native catch() helper that the CLI cannot
            # inject. Those tests remain covered by the normal Tytanic job.
            count = 0
            skipped = 0
            for fixture in sorted(ROOT.glob("tests/*/test.typ")):
                sources = [fixture, *fixture.parent.glob("*.typ")]
                if any(re.search(r"\bcatch\s*\(", path.read_text()) for path in sources):
                    skipped += 1
                    continue
                result = subprocess.run(
                    ["typst", "compile", "--root", str(ROOT), "--font-path", str(ROOT / "fonts"),
                     str(fixture), str(Path(temporary) / "compat.pdf")],
                    cwd=ROOT, capture_output=True, text=True,
                )
                passed = result.returncode == 0
                print(f"{'pass' if passed else 'FAIL'} compatibility/{fixture.parent.name}", flush=True)
                if not passed:
                    print(result.stderr)
                    failed = True
                count += 1
            print(f"Compiled {count} fixtures; {skipped} require Tytanic catch()", flush=True)
        if not args.errors_only:
            failed |= not run_accessibility(Path(temporary) / "accessibility.pdf")
            failed |= not run_listing_accessibility(Path(temporary) / "listing-figures.pdf")
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
    if not args.errors_only:
        gallery = [sys.executable, str(ROOT / "scripts/examples.py"),
                   "--compile-only" if args.compile_only else "--check"]
        failed |= subprocess.run(gallery, cwd=ROOT).returncode != 0
        failed |= subprocess.run([sys.executable, str(ROOT / "scripts/readme.py")],
                                 cwd=ROOT).returncode != 0
        result = subprocess.run([sys.executable, str(ROOT / "tests/tooling.py")], cwd=ROOT)
        failed |= result.returncode != 0
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
