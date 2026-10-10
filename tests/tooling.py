#!/usr/bin/env python3
"""Check release configuration and smoke-test a package without development assets."""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]


def main():
    manifest = tomllib.loads((ROOT / "typst.toml").read_text())
    package = manifest["package"]
    ignores = {
        line.strip() for line in (ROOT / ".typstignore").read_text().splitlines()
        if line.strip() and not line.startswith("#")
    }
    difference = ignores ^ set(package["exclude"])
    assert not difference, f"packaging exclusion policies have diverged: {sorted(difference)}"
    assert not (ROOT / "scripts/gen-signature.py").exists(), "unsafe legacy generator restored"
    recipes = (ROOT / "Justfile").read_text()
    assert not re.search(r"^signature:", recipes, re.MULTILINE), "unsafe signature recipe restored"
    assert "python3 tests/run.py" in recipes, "local suite must use the complete runner"
    release = (ROOT / ".github/workflows/release.yml").read_text()
    workflow = (ROOT / ".github/workflows/test.yml").read_text()
    assert "workflow_call:" in workflow, "release validation workflow is not reusable"
    assert "needs: validate" in release, "release must wait for validation of the tagged commit"
    assert f"'{package['compiler']}'" in workflow, "minimum compiler missing from CI matrix"
    for setup in re.findall(r"setup-typst@v4\s+with:\s+(\S+):", release + workflow):
        assert setup == "typst-version", "incorrect setup-typst version input"
    for command in re.findall(r"^\s+(just [\w -]+)$", release, re.MULTILINE):
        subprocess.run(["just", "--dry-run", *command.split()[1:]], cwd=ROOT, check=True)

    with tempfile.TemporaryDirectory(prefix="codly-package-check-") as temporary:
        output = Path(temporary)
        subprocess.run([str(ROOT / "scripts/package"), str(output / "out")],
                       cwd=ROOT, check=True)
        built = output / "out" / package["name"] / package["version"]
        files = [path for path in built.rglob("*") if path.is_file()]
        forbidden = {"fonts", "assets", "examples", "tests", "scripts", "bench", "docs",
                     ".github", ".agents", ".codex", ".aws"}
        assert all(path.relative_to(built).parts[0] not in forbidden for path in files)
        assert not (built / "docs.pdf").exists()
        assert (built / "src/typst-small.png").is_file(), "runtime icon must be retained"
        assert (built / package["entrypoint"]).is_file()
        assert not re.search(r"\(examples/", (built / "README.md").read_text())
        assert f"/v{package['version']}/examples/" in (built / "README.md").read_text()
        size = sum(path.stat().st_size for path in files)
        assert size < 1024 * 1024, f"unexpected package growth: {size} bytes"
        smoke = built / ".package-smoke.typ"
        shutil.copyfile(ROOT / "tests/package-smoke.typ", smoke)
        subprocess.run(["typst", "compile", "--root", str(built),
                        "--ignore-system-fonts", str(smoke), str(output / "smoke.pdf")],
                       cwd=output, check=True)
        # Resolve the actual name/version import from an isolated package path.
        packages = output / "packages"
        installed = packages / "local" / package["name"] / package["version"]
        shutil.copytree(built, installed)
        source = (ROOT / "tests/package-smoke.typ").read_text().replace(
            '"/codly.typ"', f'"@local/{package["name"]}:{package["version"]}"')
        subprocess.run(["typst", "compile", "--root", str(output),
                        "--package-path", str(packages), "--ignore-system-fonts",
                        "-", str(output / "versioned-smoke.pdf")],
                       input=source, text=True, cwd=output, check=True)
        print(f"pass tooling/package-smoke ({size:,} bytes)", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
