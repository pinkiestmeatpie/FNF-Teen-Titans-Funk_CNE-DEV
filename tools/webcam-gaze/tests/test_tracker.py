import importlib.util
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("tracker", Path(__file__).resolve().parents[1] / "tracker.py")
tracker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tracker)


class TrackerTests(unittest.TestCase):
    def test_mirrored_position_and_clamping(self):
        self.assertEqual(tracker.position((0, 25, 20, 50), 100, 100), (0.8, 0.0))
        self.assertEqual(tracker.position((90, 25, 20, 50), 100, 100), (-1.0, 0.0))
        self.assertEqual(tracker.position((40, 0, 20, 20), 100, 100), (0.0, -0.8))

    def test_publish_replaces_previous_sample(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.json"
            tracker.publish(path, {"time": 1, "found": True, "x": 0.5, "owner": "a"})
            tracker.publish(path, {"time": 2, "found": False, "owner": "b"})
            self.assertEqual(path.read_text(), "1|2|0|0|0|b")
            self.assertEqual(list(Path(directory).iterdir()), [path])

    def test_publish_retries_windows_file_sharing_errors(self):
        for error_code in (5, 32):
            with self.subTest(error_code=error_code), tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / "sample.txt"
                path.write_text("previous sample")
                error = PermissionError("file in use")
                error.winerror = error_code
                real_replace = tracker.os.replace
                attempts = []
                def replace_after_contention(src, dst):
                    attempts.append(1)
                    if len(attempts) <= 2:
                        raise error
                    return real_replace(src, dst)
                with patch.object(tracker.os, "replace", side_effect=replace_after_contention) as replace, \
                     patch.object(tracker.time, "sleep") as sleep:
                    tracker.publish(path, {"time": 1, "found": True, "x": 0.5, "owner": "a"})
                self.assertEqual(replace.call_count, 3)
                self.assertEqual(sleep.call_count, 2)
                self.assertEqual(path.read_text(), "1|1|1|0.5|0|a")
                self.assertEqual(list(Path(directory).iterdir()), [path])

    def test_publish_surfaces_persistent_permission_errors_and_cleans_up(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.txt"
            path.write_text("previous sample")
            error = PermissionError("file in use")
            error.winerror = 5
            with patch.object(tracker.os, "replace", side_effect=error), \
                 patch.object(tracker.time, "monotonic", side_effect=[0, 2]):
                with self.assertRaises(PermissionError):
                    tracker.publish(path, {"time": 1, "found": False, "owner": "a"})
            self.assertEqual(path.read_text(), "previous sample")
            self.assertEqual(list(Path(directory).iterdir()), [path])

    def test_selected_camera_backend_is_passed_to_opencv(self):
        class Camera:
            def isOpened(self): return False
            def release(self): pass
        calls = []
        fake_cv = types.SimpleNamespace(
            data=types.SimpleNamespace(haarcascades=""),
            CascadeClassifier=lambda path: types.SimpleNamespace(empty=lambda: False),
            CAP_MSMF=1400,
            VideoCapture=lambda *args: calls.append(args) or Camera(),
        )
        with patch.dict(sys.modules, {"cv2": fake_cv}):
            self.assertEqual(tracker.run(0, Path("unused"), "msmf"), 1)
            self.assertEqual(tracker.run(0, Path("unused")), 1)
        self.assertEqual(calls, [(0, 1400), (0,)])

    def test_capture_failure_and_cleanup(self):
        class Camera:
            released = False
            def isOpened(self): return True
            def read(self): return (False, None)
            def release(self): self.released = True
        camera = Camera()
        fake_cv = types.SimpleNamespace(
            data=types.SimpleNamespace(haarcascades=""),
            CascadeClassifier=lambda path: types.SimpleNamespace(empty=lambda: False),
            VideoCapture=lambda index: camera,
        )
        with tempfile.TemporaryDirectory() as directory, patch.dict(sys.modules, {"cv2": fake_cv}):
            path = Path(directory) / "sample.json"
            # A previous instance's sample must not be deleted.
            path.write_text("1|0|0|0|0|another-instance")
            self.assertEqual(tracker.run(0, path), 1)
            self.assertTrue(camera.released)
            self.assertTrue(path.exists())

    def test_stops_and_removes_own_sample(self):
        class Camera:
            released = False
            def isOpened(self): return True
            def read(self): return (True, types.SimpleNamespace(shape=(100, 100, 3)))
            def release(self): self.released = True
        camera = Camera()
        detector = types.SimpleNamespace(empty=lambda: False, detectMultiScale=lambda *a, **k: [(0, 25, 20, 50)])
        fake_cv = types.SimpleNamespace(data=types.SimpleNamespace(haarcascades=""),
            CascadeClassifier=lambda path: detector, VideoCapture=lambda index: camera,
            COLOR_BGR2GRAY=1, cvtColor=lambda frame, color: frame)
        with tempfile.TemporaryDirectory() as directory, patch.dict(sys.modules, {"cv2": fake_cv}):
            path = Path(directory) / "sample.json"
            captured = []
            real_publish = tracker.publish
            def record(path, payload):
                real_publish(path, payload)
                captured.append(path.read_text().split("|"))
            with patch.object(tracker, "publish", record), patch.object(tracker.time, "sleep", side_effect=KeyboardInterrupt):
                self.assertEqual(tracker.run(0, path), 0)
            self.assertTrue(camera.released)
            self.assertFalse(path.exists())
            self.assertEqual(captured[0][2], "1")
            self.assertAlmostEqual(float(captured[0][3]), 0.8)
            self.assertAlmostEqual(float(captured[0][4]), 0.0)


if __name__ == "__main__":
    unittest.main()
