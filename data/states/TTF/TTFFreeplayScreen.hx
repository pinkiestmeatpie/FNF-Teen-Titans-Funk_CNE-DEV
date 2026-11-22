import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.backend.scripting.Script;
import funkin.backend.assets.ModsFolder;
import Sys;
import sys.FileSystem;
import sys.io.Process;

var songs:Array<Dynamic> = [];
var selected:Int = 0;
var difficulty:Int = 0;
var rows:Array<FlxText> = [];
var cover:FlxSprite;
var coverLabel:FlxText;
var diffLabel:FlxText;
var leaving:Bool = false;
var pupil:FlxSprite;
var gazeScript:Script;
var trackerProcess:Process;
var webcamNotice:FlxText;
var secretKeys:Array<Int> = [82, 69, 71, 82, 69, 84]; // REGRET
var secretProgress:Int = 0;
var secretActive:Bool = false;
var secretTime:Float = 0;
var gazePollTimer:Float = 0;
var trackerResponding:Bool = false;
var trackerMissingFor:Float = 0;
var faceDetected:Bool = false;
var faceMissingFor:Float = 0;
var targetX:Float = 0;
var targetY:Float = 0;
var lookX:Float = 0;
var lookY:Float = 0;
static var ttfRegretReturnToAbc:Bool = false;
static var ttfRegretReturnDifficulty:Int = 0;

