"""Restore or publish built documentation to a Git remote and branch."""
import argparse
import hashlib
import uuid
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[2]
BRANCH = "docs-site"


def git(*args, cwd=None, capture=False):
    return subprocess.run(["git", *args], cwd=cwd or ROOT, check=True,
                          text=True, stdout=subprocess.PIPE if capture else None).stdout


def archive_ref(remote, branch):
    key = hashlib.sha256(f"{remote}\n{branch}".encode()).hexdigest()
    return f"refs/codly-docs/archives/{key}"


def restore(site, remote="origin", branch=BRANCH):
    site.mkdir(parents=True, exist_ok=True)
    if any(site.iterdir()):
        raise ValueError(f"Archive destination must be empty: {site}")
    git("check-ref-format", "--branch", branch, capture=True)
    cached = archive_ref(remote, branch)
    heads = git("ls-remote", "--heads", remote, f"refs/heads/{branch}", capture=True)
    if not heads.strip():
        git("update-ref", "-d", cached)
        return
    git("fetch", remote, f"refs/heads/{branch}")
    git("update-ref", cached, "FETCH_HEAD")
    with tempfile.TemporaryFile() as output:
        subprocess.run(["git", "archive", cached], cwd=ROOT,
                       stdout=output, check=True)
        output.seek(0)
        with tarfile.open(fileobj=output) as archive:
            archive.extractall(site, filter="data")


def publish(site, remote="origin", branch=BRANCH):
    if not (site / "versions.json").is_file():
        raise ValueError("No assembled site to archive")
    git("check-ref-format", "--branch", branch, capture=True)
    cached = archive_ref(remote, branch)
    previous = subprocess.run(["git", "rev-parse", "--verify", cached],
                              cwd=ROOT, capture_output=True, text=True)
    orphan = "codly-docs-publish-" + uuid.uuid4().hex if previous.returncode != 0 else None
    with tempfile.TemporaryDirectory(prefix="codly-docs-publish-") as temporary:
        checkout = Path(temporary) / "archive"
        git("worktree", "add", "--detach", str(checkout),
            previous.stdout.strip() if previous.returncode == 0 else "HEAD")
        try:
            if orphan:
                git("checkout", "--orphan", orphan, cwd=checkout)
            for entry in checkout.iterdir():
                if entry.name == ".git":
                    continue
                if entry.is_dir() and not entry.is_symlink():
                    shutil.rmtree(entry)
                else:
                    entry.unlink()
            shutil.copytree(site, checkout, dirs_exist_ok=True)
            git("add", "--all", cwd=checkout)
            changed = subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=checkout).returncode
            if changed:
                git("-c", "user.name=github-actions[bot]", "-c",
                    "user.email=41898282+github-actions[bot]@users.noreply.github.com",
                    "commit", "-m", "Update documentation builds", cwd=checkout)
                git("push", remote, f"HEAD:refs/heads/{branch}", cwd=checkout)
                commit = git("rev-parse", "HEAD", cwd=checkout, capture=True).strip()
                git("update-ref", cached, commit)
        finally:
            git("worktree", "remove", "--force", str(checkout))
            if orphan:
                git("branch", "-D", orphan)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["restore", "publish"])
    parser.add_argument("--site", type=Path, default=ROOT / "docs/.site")
    parser.add_argument("--remote", default="origin")
    parser.add_argument("--branch", default=BRANCH)
    args = parser.parse_args()
    (restore if args.action == "restore" else publish)(args.site.resolve(), args.remote, args.branch)
