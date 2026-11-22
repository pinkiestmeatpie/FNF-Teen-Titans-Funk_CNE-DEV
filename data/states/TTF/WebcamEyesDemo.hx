import funkin.backend.scripting.Script;
import funkin.menus.MainMenuState;

var gazeScript:Script;
var irisLeft:FlxSprite;
var irisRight:FlxSprite;
var statusText:FlxText;
var targetX:Float = 0;
var targetY:Float = 0;
var lookX:Float = 0;
var lookY:Float = 0;
var pollTimer:Float = 0;
// Lower smoothing speeds make movement gentler, but slower to respond.
var eyeSmoothing:Float = 4;
// Hold the last position briefly when the detector misses a face.
var faceLossGrace:Float = 0.45;
var faceMissingFor:Float = 0;
var faceDetected:Bool = false;

function create() {
    FlxG.camera.bgColor = 0xFF171322;
    var heading = new FlxText(0, 70, FlxG.width, "WEBCAM EYES", 32);
    heading.setFormat(null, 32, FlxColor.WHITE, "center");
    add(heading);

    var leftEye = new FlxSprite(390, 260).loadGraphic(Paths.image("webcam-gaze/eye"));
    var rightEye = new FlxSprite(690, 260).loadGraphic(Paths.image("webcam-gaze/eye"));
    add(leftEye);
    add(rightEye);
    irisLeft = new FlxSprite(475, 305).loadGraphic(Paths.image("webcam-gaze/iris"));
    irisRight = new FlxSprite(775, 305).loadGraphic(Paths.image("webcam-gaze/iris"));
    add(irisLeft);
    add(irisRight);

    statusText = new FlxText(0, 495, FlxG.width, "Starting webcam...", 20);
    statusText.setFormat(null, 20, FlxColor.WHITE, "center");
    add(statusText);
    var help = new FlxText(0, 545, FlxG.width, "Move your face to test tracking.\nPress Escape to return.", 16);
    help.setFormat(null, 16, 0xFFBDB3CE, "center");
    add(help);

    gazeScript = Script.create(Paths.script("data/scripts/WebcamGaze"));
    gazeScript.load();
    gazeScript.call("startWebcam");
}

function update(elapsed:Float) {
    if (controls.BACK) {
        FlxG.switchState(new MainMenuState());
        return;
    }
    pollTimer -= elapsed;
    if (pollTimer <= 0) {
        pollTimer = 0.1;
        var webcam = gazeScript.call("pollWebcam");
        var gaze = webcam == null ? null : webcam.gaze;
        faceDetected = gaze != null && gaze.active;
        if (faceDetected) {
            targetX = gaze.x;
            targetY = gaze.y;
            faceMissingFor = 0;
        }
        if (webcam != null) statusText.text = webcam.message;
    }
    if (!faceDetected) {
        faceMissingFor += elapsed;
        if (faceMissingFor >= faceLossGrace) {
            targetX = 0;
            targetY = 0;
        }
    }
    var amount = 1 - Math.exp(-eyeSmoothing * elapsed);
    lookX += (targetX - lookX) * amount;
    lookY += (targetY - lookY) * amount;
    irisLeft.setPosition(475 + lookX * 48, 305 + lookY * 24);
    irisRight.setPosition(775 + lookX * 48, 305 + lookY * 24);
}

function destroy() {
    if (gazeScript != null) {
        gazeScript.call("stopWebcam");
        gazeScript.destroy();
    }
}
