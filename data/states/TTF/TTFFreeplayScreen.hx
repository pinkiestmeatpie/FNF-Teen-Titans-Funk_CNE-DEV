// thank you superkoolraven :P
import funkin.backend.MusicBeatState;
import funkin.menus.FreeplaySonglist;
import funkin.backend.Paths;
import funkin.backend.CoolUtil;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import funkin.backend.scripting.Script;

var songs:Array<Any> = [];
var curSelected:Int = 0;
var prevSelected:Int = -1;
var songL:FlxTypedGroup<FlxText> = [];
var uiCamera:FlxCamera;
var cover:FlxSprite;
var pupil:FlxSprite;
var gazeScript:Script;
var secretKeys:Array<Int> = [82, 69, 71, 82, 69, 84]; // REGRET
var secretProgress:Int = 0;
var secretActive:Bool = false;
var secretTime:Float = 0;
var gazePollTimer:Float = 0;
var faceDetected:Bool = false;
var faceMissingFor:Float = 0;
var targetX:Float = 0;
var targetY:Float = 0;
var lookX:Float = 0;
var lookY:Float = 0;
static var ttfRegretReturnToDrivebot:Bool = false;

//function beatHit() FlxG.camera.zoom += 0.02;

function create() {
	CoolUtil.playMenuSong();
	var songList = FreeplaySonglist.get();
	songs = songList.songs;
	if (ttfRegretReturnToDrivebot) {
		for (i in 0...songs.length) {
			if (matchesDrivebot(songs[i])) {
				curSelected = i;
				break;
			}
		}
		ttfRegretReturnToDrivebot = false;
	}

	var bg = new FlxSprite(FlxG.width, FlxG.height, FlxColor.BLACK);
	add(bg);

	uiCamera = new FlxCamera(0, 0, 1280, 720);
	uiCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(uiCamera, false);

	for (i in 0...songs.length) {
		var text = new FlxText();
		text.text = songs[i].displayName;
		text.setFormat(Paths.font('comm.ttf'), null, FlxColor.YELLOW);
		text.size = 90;
		text.x = 50;
		//text.screenCenter();
		text.y = (125 * i) + 100;
		text.cameras = [uiCamera];
		songL.push(text);
		add(text);
	}

	cover = new FlxSprite(FlxG.width - 300, 100);
	cover.x = 700;
	cover.y = -50;
	cover.loadGraphic(Paths.image(isDrivebot() ? 'covers/drivebot' : 'covers/' + songs[curSelected].name));
	if (cover.graphic == null) {
		cover.makeGraphic(200, 200, FlxColor.GRAY);
	}
	add(cover);

	pupil = new FlxSprite().loadGraphic(Paths.image('covers/drivebot-alt-pupil'));
	pupil.setGraphicSize(FlxG.width, FlxG.height);
	pupil.updateHitbox();
	pupil.visible = false;
	add(pupil);
}

function update(elapsed:Float) {
	if (secretActive) {
		updateSecret(elapsed);
		return;
	}

	if (controls.UP_P) curSelected--;
	if (controls.DOWN_P) curSelected++;
	if (curSelected < 0) curSelected = songs.length - 1;
	if (curSelected >= songs.length) curSelected = 0;

	if (curSelected != prevSelected) {
		secretProgress = 0;
		FlxG.sound.play(Paths.sound('scroll2'));
		cover.scale.set(1, 1);
		cover.x = 700;
		cover.y = -50;
		if (isDrivebot()) {
			cover.loadGraphic(Paths.image('covers/drivebot'));
			cover.setGraphicSize(FlxG.width, FlxG.height);
			cover.x = cover.y = 0;
		} else {
			cover.loadGraphic(Paths.image('covers/' + songs[curSelected].name));
		}
		cover.updateHitbox();
		if (cover.graphic == null) {
			cover.makeGraphic(200, 200, FlxColor.GRAY);
		}
		prevSelected = curSelected;
	}

	for (i in 0...songL.length) {
		songL[i].alpha = 0.6;
	}
	songL[curSelected].alpha = 1;
	//uiCamera.follow(songL[curSelected], 0.5);

	if (isDrivebot()) {
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

	if (controls.ACCEPT) {
		PlayState.loadSong(songs[curSelected].name, "hard", false, false);
		FlxG.switchState(new PlayState());
	}
	if (controls.BACK) {
		FlxG.switchState(new MainMenuState());
	}
}

function isDrivebot():Bool {
	return matchesDrivebot(songs[curSelected]);
}

function matchesDrivebot(song):Bool {
	return song != null && ((song.name != null && song.name.toLowerCase() == 'drivebot') ||
		(song.displayName != null && song.displayName.toLowerCase() == 'drivebot'));
}

function startSecret() {
	secretActive = true;
	secretTime = 0;
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	cover.loadGraphic(Paths.image('covers/drivebot-alt'));
	cover.setGraphicSize(FlxG.width, FlxG.height);
	cover.updateHitbox();
	cover.x = cover.y = 0;
	pupil.x = pupil.y = 0;
	pupil.visible = true;
	gazeScript = Script.create(Paths.script('data/scripts/WebcamGaze'));
	gazeScript.load();
}

function updateSecret(elapsed:Float) {
	secretTime += elapsed;
	if (secretTime >= 15) {
		PlayState.loadSong('HYPNOTIZED', 'hard', false, false);
		ttfRegretReturnToDrivebot = true;
		FlxG.switchState(new PlayState());
		return;
	}

	gazePollTimer -= elapsed;
	if (gazePollTimer <= 0) {
		gazePollTimer = 0.1;
		var gaze = gazeScript.call('readGaze');
		faceDetected = gaze != null && gaze.active;
		if (faceDetected) {
			targetX = gaze.x;
			targetY = gaze.y;
			faceMissingFor = 0;
		}
	}
	if (!faceDetected) {
		faceMissingFor += elapsed;
		if (faceMissingFor >= 0.45) targetX = targetY = 0;
	}
	var amount = 1 - Math.exp(-4 * elapsed);
	lookX += (targetX - lookX) * amount;
	lookY += (targetY - lookY) * amount;
	// The supplied pupil and eye are aligned at 1920x1080. Keep the pupil inside the sclera.
	pupil.x = lookX * (10 * FlxG.width / 1920);
	pupil.y = lookY * (10 * FlxG.height / 1080);
}

function destroy() {
	if (gazeScript != null) gazeScript.destroy();
}

/*
// clock (not mine!)
import Date;
var timeFormat12h:Bool = true; //the illusion of choice
function postCreate() {
    timeTxt = new FunkinText(0, FlxG.height - 700, 2000, "X:XX", 32, true);
	timeTxt.setFormat(Paths.font('comm.ttf'), 50, FlxColor.YELLOW);
    timeTxt.borderSize = 2;
    timeTxt.alignment = "center";
    timeTxt.scrollFactor.set();
    timeTxt.updateHitbox();
    add(timeTxt);
}
function update(elapsed:Float) {
    var theDate = Date.now();
	var hours = theDate.getHours();
    var minutes = theDate.getMinutes();
    var seconds = theDate.getSeconds();

    if (timeFormat12h){
        //24 hr system haters gonna cry
        if (hours >= 12) {			
            hours -= 12;
        }
    }
	var formattedTime = (hours < 10 ? "0" : "" ) + hours + ":" + (minutes < 10 ? "0" : "" ) + minutes + ":" + (seconds < 10 ? "0" : "" ) + seconds + " " + (timeFormat12h ? (hours >= 12 ? "AM" : "PM") : "" );
	timeTxt.text = formattedTime;
}
	*/
