<!-- coderabbit-ai-generated:v1 -->

# Webcam eyes demo

The demo follows the position of your face in the webcam image. It does not measure where your eyes are looking. The camera is **off by default**; it is opened only when you launch the separate tracker. Frames are processed locally and never sent to the game or saved. The tracker writes only a timestamp, face position and status to a temporary file.

## Try it

1. Install Python 3 and open a terminal in this mod folder. Create an environment and install the tracker dependency:

   **Windows (PowerShell)**

   ```powershell
   py -m venv .venv-webcam
   .\.venv-webcam\Scripts\python -m pip install -r tools/webcam-gaze/requirements.txt
   .\.venv-webcam\Scripts\python tools/webcam-gaze/tracker.py
   ```

   **macOS / Linux**

   ```sh
   python3 -m venv .venv-webcam
   .venv-webcam/bin/python -m pip install -r tools/webcam-gaze/requirements.txt
   .venv-webcam/bin/python tools/webcam-gaze/tracker.py
   ```

2. Grant camera access if your operating system asks. Start Codename Engine with this mod and press **F8** on its main menu. Move your face left, right, up and down. Escape returns to the menu.
3. Stop the tracker with **Ctrl+C** in its terminal to release the camera. Closing or leaving the game does not stop the separate tracker.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:db19df69234f0fbea3cbcccad3e2959834604b63add6912efa59e39487b9750e -->

If the camera is unavailable, the eyes stay centered. Try a different camera with `--camera 1` (or another camera index), check OS camera permissions, and make sure another application has not taken exclusive access. On Windows, if the default camera backend cannot open the device, try `--backend msmf` or `--backend dshow`, for example:

```powershell
.\.venv-webcam\Scripts\python tools/webcam-gaze/tracker.py --backend msmf
```

Good lighting and a front-facing face improve detection. The demo runs without the tracker, and stale or missing samples fall back to centered eyes.

<!-- /coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:87e640fe55382d72c476f4c420196204dddaebaeb58058bebc6dec35d3678901 -->

The tracker and game must run on the same computer and use the same `TMPDIR`, `TEMP`, and `TMP` settings. By default they use `ttf-webcam-gaze.txt` in the first of those directories that is set, or `/tmp` on Unix and the working directory on Windows when none is set. To choose another path, set the same `TTF_GAZE_FILE` environment variable to an absolute file path in **both processes** before starting them. The directory must already exist. Run only one tracker per file.

<!-- /coderabbit-ai-generated:v1 -->

## Use it with a character

The demo in `data/states/TTF/WebcamEyesDemo.hx` is a working example. In another state or song script, create and load `Script.create(Paths.script("data/scripts/WebcamGaze"))`, then call `readGaze` on it periodically. The result has `x` and `y` in the range -1 to 1, and `active` indicates a fresh face detection. Smooth the values over time and use them as small offsets for separate pupil sprites; call `destroy()` on the script when finished.

A character with eyes painted into a single sprite needs artwork with separate pupils and matching eye whites, positioned and synchronized for each animation frame. Keep pupils inside the eye shapes and adjust the movement range for the art. No existing character artwork has been changed by this demo.
