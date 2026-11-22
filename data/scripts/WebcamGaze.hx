import funkin.backend.assets.ModsFolder;
import Sys;
import Date;
import sys.io.File;
import sys.FileSystem;
import sys.io.Process;

var trackerProcess:Process;
var preparationProcess:Process;
var sessionFile:String;
var startupError:String;
var startedAt:Float = 0;

// The tracker writes coordinates only. It opens the camera when explicitly started.
function gazeFile() {
    var path = Sys.getEnv("TTF_GAZE_FILE");
    if (path != null && path != "") return path;
    var dir = Sys.getEnv("TMPDIR");
    if (dir == null || dir == "") dir = Sys.getEnv("TEMP");
    if (dir == null || dir == "") dir = Sys.getEnv("TMP");
    if (dir == null || dir == "") dir = Sys.systemName() == "Windows" ? "." : "/tmp";
    return dir + "/ttf-webcam-gaze.txt";
}

// Returns screen-relative face coordinates in [-1, 1], or a centered fallback.
function readGaze() {
    return readSample(gazeFile());
}

function readSample(path:String, session:Bool = false) {
    var fallback = {x: 0.0, y: 0.0, active: false, running: false, status: null};
    try {
        if (!FileSystem.exists(path)) return fallback;
        var fields = File.getContent(path).split("|");
        if (session && fields.length == 2 && fields[0] == "status") {
            fallback.status = fields[1];
            return fallback;
        }
        if (fields.length != 6 || fields[0] != "1" || (fields[2] != "0" && fields[2] != "1")) return fallback;
        var age = Date.now().getTime() / 1000 - Std.parseFloat(fields[1]);
        if (!Math.isFinite(age) || age < -1 || age > 1) return fallback;
        if (fields[2] == "0") return {x: 0.0, y: 0.0, active: false, running: true, status: null};
        var x:Float = Std.parseFloat(fields[3]);
        var y:Float = Std.parseFloat(fields[4]);
        if (!Math.isFinite(x) || !Math.isFinite(y)) return fallback;
        return {x: Math.max(-1, Math.min(1, x)), y: Math.max(-1, Math.min(1, y)), active: true, running: true, status: null};
    } catch (error:Dynamic) {
        return fallback;
    }
}

function modRoot():String {
    var root = ModsFolder.modsPath;
    var lastChar = root.charAt(root.length - 1);
    if (lastChar != "/" && lastChar != "\\") root += "/";
    return FileSystem.fullPath(root + ModsFolder.currentModFolder);
}

function prepareWebcam() {
    if (Sys.systemName() != "Windows" || ModsFolder.currentModFolder == null) return;
    try {
        var root = modRoot() + "/tools/webcam-gaze";
        if (FileSystem.exists(modRoot() + "/.venv-webcam/Scripts/python.exe")) return;
        var python = root + "/windows/runtime/python.exe";
        var launcher = root + "/windows/launcher.py";
        if (FileSystem.exists(python) && FileSystem.exists(launcher))
            preparationProcess = new Process(python, [launcher, "--prepare-only", "--parent-stdin"]);
    } catch (error:Dynamic) {
        trace("Webcam preparation could not start: " + error);
    }
}

function startWebcam() {
    // A separately started tracker remains owned by the player.
    if (readGaze().running) return;
    startedAt = Date.now().getTime();
    var system = Sys.systemName();
    if (ModsFolder.currentModFolder == null || (system != "Windows" && system != "Linux" && system != "Mac")) {
        startupError = "Webcam needs the desktop game with the mod selected.";
        return;
    }
    try {
        var root = modRoot();
        var python = root + (system == "Windows" ? "/.venv-webcam/Scripts/python.exe" : "/.venv-webcam/bin/python");
        var tracker = root + "/tools/webcam-gaze/tracker.py";
        if (FileSystem.exists(python) && FileSystem.exists(tracker)) {
            // Keep the venv path: resolving its symlink can bypass the venv.
            sessionFile = FileSystem.absolutePath(gazeFile()) + "." + startedAt + "." + Std.int(Math.random() * 1000000000);
            trackerProcess = new Process(python, [tracker, "--backend", system == "Windows" ? "msmf" : "auto", "--parent-stdin", "--session-file", sessionFile]);
            return;
        }
        var bundledPython = root + "/tools/webcam-gaze/windows/runtime/python.exe";
        var launcher = root + "/tools/webcam-gaze/windows/launcher.py";
        if (system == "Windows" && FileSystem.exists(bundledPython) && FileSystem.exists(launcher)) {
            sessionFile = FileSystem.absolutePath(gazeFile()) + "." + startedAt + "." + Std.int(Math.random() * 1000000000);
            trackerProcess = new Process(bundledPython, [launcher, "--parent-stdin", "--session-file", sessionFile]);
            return;
        }
        startupError = system == "Windows" ? "Webcam files missing. Extract the full updated mod." : "Waiting for the optional webcam tracker.";
    } catch (error:Dynamic) {
        startupError = "Webcam helper could not launch. Check whether Windows blocked it.";
        trace("Webcam tracker could not start: " + error);
    }
}

function pollWebcam() {
    var gaze = sessionFile == null ? readGaze() : readSample(sessionFile, true);
    if (gaze.active) return {gaze: gaze, message: "Face detected."};
    if (gaze.running) return {gaze: gaze, message: "Camera on. Look toward it in good light."};
    var waiting = Date.now().getTime() - startedAt < 8000;
    var message = startupError;
    if (message == null) {
        message = switch (gaze.status) {
            case "setup": waiting ? "Preparing webcam..." : "Webcam setup is taking longer than expected.";
            case "opening": waiting ? "Opening webcam..." : "Webcam is taking too long to respond.";
            case "camera": "No camera frames. Check Windows camera access and close other camera apps.";
            case "frames": "Camera stopped sending frames.";
            case "install": "Webcam setup failed. Extract the full updated mod and check disk space.";
            case "library": "Webcam libraries could not load.";
            case "output": "Webcam could not share its face position with the game.";
            default: waiting ? "Starting webcam..." : "Webcam helper didn't respond. Check whether Windows blocked it.";
        };
    }
    return {gaze: gaze, message: message};
}

function stopWebcam() {
    // Closing the owned pipe tells the tracker to release the camera.
    if (trackerProcess != null) {
        trackerProcess.close();
        trackerProcess = null;
    }
    if (preparationProcess != null) {
        preparationProcess.close();
        preparationProcess = null;
    }
    if (sessionFile != null) {
        try {
            if (FileSystem.exists(sessionFile)) FileSystem.deleteFile(sessionFile);
        } catch (error:Dynamic) {}
        sessionFile = null;
    }
}
