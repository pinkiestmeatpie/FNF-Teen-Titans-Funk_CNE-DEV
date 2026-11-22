<!-- coderabbit-ai-generated:v1 -->

# Bundled Windows webcam runtime

The Windows x64 build is self-contained and does not download or install software when it runs. `runtime/` contains the official [Python 3.14.4 embeddable distribution](https://www.python.org/downloads/release/python-3144/), distributed under the Python Software Foundation License; its license is in `runtime/LICENSE.txt`. The original archive SHA-256 is `cda80a9b1e75c0f1b4f9872ca1b417f0d19bce32facc811aea9180e70fad5fb9`.

`packages/` contains the official Windows x64 wheels for [NumPy 2.5.5](https://pypi.org/project/numpy/2.5.5/) (BSD license and bundled library notices) and [opencv-python-headless 4.14.0.94](https://pypi.org/project/opencv-python-headless/4.14.0.94/) (Apache 2.0 and bundled library notices). Their license files remain inside each wheel and are extracted with it. `launcher.py` verifies the wheel SHA-256 values before extracting them to the current user's local application data cache.

The game prepares the cache without opening the camera when Freeplay opens. On secret activation, the launcher uses the bundled runtime and Media Foundation to start tracking. The helper watches the game process's input pipe and exits when the sequence ends or the game closes. No camera frames leave the machine.
