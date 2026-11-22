#!/usr/bin/env python3
"""Publish only a face's normalized position for the optional CNE demo."""
import argparse
import os
from pathlib import Path
import sys
import tempfile
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
    # A reader sees either the previous complete sample or the next complete sample.
    fd, name = tempfile.mkstemp(prefix=".ttf-gaze-", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            stream.write("|".join(("1", str(payload["time"]), "1" if payload["found"] else "0",
                                   str(payload.get("x", 0)), str(payload.get("y", 0)), payload["owner"])))
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


def run(camera_index, path, backend="auto"):
    try:
        import cv2
    except ImportError:
        print("OpenCV is missing. Install requirements.txt first.", file=sys.stderr)
        return 1

    cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    if cascade.empty():
        print("OpenCV's face detector could not be loaded.", file=sys.stderr)
        return 1
    if backend == "auto":
        camera = cv2.VideoCapture(camera_index)
    else:
        camera = cv2.VideoCapture(camera_index, getattr(cv2, "CAP_" + backend.upper()))
    if not camera.isOpened():
        camera.release()
        print(f"Could not open camera {camera_index}. Check permission and --camera.", file=sys.stderr)
        return 1

    owner = uuid.uuid4().hex
    print(f"Camera is active. Sending face position to {path}. Press Ctrl+C to stop.", flush=True)
    try:
        while True:
            started = time.monotonic()
            ok, frame = camera.read()
            if not ok or frame is None:
                print("Camera stopped delivering frames.", file=sys.stderr)
                return 1
            height, width = frame.shape[:2]
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(50, 50))
            sample = {"version": 1, "time": time.time(), "found": len(faces) > 0, "owner": owner}
            if len(faces):
                face = max(faces, key=lambda rect: int(rect[2]) * int(rect[3]))
                sample["x"], sample["y"] = position(face, width, height)
            publish(path, sample)
            time.sleep(max(0, 0.1 - (time.monotonic() - started)))
    except KeyboardInterrupt:
        return 0
    except OSError as exc:
        print(f"Could not publish face position: {exc}", file=sys.stderr)
        return 1
    finally:
        camera.release()
        try:
            # Do not delete a newer instance's sample.
            if path.read_text(encoding="utf-8").split("|")[-1] == owner:
                path.unlink()
        except OSError:
            pass


def main():
    parser = argparse.ArgumentParser(description="Track a face locally for the Teen Titans Funk webcam demo")
    parser.add_argument("--camera", type=int, default=0, help="camera index (default: 0)")
    parser.add_argument("--backend", choices=("auto", "msmf", "dshow"), default="auto",
                        help="camera backend (default: auto; msmf and dshow are Windows options)")
    args = parser.parse_args()
    return run(args.camera, gaze_path(), args.backend)


if __name__ == "__main__":
    sys.exit(main())
