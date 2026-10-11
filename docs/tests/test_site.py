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

    def test_compiler_assets_share_urls_and_changed_bytes_keep_old_versions_working(self):
        def compiler_book(name, compiler=b"compiler"):
            book = self.book(name, name)
            (book / "assets/fonts").mkdir()
            (book / "assets/compiler.wasm").write_bytes(compiler)
            (book / "assets/renderer.wasm").write_bytes(b"renderer")
            (book / "assets/fonts/emoji.ttf").write_bytes(b"font")
            (book / "assets/compiler-assets.json").write_text(json.dumps({
                "compilerWasm": "compiler.wasm", "rendererWasm": "renderer.wasm",
                "fonts": ["fonts/emoji.ttf"],
            }))
            return book

        def resolved(build):
            manifest = build / "assets/compiler-assets.json"
            data = json.loads(manifest.read_text())
            return [(manifest.parent / name).resolve() for name in
                    [data["compilerWasm"], data["rendererWasm"], *data["fonts"]]]

        self.assemble(compiler_book("first"), "main", "2.0.0")
        original = resolved(self.site / "v2.0.0")
        self.assertEqual(resolved(self.site / "main"), original)
        self.assertEqual(resolved(self.site), original)
        self.assertEqual(len(list((self.site / "_typst").iterdir())), 3)

        self.assemble(compiler_book("release"), "v2.1.0", "2.1.0")
        self.assertEqual(resolved(self.site / "v2.1.0"), original)
        self.assertEqual(resolved(self.site), original)
        self.assertEqual(len(list((self.site / "_typst").iterdir())), 3)

        self.assemble(compiler_book("updated", b"new compiler"), "main", "2.2.0")
        updated = resolved(self.site / "main")
        self.assertNotEqual(updated[0], original[0])
        self.assertEqual(updated[1:], original[1:])
        self.assertEqual([file.read_bytes() for file in original], [b"compiler", b"renderer", b"font"])
        self.assertEqual(updated[0].read_bytes(), b"new compiler")
        self.assertEqual(len(list((self.site / "_typst").iterdir())), 4)

        self.assemble(compiler_book("pinned"), "main", "2.2.0", default="v2.0.0")
        self.assertEqual(resolved(self.site), original)

    def test_preserves_hosting_domain_across_main_release_and_pinned_default(self):
        self.site.mkdir()
        (self.site / "CNAME").write_text("codly.dherse.dev\n")
        first = self.book("main", "nightly")
        (first / "CNAME").write_text("stale-release.example\n")
        self.assemble(first, "main", "2.0.0")
        self.assertEqual((self.site / "CNAME").read_text(), "codly.dherse.dev\n")

        self.assemble(self.book("release", "release"), "v2.1.0", "2.1.0")
        self.assertEqual((self.site / "CNAME").read_text(), "codly.dherse.dev\n")
        self.assemble(self.book("later-main", "later nightly"), "main", "2.2.0",
                      default="v2.0.0")
        self.assertEqual((self.site / "CNAME").read_text(), "codly.dherse.dev\n")

    def test_configured_domain_is_created_and_restored_if_deleted(self):
        config = json.loads((Path(__file__).resolve().parents[1] / "site.json").read_text())
        book = self.book("main", "nightly")
        site_script.assemble(book, self.site, "main", config, "2.0.0")
        self.assertEqual((self.site / "CNAME").read_text(), "codly.dherse.dev\n")
        (self.site / "CNAME").unlink()
        site_script.assemble(book, self.site, "main", config, "2.0.0")
        self.assertEqual((self.site / "CNAME").read_text(), "codly.dherse.dev\n")

    def test_unbuilt_default_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Default release v9.9.9 has not been built"):
            self.assemble(self.book("main", "nightly"), "main", "2.0.0", default="v9.9.9")


if __name__ == "__main__":
    unittest.main()
