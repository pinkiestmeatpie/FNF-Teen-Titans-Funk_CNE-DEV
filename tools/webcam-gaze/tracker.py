#!/usr/bin/env python3
"""Publish only a face's normalized position for the optional CNE demo."""
import argparse
import os
from pathlib import Path
import sys
import tempfile
import threading
import time
import uuid


def gaze_path():
    override = os.environ.get("TTF_GAZE_FILE")
    if override:
        return Path(override)
    directory = next((os.environ.get(name) for name in ("TMPDIR", "TEMP", "TMP") if os.environ.get(name)), None)
    return Path(directory or ("." if os.name == "nt" else "/tmp")) / "ttf-webcam-gaze.txt"


def position(face, width, height):
    """Mirror the camera image, so the eyes follow screen-relative movement."""
    x, y, w, h = face
    return (max(-1.0, min(1.0, 1.0 - 2.0 * (x + w / 2) / width)),
            max(-1.0, min(1.0, 2.0 * (y + h / 2) / height - 1.0)))


def publish(path, payload):
    publish_text(path, "|".join(("1", str(payload["time"]), "1" if payload["found"] else "0",
                                 str(payload.get("x", 0)), str(payload.get("y", 0)), payload["owner"])))


def publish_text(path, text):
    # A reader sees either the previous complete sample or the next complete sample.
    fd, name = tempfile.mkstemp(prefix=".ttf-gaze-", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            stream.write(text)
        # Windows can briefly deny replacement while the game has the old
        # sample open. Keep the complete temporary file and retry the rename.
        deadline = time.monotonic() + 1.0
        while True:
            try:
                os.replace(name, path)
                break
            except PermissionError as exc:
                if getattr(exc, "winerror", None) not in (5, 32) or time.monotonic() >= deadline:
                    raise
                time.sleep(0.01)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def open_camera(cv2, choices, stop_event):
    # An open handle is not enough: some devices open but return no color frames.
    for index, backend in choices:
        if stop_event is not None and stop_event.is_set():
            break
        camera = None
        keep = False
        try:
            if backend == "auto":
                camera = cv2.VideoCapture(index)
            else:
                camera = cv2.VideoCapture(index, getattr(cv2, "CAP_" + backend.upper()))
            if camera.isOpened():
                ok, frame = camera.read()
                if ok and frame is not None:
                    keep = True
                    return camera, frame
        except cv2.error as exc:
            print(f"Camera {index} ({backend}) failed: {exc}", file=sys.stderr)
        finally:
            if camera is not None and not keep:
                camera.release()
    return None, None


def run(camera_index, path, backend="auto", stop_event=None, *, choices=None, report=None):
    def fail(code, text):
        print(text, file=sys.stderr)
        if report is not None and (stop_event is None or not stop_event.is_set()):
            report(code)
        return 1

    try:
        import cv2
    except ImportError:
        return fail("library", "OpenCV could not be loaded. Check the tracker dependencies.")

    cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    if cascade.empty():
        return fail("library", "OpenCV's face detector could not be loaded.")
    camera, frame = open_camera(cv2, choices or ((camera_index, backend),), stop_event)
    if stop_event is not None and stop_event.is_set():
        if camera is not None:
            camera.release()
        return 0
    if camera is None:
        return fail("camera", f"Could not read from the camera (starting at index {camera_index}).")

    owner = uuid.uuid4().hex
    print(f"Camera is active. Sending face position to {path}. Press Ctrl+C to stop.", flush=True)
    try:
        while stop_event is None or not stop_event.is_set():
            started = time.monotonic()
            height, width = frame.shape[:2]
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(50, 50))
            sample = {"version": 1, "time": time.time(), "found": len(faces) > 0, "owner": owner}
            if len(faces):
                face = max(faces, key=lambda rect: int(rect[2]) * int(rect[3]))
                sample["x"], sample["y"] = position(face, width, height)
            publish(path, sample)
            delay = max(0, 0.1 - (time.monotonic() - started))
            if stop_event is None:
                time.sleep(delay)
            else:
                if stop_event.wait(delay):
                    break
            ok, frame = camera.read()
            if not ok or frame is None:
                return fail("frames", "Camera stopped delivering frames.")
        return 0
    except KeyboardInterrupt:
        return 0
    except OSError as exc:
        return fail("output", f"Could not publish face position: {exc}")
    finally:
        camera.release()
        try:
            # Do not delete a newer instance's sample.
            if path.read_text(encoding="utf-8").split("|")[-1] == owner:
                path.unlink()
        except OSError:
            pass


def watch_parent(stop_event):
    # The game owns this pipe. EOF means it closed or exited.
    try:
        # Read the OS handle directly so a blocked daemon does not hold the
        # buffered stdin lock during normal Python shutdown.
        os.read(sys.stdin.fileno(), 1)
    except (OSError, ValueError):
        pass
    stop_event.set()
    # A stuck camera driver must not leave the camera open after the game exits.
    time.sleep(2)
    os._exit(0)


def main():
    parser = argparse.ArgumentParser(description="Track a face locally for the Teen Titans Funk webcam demo")
    parser.add_argument("--camera", type=int, default=0, help="camera index (default: 0)")
    parser.add_argument("--backend", choices=("auto", "msmf", "dshow"), default="auto",
                        help="camera backend (default: auto; msmf and dshow are Windows options)")
    parser.add_argument("--parent-stdin", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--session-file", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    stop_event = None
    if args.parent_stdin:
        stop_event = threading.Event()
        threading.Thread(target=watch_parent, args=(stop_event,), daemon=True).start()
    def report(code):
        if args.session_file is not None and (stop_event is None or not stop_event.is_set()):
            try:
                publish_text(args.session_file, "status|" + code)
            except OSError as exc:
                print(f"Could not write webcam status: {exc}", file=sys.stderr)

    if args.session_file:
        report("opening")
    return run(args.camera, args.session_file or gaze_path(), args.backend, stop_event, report=report)


if __name__ == "__main__":
    sys.exit(main())
