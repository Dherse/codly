import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/releases.py"
spec = importlib.util.spec_from_file_location("codly_releases_script", SCRIPT)
releases_script = importlib.util.module_from_spec(spec)
spec.loader.exec_module(releases_script)


class PendingReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.site = Path(self.temporary.name)

    def tearDown(self):
        self.temporary.cleanup()

    def record_release(self, tag, release_tag):
        metadata = self.site / tag / "assets" / "version.json"
        metadata.parent.mkdir(parents=True, exist_ok=True)
        metadata.write_text(json.dumps({"version": tag, "releaseTag": release_tag}))

    def test_skips_tags_before_initial_and_malformed_tags(self):
        self.assertEqual(releases_script.pending_releases(
            ["v1.9.9", "not-a-release", "v2.0.0", "v2.1.0"], self.site, "v2.0.0"),
            ["v2.0.0", "v2.1.0"])

    def test_includes_missing_release_and_initial_bootstrap_without_release_marker(self):
        self.record_release("v2.0.0", None)  # main seeded the initial stable path
        self.assertEqual(releases_script.pending_releases(
            ["v2.0.0", "v2.1.0"], self.site, "v2.0.0"), ["v2.0.0", "v2.1.0"])

    def test_ignores_release_with_matching_published_marker(self):
        self.record_release("v2.0.0", "v2.0.0")
        self.assertEqual(releases_script.pending_releases(
            ["v2.0.0"], self.site, "v2.0.0"), [])

    def test_explicit_requested_release_is_rebuilt_even_when_published(self):
        self.record_release("v2.0.0", "v2.0.0")
        self.record_release("v2.1.0", "v2.1.0")
        self.assertEqual(releases_script.pending_releases(
            ["v2.0.0", "v2.1.0"], self.site, "v2.0.0", "v2.0.0"), ["v2.0.0"])

    def test_missing_requested_tag_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Release tag does not exist: v2.0.0"):
            releases_script.pending_releases([], self.site, "v2.0.0", "v2.0.0")

    def test_requested_tag_before_initial_version_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "predates initialVersion: v1.9.9"):
            releases_script.pending_releases(["v1.9.9"], self.site, "v2.0.0", "v1.9.9")


if __name__ == "__main__":
    unittest.main()
