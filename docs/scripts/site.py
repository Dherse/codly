"""Assemble archived documentation builds into a GitHub Pages site."""
import argparse
import hashlib
import json
import os
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


def share_compiler_assets(build, site):
    """Give identical binaries the same URL across versions and the landing site."""
    manifest_path = build / "assets/compiler-assets.json"
    if not manifest_path.is_file():
        return  # Older archived runtimes still use their original asset URLs.
    manifest = json.loads(manifest_path.read_text())
    shared = site / "_typst"
    shared.mkdir(exist_ok=True)

    def share(name):
        source = (manifest_path.parent / name).resolve()
        source.relative_to(site.resolve())
        content = source.read_bytes()
        target = shared / (hashlib.sha256(content).hexdigest() + source.suffix)
        if not target.exists():
            target.write_bytes(content)
        return Path(os.path.relpath(target, manifest_path.parent)).as_posix()

    manifest["compilerWasm"] = share(manifest["compilerWasm"])
    manifest["rendererWasm"] = share(manifest["rendererWasm"])
    manifest["fonts"] = [share(name) for name in manifest["fonts"]]
    manifest_path.write_text(json.dumps(manifest) + "\n")


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
    share_compiler_assets(site / version, site)
    if version == "main" and not (site / initial).exists() and initial == f"v{package_version}":
        copy_build(book, site / initial, initial, "../")
        share_compiler_assets(site / initial, site)
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
        if entry.name in releases or entry.name in ("main", "CNAME", "_typst"):
            continue
        if entry.is_dir():
            shutil.rmtree(entry)
        else:
            entry.unlink()
    for entry in (site / default).iterdir():
        # The hosting domain belongs to the site, not an archived release.
        if entry.name == "CNAME":
            continue
        target = site / entry.name
        if entry.is_dir():
            shutil.copytree(entry, target)
        else:
            shutil.copy2(entry, target)
    (site / "assets/version.json").write_text(json.dumps({"version": default, "siteRoot": "./"}) + "\n")
    # The copied manifest was relative to a version directory; rebase it at root.
    manifest = site / "assets/compiler-assets.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text())
        def rebase(name):
            source = (site / default / "assets" / name).resolve()
            return Path(os.path.relpath(source, manifest.parent)).as_posix()
        data["compilerWasm"] = rebase(data["compilerWasm"])
        data["rendererWasm"] = rebase(data["rendererWasm"])
        data["fonts"] = [rebase(name) for name in data["fonts"]]
        manifest.write_text(json.dumps(data) + "\n")
    versions = [{"version": item, "label": item} for item in releases]
    if (site / "main/index.html").is_file():
        versions.append({"version": "main", "label": "main (nightly)"})
    (site / "versions.json").write_text(json.dumps({
        "defaultVersion": default, "versions": versions,
    }, indent=2) + "\n")
    (site / ".nojekyll").touch()
    if config.get("customDomain"):
        (site / "CNAME").write_text(config["customDomain"] + "\n")
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
