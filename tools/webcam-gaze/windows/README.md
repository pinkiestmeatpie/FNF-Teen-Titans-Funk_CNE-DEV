<!-- coderabbit-ai-generated:v1 -->

# Bundled Windows webcam runtime

The Windows x64 build is self-contained and does not download or install software when it runs. `runtime/` contains the official [Python 3.14.4 embeddable distribution](https://www.python.org/downloads/release/python-3144/), distributed under the Python Software Foundation License; its license is in `runtime/LICENSE.txt`. The original archive SHA-256 is `cda80a9b1e75c0f1b4f9872ca1b417f0d19bce32facc811aea9180e70fad5fb9`.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:6060b5f58e1b68e78c91a028fa18ed1ed18c1bd85b31fbf076fdc779597f1b54 -->

`packages/` contains the official Windows x64 wheels for [NumPy 2.5.5](https://pypi.org/project/numpy/2.5.5/) (BSD license and bundled library notices) and [opencv-python 4.14.0.94](https://pypi.org/project/opencv-python/4.14.0.94/) (Apache 2.0 and bundled library notices). Their license files remain inside each wheel and are extracted with it. `launcher.py` verifies the wheel SHA-256 values before extracting them to the current user's local application data cache.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:a28299b45b1ad4e9c376f8ec1f05c6da6c8bdaa865902e27694a548d26d7ebc2 -->

When no local `.venv-webcam` is installed, the game prepares the bundled cache without opening the camera when Freeplay opens. If `.venv-webcam` exists, the game starts its tracker with the MSMF backend.

<!-- /coderabbit-ai-generated:v1 --> When you press F8 on the main menu or activate the Freeplay secret, the launcher tries Media Foundation first and falls back to DirectShow and a second camera index. The regular OpenCV wheel includes both Windows backends. The F8 screen shows whether setup succeeded, the camera opened, and a face was detected. The helper watches the game process's input pipe and exits when the sequence ends or the game closes. No camera frames leave the machine.

<!-- /coderabbit-ai-generated:v1 -->
