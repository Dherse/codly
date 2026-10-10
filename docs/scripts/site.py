"""Assemble archived documentation builds into a GitHub Pages site."""
import argparse
import json
from pathlib import Path
import re
import shutil
import tomllib

VERSION = re.compile(r"v(\d+)\.(\d+)\.(\d+)")


def version_key(version):
    match = VERSION.fullmatch(version)
    if not match:
        raise ValueError(f"Invalid release version: {version}")
    return tuple(map(int, match.groups()))


def copy_build(book, target, version, site_root):
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(book, target)
    (target / "assets/version.json").write_text(json.dumps({
        "version": version, "siteRoot": site_root,
    }) + "\n")


def assemble(book, site, version, config, package_version):
    if version != "main":
        version_key(version)
        if version != f"v{package_version}":
            raise ValueError(f"Release {version} does not match package {package_version}")
    if not (book / "index.html").is_file():
        raise ValueError("Build is missing index.html")
    initial = config["initialVersion"]
    version_key(initial)
    site.mkdir(parents=True, exist_ok=True)
    copy_build(book, site / version, version, "../")
    if version == "main" and not (site / initial).exists() and initial == f"v{package_version}":
        copy_build(book, site / initial, initial, "../")
    if version != "main":
        metadata = site / version / "assets/version.json"
        metadata.write_text(json.dumps({"version": version, "siteRoot": "../", "releaseTag": version}) + "\n")
    releases = sorted((p.name for p in site.iterdir()
                       if p.is_dir() and VERSION.fullmatch(p.name) and (p / "index.html").is_file()),
                      key=version_key, reverse=True)
    default = config["defaultVersion"]
    if default == "latest":
        if not releases:
            raise ValueError("No stable documentation build is available")
        default = releases[0]
    if default not in releases:
        raise ValueError(f"Default release {default} has not been built")
    for entry in site.iterdir():
        if entry.name in releases or entry.name == "main":
            continue
        if entry.is_dir():
            shutil.rmtree(entry)
        else:
            entry.unlink()
    for entry in (site / default).iterdir():
        target = site / entry.name
        if entry.is_dir():
            shutil.copytree(entry, target)
        else:
            shutil.copy2(entry, target)
    (site / "assets/version.json").write_text(json.dumps({"version": default, "siteRoot": "./"}) + "\n")
    versions = [{"version": item, "label": item} for item in releases]
    if (site / "main/index.html").is_file():
        versions.append({"version": "main", "label": "main (nightly)"})
    (site / "versions.json").write_text(json.dumps({
        "defaultVersion": default, "versions": versions,
    }, indent=2) + "\n")
    (site / ".nojekyll").touch()
    return default


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--book", type=Path, default=Path("book"))
    parser.add_argument("--site", type=Path, default=Path(".site"))
    parser.add_argument("--version", default="main")
    parser.add_argument("--config", type=Path, default=Path("site.json"))
    parser.add_argument("--package", type=Path, default=Path("../typst.toml"))
    args = parser.parse_args()
    package = tomllib.loads(args.package.read_text())["package"]["version"]
    default = assemble(args.book.resolve(), args.site.resolve(), args.version,
                       json.loads(args.config.read_text()), package)
    print(f"Built {args.version}; default: {default}; output: {args.site}")
