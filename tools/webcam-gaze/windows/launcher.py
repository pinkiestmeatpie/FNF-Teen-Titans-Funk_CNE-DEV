#!/usr/bin/env python3
"""Prepare the bundled Windows dependencies and optionally run the tracker."""
import argparse
import hashlib
import os
from pathlib import Path
import shutil
import sys
import tempfile
import threading
import time
import zipfile

# The embedded Python intentionally ignores global site-packages.
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
import tracker

PACKAGES = (
    ("numpy-2.5.5-cp314-cp314-win_amd64.whl", "20145b11776d2f7570cd61351b156a51d3a341822282095baa819d87272bc710"),
    ("opencv_python-4.14.0.94-cp37-abi3-win_amd64.whl", "ace53616cdffc9643e17e075397b493e607c427d388c7508798ef7ad2ed577cc"),
)
CACHE_VERSION = "python3144-numpy255-opencv414094-msmf"
CAMERAS = ((0, "msmf"), (0, "dshow"), (1, "msmf"), (1, "dshow"))


class PreparationStopped(Exception):
    pass


def acquire_lock(stream, stop_event):
    if os.name == "nt":
        import msvcrt
    else:
        import fcntl
    while not stop_event.is_set():
        try:
            stream.seek(0)
            if os.name == "nt":
                msvcrt.locking(stream.fileno(), msvcrt.LK_NBLCK, 1)
            else:
                fcntl.flock(stream.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            return
        except OSError:
            stop_event.wait(0.1)
    raise PreparationStopped()


def release_lock(stream):
    stream.seek(0)
    if os.name == "nt":
        import msvcrt
        msvcrt.locking(stream.fileno(), msvcrt.LK_UNLCK, 1)
    else:
        import fcntl
        fcntl.flock(stream.fileno(), fcntl.LOCK_UN)


def prepare_packages(stop_event):
    cache_base = Path(os.environ.get("LOCALAPPDATA") or tempfile.gettempdir()) / "TeenTitansFunk" / "webcam"
    cache_base.mkdir(parents=True, exist_ok=True)
    destination = cache_base / CACHE_VERSION
    marker = destination / ".ready"
    if marker.is_file():
        return destination
    # A kernel lock lets another game wait for preparation and is released on a crash.
    with open(cache_base / (CACHE_VERSION + ".lock"), "a+b") as lock:
        lock.seek(0, os.SEEK_END)
        if lock.tell() == 0:
            lock.write(b"0")
            lock.flush()
        acquire_lock(lock, stop_event)
        try:
            if marker.is_file():
                return destination
            if destination.exists():
                shutil.rmtree(destination)
            # Clean up abandoned installations without touching an active one.
            for old in cache_base.glob(CACHE_VERSION + "-install-*"):
                if old.is_dir() and time.time() - old.stat().st_mtime > 86400:
                    shutil.rmtree(old, ignore_errors=True)
            staging = Path(tempfile.mkdtemp(prefix=CACHE_VERSION + "-install-", dir=cache_base))
            try:
                for name, expected in PACKAGES:
                    wheel = ROOT / "packages" / name
                    digest = hashlib.sha256()
                    with wheel.open("rb") as source:
                        for chunk in iter(lambda: source.read(1024 * 1024), b""):
                            if stop_event.is_set():
                                raise PreparationStopped()
                            digest.update(chunk)
                    if digest.hexdigest() != expected:
                        raise ValueError("Bundled webcam package failed its integrity check: " + name)
                    with zipfile.ZipFile(wheel) as archive:
                        for entry in archive.infolist():
                            if stop_event.is_set():
                                raise PreparationStopped()
                            archive.extract(entry, staging)
                (staging / ".ready").write_text(CACHE_VERSION, encoding="utf-8")
                os.replace(staging, destination)
            finally:
                if staging.exists():
                    shutil.rmtree(staging, ignore_errors=True)
            return destination
        finally:
            release_lock(lock)


def main():
    parser = argparse.ArgumentParser(description="Start the bundled webcam tracker")
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--parent-stdin", action="store_true")
    parser.add_argument("--session-file", type=Path)
    args = parser.parse_args()
    path = args.session_file or tracker.gaze_path()

    stop_event = threading.Event()

    def report(code):
        if args.session_file is not None and not stop_event.is_set():
            try:
                tracker.publish_text(path, "status|" + code)
            except OSError as exc:
                print(f"Could not write webcam status: {exc}", file=sys.stderr)

    if args.parent_stdin:
        threading.Thread(target=tracker.watch_parent, args=(stop_event,), daemon=True).start()
    try:
        if not args.prepare_only:
            report("setup")
        packages = prepare_packages(stop_event)
        if args.prepare_only or stop_event.is_set():
            return 0
        sys.path.insert(0, str(packages))
    except PreparationStopped:
        return 0
    except (OSError, ValueError, zipfile.BadZipFile) as exc:
        report("install")
        print(f"Webcam setup failed: {exc}", file=sys.stderr)
        return 1

    report("opening")
    return tracker.run(0, path, "msmf", stop_event, choices=CAMERAS, report=report)


if __name__ == "__main__":
    sys.exit(main())
