#!/usr/bin/env python3
"""Compile each standalone Typst snippet in the README against this checkout."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    snippets = re.findall(r"^(`{3,})typ\n(.*?)^\1\s*$",
                          (ROOT / "README.md").read_text(), re.MULTILINE | re.DOTALL)
    assert snippets, "README has no compilable Typst examples"
    with tempfile.TemporaryDirectory(prefix="codly-readme-") as temporary:
        for index, (_, source) in enumerate(snippets, 1):
            source = re.sub(r'"@preview/codly:[0-9.]+"', '"/codly.typ"', source)
            subprocess.run(["typst", "compile", "--root", str(ROOT),
                            "--font-path", str(ROOT / "fonts"), "-",
                            str(Path(temporary) / f"{index}.pdf")],
                           input=source, text=True, cwd=ROOT, check=True)
            print(f"pass readme/snippet-{index}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
