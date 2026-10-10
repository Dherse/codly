#!/usr/bin/env python3
"""Use release-tag URLs for README links excluded from the runtime package."""
from pathlib import Path
import re
import sys
import tomllib

root = Path(__file__).resolve().parents[1]
package = tomllib.loads((root / "typst.toml").read_text())["package"]
repository = package["repository"].removeprefix("https://github.com/")
tag = "v" + package["version"]
readme = Path(sys.argv[1]) / "README.md"


def replace(match):
    path = match.group(1)
    if path.endswith(".png"):
        return f"(https://raw.githubusercontent.com/{repository}/{tag}/{path})"
    return f"(https://github.com/{repository}/blob/{tag}/{path})"


readme.write_text(re.sub(r"\((examples/[^)]+)\)", replace, readme.read_text()))
