import json
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
spec = importlib.util.spec_from_file_location("codly_site_script", Path(__file__).resolve().parents[1] / "scripts/site.py")
site_script = importlib.util.module_from_spec(spec)
spec.loader.exec_module(site_script)


class AssembleTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.site = self.root / "site"

    def tearDown(self):
        self.temporary.cleanup()

    def book(self, name, content):
        book = self.root / name
        (book / "assets").mkdir(parents=True)
        (book / "index.html").write_text(content)
        (book / "assets" / "example.txt").write_text(content)
        return book

    def assemble(self, book, version, package_version, default="latest", initial="v2.0.0"):
        return site_script.assemble(book, self.site, version,
                                    {"initialVersion": initial, "defaultVersion": default},
                                    package_version)

    def test_main_bootstraps_release_and_preserves_it_on_later_nightly_build(self):
        first = self.book("main-20", "nightly 2.0")
        self.assertEqual(self.assemble(first, "main", "2.0.0"), "v2.0.0")
        snapshot = (self.site / "v2.0.0/index.html").read_text()
        self.assertEqual(snapshot, "nightly 2.0")
        self.assertEqual(json.loads((self.site / "v2.0.0/assets/version.json").read_text()),
                         {"version": "v2.0.0", "siteRoot": "../"})

        second = self.book("main-21", "nightly 2.1")
        self.assertEqual(self.assemble(second, "main", "2.1.0"), "v2.0.0")
        self.assertEqual((self.site / "v2.0.0/index.html").read_text(), snapshot)
        self.assertEqual((self.site / "main/index.html").read_text(), "nightly 2.1")

    def test_release_keeps_history_latest_root_metadata_and_manifest_order(self):
        self.assemble(self.book("main", "nightly 2.0"), "main", "2.0.0")
        self.assemble(self.book("release-21", "release 2.1"), "v2.1.0", "2.1.0")

        self.assertEqual((self.site / "v2.0.0/index.html").read_text(), "nightly 2.0")
        self.assertEqual((self.site / "v2.1.0/index.html").read_text(), "release 2.1")
        self.assertEqual((self.site / "index.html").read_text(), "release 2.1")
        self.assertEqual(json.loads((self.site / "assets/version.json").read_text()),
                         {"version": "v2.1.0", "siteRoot": "./"})
        manifest = json.loads((self.site / "versions.json").read_text())
        self.assertEqual(manifest["defaultVersion"], "v2.1.0")
        self.assertEqual([entry["version"] for entry in manifest["versions"]],
                         ["v2.1.0", "v2.0.0", "main"])
        self.assertEqual(manifest["versions"][-1], {"version": "main", "label": "main (nightly)"})

    def test_config_can_pin_default_to_older_release(self):
        self.assemble(self.book("main", "nightly"), "main", "2.0.0")
        self.assemble(self.book("release-21", "release 2.1"), "v2.1.0", "2.1.0",
                      default="v2.0.0")
        self.assertEqual((self.site / "index.html").read_text(), "nightly")
        self.assertEqual(json.loads((self.site / "assets/version.json").read_text())["version"],
                         "v2.0.0")
        self.assertEqual(json.loads((self.site / "versions.json").read_text())["defaultVersion"],
                         "v2.0.0")

    def test_release_must_match_package_version(self):
        with self.assertRaisesRegex(ValueError, "does not match package"):
            self.assemble(self.book("wrong-release", "x"), "v2.1.0", "2.2.0")

    def test_unbuilt_default_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Default release v9.9.9 has not been built"):
            self.assemble(self.book("main", "nightly"), "main", "2.0.0", default="v9.9.9")


if __name__ == "__main__":
    unittest.main()