function create() {
    CoolUtil.playMenuSong();
    songs = FreeplaySonglist.get().songs;
    if (ttfRegretReturnToAbc) {
        for (i in 0...songs.length) {
            if (isAbc(songs[i])) {
                selected = i;
                if (songs[i].difficulties.length > 0)
                    difficulty = Std.int(Math.min(ttfRegretReturnDifficulty, songs[i].difficulties.length - 1));
                break;
            }
        }
        ttfRegretReturnToAbc = false;
        ttfRegretReturnDifficulty = 0;
    }
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
    var heading = new FlxText(55, 45, 560, 'FREEPLAY', 36);
    heading.setFormat(Paths.font('comm.ttf'), 36, FlxColor.WHITE, 'left');
    add(heading);
    for (i in 0...5) {
        var row = new FlxText(65, 135 + i * 75, 570, '', 38);
        row.setFormat(Paths.font('comm.ttf'), 38, 0xFFFFFF00, 'left');
        rows.push(row);
        add(row);
    }
    add(new FlxSprite(690, 85).makeGraphic(525, 510, 0xFF252525));
    cover = new FlxSprite();
    add(cover);
    pupil = new FlxSprite().loadGraphic(Paths.image('covers/drivebot-alt-pupil'));
    pupil.visible = false;
    add(pupil);
    coverLabel = new FlxText(710, 315, 485, 'SONG COVER', 30);
    coverLabel.setFormat(Paths.font('comm.ttf'), 30, 0xFFAAAAAA, 'center');
    add(coverLabel);
    diffLabel = new FlxText(55, 570, 570, '', 24);
    diffLabel.setFormat(Paths.font('comm.ttf'), 24, FlxColor.WHITE, 'left');
    add(diffLabel);
    webcamNotice = new FlxText(55, 615, 1170, 'Webcam unavailable. Check the tracker setup and camera permission.', 16);
    webcamNotice.setFormat(Paths.font('comm.ttf'), 16, 0xFFAAAAAA, 'center');
    webcamNotice.visible = false;
    add(webcamNotice);
    var hint = new FlxText(55, 655, 1170, 'UP / DOWN: SONG    LEFT / RIGHT: DIFFICULTY    ENTER: PLAY    ESC: BACK', 19);
    hint.setFormat(Paths.font('comm.ttf'), 19, 0xFFAAAAAA, 'center');
    add(hint);
    refresh(true);
}
function refresh(animateCover:Bool) {
    if (songs.length == 0) {
        rows[0].text = 'NO SONGS FOUND';
        cover.visible = false;
        diffLabel.text = '';
        return;
    }
    var first = Std.int(Math.max(0, Math.min(selected - 2, songs.length - 5)));
    for (i in 0...rows.length) {
        var index = first + i;
        rows[i].text = index < songs.length ? (index == selected ? '> ' : '  ') + songs[index].displayName.toUpperCase() : '';
        rows[i].alpha = index == selected ? 1 : 0.6;
    }
    var diffs = songs[selected].difficulties;
    diffLabel.text = diffs.length > 0 ? '<  ' + diffs[difficulty].toUpperCase() + '  >' : 'NO CHART AVAILABLE';
    if (!animateCover) return;
    FlxTween.cancelTweensOf(cover);
    FlxTween.cancelTweensOf(coverLabel);
    var coverPath = Paths.image('covers/' + songs[selected].name.toLowerCase());
    if (Assets.exists(coverPath)) {
        cover.scale.set(1, 1);
        cover.loadGraphic(coverPath);
        cover.updateHitbox();
        var scale = Math.min(485 / cover.width, 470 / cover.height);
        cover.setGraphicSize(Std.int(cover.width * scale), Std.int(cover.height * scale));
        cover.updateHitbox();
        cover.x = FlxG.width + 16;
        FlxTween.tween(cover, {x: 952 - cover.width / 2}, 0.36, {ease: FlxEase.cubicOut});
        cover.y = 340 - cover.height / 2;
        cover.visible = true;
        coverLabel.visible = false;
    } else {
        cover.visible = false;
        coverLabel.visible = true;
        coverLabel.x = FlxG.width + 16;
        FlxTween.tween(coverLabel, {x: 710}, 0.36, {ease: FlxEase.cubicOut});
    }
}
function update(elapsed:Float) {
    if (leaving) return;
    if (secretActive) {
        updateSecret(elapsed);
        return;
    }
    var change = 0;
    if (controls.UP_P) change = -1;
    if (controls.DOWN_P) change = 1;
    if (change != 0 && songs.length > 1) {
        selected = FlxMath.wrap(selected + change, 0, songs.length - 1);
        secretProgress = 0;
        difficulty = 0;
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh(true);
    }
    change = 0;
    if (controls.LEFT_P) change = -1;
    if (controls.RIGHT_P) change = 1;
    if (change != 0 && songs.length > 0 && songs[selected].difficulties.length > 1) {
        difficulty = FlxMath.wrap(difficulty + change, 0, songs[selected].difficulties.length - 1);
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh(false);
    }
    if (songs.length > 0 && isAbc(songs[selected])) {
        var key:Int = FlxG.keys.firstJustPressed();
        if (key >= 65 && key <= 90) {
            if (key == secretKeys[secretProgress]) secretProgress++;
            else secretProgress = key == secretKeys[0] ? 1 : 0;
            if (secretProgress == secretKeys.length) {
                startSecret();
                return;
            }
        }
    }
    if (controls.BACK) {
        leaving = true;
        FlxG.switchState(new MainMenuState());
    } else if (controls.ACCEPT && songs.length > 0 && songs[selected].difficulties.length > 0) {
        leaving = true;
        Options.freeplayLastSong = songs[selected].name;
        Options.freeplayLastDifficulty = songs[selected].difficulties[difficulty];
        PlayState.loadSong(songs[selected].name, songs[selected].difficulties[difficulty], false, false);
        FlxG.switchState(new PlayState());
    }
}

function isAbc(song):Bool {
    return song != null && song.name != null && song.name.toLowerCase() == 'abc';
}

