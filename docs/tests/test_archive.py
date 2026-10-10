import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/archive.py"
spec = importlib.util.spec_from_file_location("codly_archive_script", SCRIPT)
archive_script = importlib.util.module_from_spec(spec)
spec.loader.exec_module(archive_script)


def git(*args, cwd):
    return subprocess.run(["git", *args], cwd=cwd, check=True, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.strip()


class ArchiveTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.repo = self.root / "repo"
        self.origin = self.root / "origin.git"
        self.repo.mkdir()
        git("init", "-b", "main", cwd=self.repo)
        git("config", "user.name", "Archive Test", cwd=self.repo)
        git("config", "user.email", "archive-test@example.invalid", cwd=self.repo)
        (self.repo / "tracked.txt").write_text("base\n")
        git("add", "tracked.txt", cwd=self.repo)
        git("commit", "-m", "base", cwd=self.repo)
        git("init", "--bare", str(self.origin), cwd=self.root)
        git("remote", "add", "origin", str(self.origin), cwd=self.repo)
        git("push", "-u", "origin", "main", cwd=self.repo)
        self.original_root = archive_script.ROOT
        archive_script.ROOT = self.repo

        # Publish while both the index and worktree contain caller changes.
        git("add", "--", "tracked.txt", cwd=self.repo)
        (self.repo / "staged.txt").write_text("staged\n")
        git("add", "staged.txt", cwd=self.repo)
        (self.repo / "tracked.txt").write_text("unstaged\n")
        self.before_status = git("status", "--porcelain", cwd=self.repo)
        self.before_head = git("rev-parse", "HEAD", cwd=self.repo)
        self.before_index = git("show", ":tracked.txt", cwd=self.repo)

    def tearDown(self):
        archive_script.ROOT = self.original_root
        self.temporary.cleanup()

    def assembled_site(self, version, index_text):
        site = self.root / "site"
        (site / "assets").mkdir(parents=True, exist_ok=True)
        (site / "index.html").write_text(index_text)
        (site / "assets" / "version.json").write_text(json.dumps({"version": version}) + "\n")
        (site / "versions.json").write_text(json.dumps({
            "defaultVersion": version, "versions": [version],
        }) + "\n")
        return site

    def fetch_docs_branch(self):
        git("fetch", "origin", "docs-site", cwd=self.repo)

    def test_publish_updates_remote_restore_returns_full_archive_and_caller_checkout_is_untouched(self):
        site = self.assembled_site("v2.0.0", "release 2.0")
        (site / "v2.0.0").mkdir()
        (site / "v2.0.0/index.html").write_text("archived 2.0")
        archive_script.publish(site)
        self.fetch_docs_branch()

        (site / "v2.1.0").mkdir()
        (site / "v2.1.0/index.html").write_text("archived 2.1")
        (site / "index.html").write_text("release 2.1")
        (site / "versions.json").write_text(json.dumps({
            "defaultVersion": "v2.1.0", "versions": ["v2.1.0", "v2.0.0", "main"],
        }) + "\n")
        archive_script.publish(site)
        self.fetch_docs_branch()

        restored = self.root / "restored"
        archive_script.restore(restored)
        self.assertEqual((restored / "index.html").read_text(), "release 2.1")
        self.assertEqual((restored / "v2.0.0/index.html").read_text(), "archived 2.0")
        self.assertEqual((restored / "v2.1.0/index.html").read_text(), "archived 2.1")
        self.assertEqual(json.loads((restored / "versions.json").read_text())["versions"],
                         ["v2.1.0", "v2.0.0", "main"])

        self.assertEqual(git("status", "--porcelain", cwd=self.repo), self.before_status)
        self.assertEqual(git("rev-parse", "HEAD", cwd=self.repo), self.before_head)
        self.assertEqual(git("show", ":tracked.txt", cwd=self.repo), self.before_index)
        self.assertEqual((self.repo / "tracked.txt").read_text(), "unstaged\n")

    def test_separate_hosting_remote_uses_orphan_branch_and_preserves_source_checkout(self):
        hosting = self.root / "hosting.git"
        git("init", "--bare", str(hosting), cwd=self.root)
        source_main = git("--git-dir", str(self.origin), "rev-parse", "refs/heads/main", cwd=self.root)

        site = self.assembled_site("v2.0.0", "release 2.0")
        (site / "v2.0.0").mkdir()
        (site / "v2.0.0/index.html").write_text("archived 2.0")
        archive_script.publish(site, str(hosting), "gh-pages")
        first = git("--git-dir", str(hosting), "rev-parse", "refs/heads/gh-pages", cwd=self.root)
        first_parents = git("--git-dir", str(hosting), "rev-list", "--parents", "-n", "1",
                            "refs/heads/gh-pages", cwd=self.root).split()
        self.assertEqual(first_parents, [first], "The hosting branch must start without source history")
        self.assertEqual(git("ls-remote", str(self.origin), "refs/heads/main", cwd=self.root).split()[0],
                         source_main)

        (site / "v2.1.0").mkdir()
        (site / "v2.1.0/index.html").write_text("archived 2.1")
        (site / "index.html").write_text("release 2.1")
        (site / "versions.json").write_text(json.dumps({
            "defaultVersion": "v2.1.0", "versions": ["v2.1.0", "v2.0.0"],
        }) + "\n")
        archive_script.publish(site, str(hosting), "gh-pages")
        second = git("--git-dir", str(hosting), "rev-parse", "refs/heads/gh-pages", cwd=self.root)
        self.assertEqual(git("rev-parse", f"{second}^", cwd=self.repo), first)
        self.assertEqual(git("ls-remote", str(self.origin), "refs/heads/main", cwd=self.root).split()[0],
                         source_main)

        restored = self.root / "hosting-restored"
        archive_script.restore(restored, str(hosting), "gh-pages")
        self.assertEqual((restored / "index.html").read_text(), "release 2.1")
        self.assertEqual((restored / "v2.0.0/index.html").read_text(), "archived 2.0")
        self.assertEqual((restored / "v2.1.0/index.html").read_text(), "archived 2.1")
        self.assertEqual(git("status", "--porcelain", cwd=self.repo), self.before_status)
        self.assertEqual(git("rev-parse", "HEAD", cwd=self.repo), self.before_head)
        self.assertEqual(git("show", ":tracked.txt", cwd=self.repo), self.before_index)
        self.assertEqual((self.repo / "tracked.txt").read_text(), "unstaged\n")

    def test_restore_of_absent_remote_branch_leaves_empty_destination(self):
        hosting = self.root / "empty-hosting.git"
        git("init", "--bare", str(hosting), cwd=self.root)
        restored = self.root / "empty-restored"
        archive_script.restore(restored, str(hosting), "gh-pages")
        self.assertEqual(list(restored.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
