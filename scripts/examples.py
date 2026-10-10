#!/usr/bin/env python3
"""Render the curated README gallery, or check its committed PNGs."""
import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ("quickstart", "themes", "annotations", "diff", "gutters", "presentation", "wrapping", "excerpts")
COMPILER = "0.15.1"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--compile-only", action="store_true", help="compile examples with any supported compiler, without PNG comparisons")
    args = parser.parse_args()
    version = subprocess.check_output(["typst", "--version"], text=True).split()[1]
    if not args.compile_only and version != COMPILER:
        parser.error(f"gallery PNGs require Typst {COMPILER}, found {version}")
    failed = False
    if args.check or args.compile_only:
        readme = (ROOT / "README.md").read_text()
        package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
        tag = re.escape("v" + package["version"])
        for name in EXAMPLES:
            link = re.compile(r"\[!\[[^\]]+\]\(examples/" + name
                              + r"\.png\)\]\(https://github\.com/Dherse/codly/blob/" + tag + r"/examples/"
                              + name + r"\.typ\)")
            if not link.search(readme):
                print(f"FAIL gallery/{name}: README preview must link to its GitHub source")
                failed = True
    with tempfile.TemporaryDirectory(prefix="codly-gallery-") as temporary:
        for name in EXAMPLES:
            extension = "pdf" if args.compile_only else "png"
            output = Path(temporary) / f"{name}.{extension}"
            command = ["typst", "compile", "--root", str(ROOT), "--font-path", str(ROOT / "fonts"),
                       "--ignore-system-fonts", "--creation-timestamp", "0",
                       str(ROOT / "examples" / f"{name}.typ"), str(output)]
            if not args.compile_only:
                command += ["--ppi", "144"]
            result = subprocess.run(command, cwd=ROOT)
            if result.returncode:
                failed = True
                continue
            target = ROOT / "examples" / f"{name}.png"
            if args.check:
                if not target.exists() or target.read_bytes() != output.read_bytes():
                    print(f"FAIL gallery/{name}: run just examples", flush=True)
                    failed = True
                    continue
            elif not args.compile_only:
                shutil.copyfile(output, target)
            print(f"pass gallery/{name}", flush=True)
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