function startSecret() {
    secretActive = true;
    secretTime = 0;
    if (FlxG.sound.music != null) FlxG.sound.music.stop();
    FlxTween.cancelTweensOf(cover);
    FlxTween.cancelTweensOf(coverLabel);
    cover.scale.set(1, 1);
    cover.loadGraphic(Paths.image('covers/drivebot-alt'));
    cover.updateHitbox();
    var scale = Math.min(485 / cover.width, 470 / cover.height);
    cover.setGraphicSize(Std.int(cover.width * scale), Std.int(cover.height * scale));
    cover.updateHitbox();
    cover.x = 952 - cover.width / 2;
    cover.y = 340 - cover.height / 2;
    cover.visible = true;
    coverLabel.visible = false;
    pupil.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
    pupil.updateHitbox();
    pupil.setPosition(cover.x, cover.y);
    pupil.visible = true;
    gazeScript = Script.create(Paths.script('data/scripts/WebcamGaze'));
    gazeScript.load();
    startTracker();
}

function startTracker() {
    // A separately started tracker remains owned by the player.
    var existing = gazeScript.call('readGaze');
    if (existing != null && existing.running) return;
    var system = Sys.systemName();
    if (ModsFolder.currentModFolder == null || (system != 'Windows' && system != 'Linux' && system != 'Mac')) {
        webcamNotice.visible = true;
        return;
    }
    try {
        var root = ModsFolder.modsPath;
        var lastChar = root.charAt(root.length - 1);
        if (lastChar != '/' && lastChar != '\\') root += '/';
        root = FileSystem.fullPath(root + ModsFolder.currentModFolder);
        var python = root + (system == 'Windows' ? '/.venv-webcam/Scripts/python.exe' : '/.venv-webcam/bin/python');
        var tracker = root + '/tools/webcam-gaze/tracker.py';
        if (!FileSystem.exists(python) || !FileSystem.exists(tracker)) {
            webcamNotice.visible = true;
            return;
        }
        // Preserve the virtual environment's Python path, which can be a symlink.
        var backend = system == 'Windows' ? 'msmf' : 'auto';
        trackerProcess = new Process(python, [tracker, '--backend', backend, '--parent-stdin']);
    } catch (error:Dynamic) {
        webcamNotice.visible = true;
        trace('Webcam tracker could not start: ' + error);
    }
}

function stopTracker() {
    if (trackerProcess == null) return;
    // Closing the owned process pipes tells the helper to release the camera.
    trackerProcess.close();
    trackerProcess = null;
}

function updateSecret(elapsed:Float) {
    secretTime += elapsed;
    if (secretTime >= 15) {
        stopTracker();
        PlayState.loadSong('hypnotized', 'hard', false, false);
        ttfRegretReturnToAbc = true;
        ttfRegretReturnDifficulty = difficulty;
        leaving = true;
        FlxG.switchState(new PlayState());
        return;
    }
    gazePollTimer -= elapsed;
    if (gazePollTimer <= 0) {
        gazePollTimer = 0.1;
        var gaze = gazeScript.call('readGaze');
        trackerResponding = gaze != null && gaze.running;
        faceDetected = gaze != null && gaze.active;
        if (faceDetected) {
            targetX = gaze.x;
            targetY = gaze.y;
            faceMissingFor = 0;
        }
    }
    if (trackerProcess != null) {
        if (trackerResponding) trackerMissingFor = 0;
        else trackerMissingFor += elapsed;
        webcamNotice.visible = trackerMissingFor >= 4;
    }
    if (!faceDetected) {
        faceMissingFor += elapsed;
        if (faceMissingFor >= 0.45) targetX = targetY = 0;
    }
    var amount = 1 - Math.exp(-4 * elapsed);
    lookX += (targetX - lookX) * amount;
    lookY += (targetY - lookY) * amount;
    // The supplied pupil and eye are aligned at 1920x1080.
    pupil.setPosition(cover.x + lookX * 10 * cover.width / 1920,
        cover.y + lookY * 10 * cover.height / 1080);
}

function destroy() {
    FlxTween.cancelTweensOf(cover);
    FlxTween.cancelTweensOf(coverLabel);
    stopTracker();
    if (gazeScript != null) gazeScript.destroy();
}
