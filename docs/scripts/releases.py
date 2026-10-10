"""Build missing release docs, and rebuild an explicitly requested tag."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from importlib.util import spec_from_file_location, module_from_spec

_spec = spec_from_file_location("docs_site", Path(__file__).with_name("site.py"))
_site = module_from_spec(_spec)
_spec.loader.exec_module(_site)
assemble, version_key = _site.assemble, _site.version_key

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"


def pending_releases(tags, site, initial, requested=""):
    minimum = version_key(initial)
    pending = []
    for tag in tags:
        try:
            if version_key(tag) < minimum:
                continue
        except ValueError:
            continue
        metadata = site / tag / "assets/version.json"
        recorded = json.loads(metadata.read_text()) if metadata.is_file() else {}
        if tag == requested or recorded.get("releaseTag") != tag:
            pending.append(tag)
    if requested and requested not in tags:
        raise ValueError(f"Release tag does not exist: {requested}")
    if requested and version_key(requested) < minimum:
        raise ValueError(f"Release tag predates initialVersion: {requested}")
    return sorted(pending, key=version_key)


def build_release(tag, site, config):
    with tempfile.TemporaryDirectory(prefix="codly-docs-release-") as temporary:
        source = Path(temporary) / "source"
        subprocess.run(["git", "clone", "--shared", "--no-checkout", str(ROOT), str(source)], check=True)
        subprocess.run(["git", "checkout", "--detach", tag], cwd=source, check=True)
        if (source / ".gitmodules").is_file():
            subprocess.run(["git", "submodule", "update", "--init", "--recursive"], cwd=source, check=True)
        docs = source / "docs"
        if not (docs / "scripts/build.mjs").is_file():
            shutil.copytree(DOCS, docs, ignore=shutil.ignore_patterns(
                "node_modules", ".tools", ".site", ".cache", "book", "__pycache__", "vendor"))
            (docs / "vendor").symlink_to(DOCS / "vendor", target_is_directory=True)
        for name, version_file in [(".tools", "tool-versions.json"), ("node_modules", "package-lock.json")]:
            if (docs / version_file).read_bytes() == (DOCS / version_file).read_bytes():
                (docs / name).symlink_to(DOCS / name, target_is_directory=True)
        subprocess.run(["python3", "scripts/bootstrap.py"], cwd=docs, check=True)
        env = {**os.environ, "PATH": f"{docs}/.tools/node/bin:{docs}/.tools:{os.environ['PATH']}",
               "CODLY_SOURCE": str(source)}
        if not (docs / "node_modules").exists():
            subprocess.run(["npm", "ci"], cwd=docs, env=env, check=True)
        subprocess.run(["node", "scripts/build.mjs"], cwd=docs, env=env, check=True)
        tests = sorted(str(p.relative_to(docs)) for p in (docs / "tests").glob("*.test.mjs"))
        subprocess.run(["node", "--test", *tests], cwd=docs, env=env, check=True)
        import tomllib
        package_version = tomllib.loads((source / "typst.toml").read_text())["package"]["version"]
        assemble(docs / "book", site, tag, config, package_version)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site", type=Path, default=DOCS / ".site")
    parser.add_argument("--release-ref", default="")
    args = parser.parse_args()
    config = json.loads((DOCS / "site.json").read_text())
    tags = subprocess.check_output(["git", "tag", "--list"], cwd=ROOT, text=True).splitlines()
    for tag in pending_releases(tags, args.site, config["initialVersion"], args.release_ref):
        build_release(tag, args.site.resolve(), config)
