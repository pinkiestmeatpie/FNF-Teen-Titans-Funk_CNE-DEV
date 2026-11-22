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
