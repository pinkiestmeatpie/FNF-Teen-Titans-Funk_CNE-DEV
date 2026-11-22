import Sys;
import Date;
import sys.io.File;
import sys.FileSystem;

// A separately launched tracker writes coordinates only. Nothing opens a camera here.
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
    var fallback = {x: 0.0, y: 0.0, active: false};
    try {
        var path = gazeFile();
        if (!FileSystem.exists(path)) return fallback;
        var fields = File.getContent(path).split("|");
        if (fields.length != 6 || fields[0] != "1" || fields[2] != "1") return fallback;
        var age = Date.now().getTime() / 1000 - Std.parseFloat(fields[1]);
        if (!Math.isFinite(age) || age < -1 || age > 1) return fallback;
        var x:Float = Std.parseFloat(fields[3]);
        var y:Float = Std.parseFloat(fields[4]);
        if (!Math.isFinite(x) || !Math.isFinite(y)) return fallback;
        return {x: Math.max(-1, Math.min(1, x)), y: Math.max(-1, Math.min(1, y)), active: true};
    } catch (error:Dynamic) {
        return fallback;
    }
}
