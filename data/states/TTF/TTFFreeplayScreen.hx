// thank you superkoolraven :P
import funkin.backend.MusicBeatState;
import funkin.menus.FreeplaySonglist;
import funkin.backend.Paths;
import funkin.backend.CoolUtil;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;

var songs:Array<Any> = [];
var curSelected:Int = 0;
var prevSelected:Int = -1;
var songL:FlxTypedGroup<FlxText> = [];
var uiCamera:FlxCamera;
var cover:FlxSprite;

//function beatHit() FlxG.camera.zoom += 0.02;

function create() {
	var songList = FreeplaySonglist.get();
	songs = songList.songs;

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
	cover.loadGraphic(Paths.image('covers/' + songs[curSelected].name));
	if (cover.graphic == null) {
		cover.makeGraphic(200, 200, FlxColor.GRAY);
	}
	add(cover);
}

function update(elapsed:Float) {
	if (controls.UP_P) curSelected--;
	if (controls.DOWN_P) curSelected++;
	if (curSelected < 0) curSelected = songs.length - 1;
	if (curSelected >= songs.length) curSelected = 0;

	if (curSelected != prevSelected) {
		FlxG.sound.play(Paths.sound('scroll2'));
		cover.loadGraphic(Paths.image('covers/' + songs[curSelected].name));
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

	if (controls.ACCEPT) {
		PlayState.loadSong(songs[curSelected].name, "hard", false, false);
		FlxG.switchState(new PlayState());
	}
	if (controls.BACK) {
		FlxG.switchState(new MainMenuState());
	}
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
