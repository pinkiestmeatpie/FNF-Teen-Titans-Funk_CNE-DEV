<!-- coderabbit-ai-generated:v1 -->

# Webcam eyes demo

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:eb5cde3921dbf0ad6ee6ab1c18d4ab2b355ebc7dfe4d3cf078cc5e3f673a325d -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:677b93cfd66e674b93f2596d3d4943643ff98bb17e858cb09d0b598796e961e4 -->

The demo follows the position of your face in the webcam image. It does not measure where your eyes are looking. The camera is **off by default**. The Freeplay secret starts the tracker when activated and closes it when the sequence ends or the game exits. Frames are processed locally and never sent to the game or saved. The tracker writes only a timestamp, face position and status to a temporary file.

<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:e68acc43bcca730b9b3091a96e770735873cb5fdf5e0ac126a863ddbe65d3dc7 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:508d6b83f3ca2f4c04193990d8aed084fb73bf2bd9d617ff7e706f88fd2f6041 -->

## Windows automatic setup

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:a049641d66f00f1bd46cb0b08b60c17d94b14c22ae1f0121472db90ddbcbf4d3 -->

On Windows x64, keep the mod as an extracted folder. The Freeplay secret uses the existing `.venv-webcam` when present; otherwise it prepares bundled camera libraries in the background. Typing the secret starts the camera without a terminal or a separate Python installation. The camera is released when the secret ends or the game exits. Windows camera access must be enabled.

<!-- /coderabbit-ai-generated:v1 -->

## Manual demo and other systems

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:b1eb82df64fb92a1bebb9db736f9b47800786e44091a34c0166b2d44d872fbc2 -->

On Windows x64, press **F8** on the mod’s main menu to open a live webcam test with the same automatic setup as Freeplay. The test tells you when it detects a face or can’t read from a camera. Press **Escape** to close it. On macOS and Linux, use the setup below.

<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->

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
<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:a20f648da161f5bd13f800f38e94967147db66e9db95eb5739491a960bbe9b30 -->

3. Stop a manually started tracker with **Ctrl+C** in its terminal to release the camera. Closing or leaving the game does not stop a tracker you started yourself.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:19bd772cbd74d534ce23eb63ee495f50121c60c10074fbd5f0691556b42c8403 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:becdfc957f4305002fe885c55a7c63c2492b4c0fce4df27dc5f66d5a5d826d13 -->

For automatic tracking during the Freeplay secret on macOS and Linux, keep the mod as an extracted folder, complete the Python environment and dependency installation above inside that folder, then close the manually started tracker. The game uses that environment when the secret starts. If a tracker is already running, the game uses it and leaves it under your control.

<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->

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

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:fca325f3bd318e788fa927b7390384c23676df84d4612dea8f6438fcf4483243 -->

The demo in `data/states/TTF/WebcamEyesDemo.hx` is a working example. Its `eyeSmoothing` value controls how quickly the pupils move: smaller values look smoother but respond more slowly. `faceLossGrace` is the time in seconds to hold the last position after a missed detection before returning to center.

In another state or song script, create and load `Script.create(Paths.script("data/scripts/WebcamGaze"))`, then call `readGaze` on it periodically. The result has `x` and `y` in the range -1 to 1, and `active` indicates a fresh face detection. Smooth the values over time and use them as small offsets for separate pupil sprites; call `destroy()` on the script when finished.

<!-- /coderabbit-ai-generated:v1 -->

A character with eyes painted into a single sprite needs artwork with separate pupils and matching eye whites, positioned and synchronized for each animation frame. Keep pupils inside the eye shapes and adjust the movement range for the art. No existing character artwork has been changed by this demo.
