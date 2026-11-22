import hashlib
import importlib.util
import os
from pathlib import Path
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch
import zipfile

launcher_path = Path(__file__).resolve().parents[1] / "windows" / "launcher.py"
spec = importlib.util.spec_from_file_location("webcam_launcher", launcher_path)
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)


class LauncherTests(unittest.TestCase):
    def make_package(self, root):
        packages = root / "packages"
        packages.mkdir()
        wheel = packages / "fixture.whl"
        with zipfile.ZipFile(wheel, "w") as archive:
            archive.writestr("fixture/__init__.py", "answer = 42\n")
        return ((wheel.name, hashlib.sha256(wheel.read_bytes()).hexdigest()),)

    def test_prepares_and_reuses_cache_without_network(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            packages = self.make_package(root)
            with patch.object(launcher, "ROOT", root), patch.object(launcher, "PACKAGES", packages), \
                 patch.dict(os.environ, {"LOCALAPPDATA": temp}):
                destination = launcher.prepare_packages(threading.Event())
                self.assertEqual((destination / "fixture" / "__init__.py").read_text(), "answer = 42\n")
                (root / "packages" / "fixture.whl").unlink()
                self.assertEqual(launcher.prepare_packages(threading.Event()), destination)

    def test_bad_package_does_not_leave_ready_or_partial_cache(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            packages = self.make_package(root)
            bad = ((packages[0][0], "0" * 64),)
            with patch.object(launcher, "ROOT", root), patch.object(launcher, "PACKAGES", bad), \
                 patch.dict(os.environ, {"LOCALAPPDATA": temp}):
                with self.assertRaises(ValueError):
                    launcher.prepare_packages(threading.Event())
                cache = root / "TeenTitansFunk" / "webcam"
                self.assertFalse((cache / launcher.CACHE_VERSION).exists())
                self.assertFalse(list(cache.glob(launcher.CACHE_VERSION + "-install-*")))

    def test_cancelled_preparation_does_not_install(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            packages = self.make_package(root)
            stopped = threading.Event()
            stopped.set()
            with patch.object(launcher, "ROOT", root), patch.object(launcher, "PACKAGES", packages), \
                 patch.dict(os.environ, {"LOCALAPPDATA": temp}):
                with self.assertRaises(launcher.PreparationStopped):
                    launcher.prepare_packages(stopped)

    def test_concurrent_preparation_shares_finished_installation(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            packages = self.make_package(root)
            with patch.object(launcher, "ROOT", root), patch.object(launcher, "PACKAGES", packages), \
                 patch.dict(os.environ, {"LOCALAPPDATA": temp}):
                with ThreadPoolExecutor(max_workers=2) as pool:
                    results = list(pool.map(lambda _: launcher.prepare_packages(threading.Event()), range(2)))
                self.assertEqual(results[0], results[1])
                self.assertTrue((results[0] / ".ready").is_file())
                self.assertFalse(list(results[0].parent.glob(launcher.CACHE_VERSION + "-install-*")))


if __name__ == "__main__":
    unittest.main()
