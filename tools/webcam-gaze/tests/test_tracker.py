import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
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

    def test_automatic_camera_fallback_requires_a_frame(self):
        frame = object()
        attempts = []
        released = []

        class Camera:
            def __init__(self, index, backend):
                self.key = (index, backend)
                attempts.append(self.key)
            def isOpened(self): return self.key != (0, 700)
            def read(self): return (True, frame) if self.key == (1, 1400) else (False, None)
            def release(self): released.append(self.key)

        cv2 = types.SimpleNamespace(VideoCapture=Camera, CAP_MSMF=1400, CAP_DSHOW=700)
        camera, first_frame = tracker.open_camera(cv2, ((0, "msmf"), (0, "dshow"), (1, "msmf")), None)
        try:
            self.assertEqual(attempts, [(0, 1400), (0, 700), (1, 1400)])
            self.assertEqual(released, [(0, 1400), (0, 700)])
            self.assertIs(first_frame, frame)
        finally:
            camera.release()

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

    def test_automatic_tracker_stops_when_parent_pipe_closes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "cv2.py").write_text('''\
import os
from pathlib import Path
class data:
    haarcascades = ""
CAP_MSMF = 1400
COLOR_BGR2GRAY = 1
class CascadeClassifier:
    def __init__(self, path): pass
    def empty(self): return False
    def detectMultiScale(self, *a, **k): return []
class Frame:
    shape = (100, 100, 3)
class VideoCapture:
    def __init__(self, index, backend): assert (index, backend) == (0, CAP_MSMF)
    def isOpened(self): return True
    def read(self): return True, Frame()
    def release(self): Path(os.environ["RELEASE_MARKER"]).write_text("released")
def cvtColor(frame, color): return frame
''')
            sample = root / "sample.txt"
            marker = root / "released.txt"
            env = dict(os.environ, PYTHONPATH=str(root), TTF_GAZE_FILE=str(sample), RELEASE_MARKER=str(marker))
            process = subprocess.Popen(
                [sys.executable, str(Path(tracker.__file__)), "--backend", "msmf", "--parent-stdin"],
                stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env,
            )
            try:
                deadline = time.monotonic() + 5
                while not sample.exists() and process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                self.assertTrue(sample.exists(), "tracker did not publish a sample")
                process.stdin.close()
                self.assertEqual(process.wait(timeout=5), 0)
                self.assertTrue(marker.exists(), "camera was not released")
                self.assertFalse(sample.exists(), "owned sample was not cleaned up")
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait()

    def test_automatic_tracker_reports_unavailable_camera_to_session(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "cv2.py").write_text('''
class data: haarcascades = ""
CAP_MSMF = 1400
class CascadeClassifier:
    def __init__(self, path): pass
    def empty(self): return False
class VideoCapture:
    def __init__(self, index, backend): assert (index, backend) == (0, CAP_MSMF)
    def isOpened(self): return False
    def release(self): pass
''')
            session = root / "session.txt"
            env = dict(os.environ, PYTHONPATH=str(root))
            process = subprocess.run(
                [sys.executable, str(Path(tracker.__file__)), "--backend", "msmf", "--session-file", str(session)],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env, timeout=5,
            )
            self.assertEqual(process.returncode, 1)
            self.assertEqual(session.read_text(), "status|camera")

    def test_parent_watchdog_exits_when_camera_read_is_stuck(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "cv2.py").write_text('''\
import os, time
from pathlib import Path
class data:
    haarcascades = ""
CAP_MSMF = 1400
class CascadeClassifier:
    def __init__(self, path): pass
    def empty(self): return False
class VideoCapture:
    def __init__(self, index, backend): pass
    def isOpened(self): return True
    def read(self):
        Path(os.environ["READ_MARKER"]).write_text("blocked")
        time.sleep(60)
    def release(self): pass
''')
            marker = root / "reading.txt"
            env = dict(os.environ, PYTHONPATH=str(root), TTF_GAZE_FILE=str(root / "sample.txt"), READ_MARKER=str(marker))
            process = subprocess.Popen(
                [sys.executable, str(Path(tracker.__file__)), "--backend", "msmf", "--parent-stdin"],
                stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env,
            )
            try:
                deadline = time.monotonic() + 5
                while not marker.exists() and process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                self.assertTrue(marker.exists(), "camera did not enter the mocked read")
                process.stdin.close()
                self.assertEqual(process.wait(timeout=5), 0)
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait()

    def test_tracker_can_exit_with_parent_pipe_still_open(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "cv2.py").write_text('''\
class data:
    haarcascades = ""
class CascadeClassifier:
    def __init__(self, path): pass
    def empty(self): return False
class VideoCapture:
    def __init__(self, index): pass
    def isOpened(self): return False
    def release(self): pass
''')
            env = dict(os.environ, PYTHONPATH=str(root))
            process = subprocess.Popen(
                [sys.executable, str(Path(tracker.__file__)), "--parent-stdin"],
                stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env,
            )
            try:
                self.assertEqual(process.wait(timeout=5), 1)
            finally:
                process.stdin.close()
                if process.poll() is None:
                    process.kill()
                    process.wait()


if __name__ == "__main__":
    unittest.main()
