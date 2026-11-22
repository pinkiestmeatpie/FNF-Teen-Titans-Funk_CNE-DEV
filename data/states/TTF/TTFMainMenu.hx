import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.addons.display.FlxBackdrop;
import openfl.display.BlendMode;

import funkin.backend.shaders.FunkinShader;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatTransition;
import funkin.editors.EditorPicker;
import funkin.menus.credits.CreditsMain;
import funkin.menus.FreeplayState;
import funkin.menus.MainMenuState;
import funkin.menus.ModSwitchMenu;
import funkin.menus.TitleState;
import funkin.options.OptionsMenu;
import funkin.backend.shaders.CustomShader;

import Date;

var canAccessDebugMenus:Bool = true;
var options:Array<String> = ['story mode', 'freeplay', 'options', 'credits'];
var charList:Array<String> = ['bf', 'gf', 'pico'];

var transitioning:Bool = false;
var isZoomLerp:Bool = false;
var popupAppear:Bool = false;
var curSelected:Int = 0;
var curSelectLerp:Float = 0;

var adjustColorShader:CustomShader;

var bg:FunkinSprite;
var chessBG:FlxBackdrop;
var lineBottom:FlxSprite;
var lineTop:FlxSprite;
var bgChar:FlxSprite;
var curChar:String;

// popup info
var blackBoxTitle:FlxSprite;
var blackBox:FlxSprite;
var blackTextInfo:FlxText;
var blackText:FlxText;
var popupBg:FlxSprite;

// bisma stuff
var bismaSprite:FlxSprite;
var showBisma:Bool = false;

function create() {
	DiscordUtil.changePresence("In the Menus", null);
	CoolUtil.playMenuSong();

	bg = new FunkinSprite().loadGraphic(Paths.image('menus/mainmenu/bgmenuRamadhan'));
	bg.antialiasing = Options.antialiasing;
	bg.scale.set(0.8, 0.8);
	bg.updateHitbox();
	bg.screenCenter();
	bg.scrollFactor.set(0, 0.3);
	add(bg);

	adjustColorShader = new CustomShader('adjustColor');
	adjustColorShader.hue = 0;
	adjustColorShader.saturation = 0;
	adjustColorShader.contrast = 0;
	adjustColorShader.brightness = 0;
	bg.shader = adjustColorShader;

	chessBG = new FlxBackdrop();
	chessBG.loadGraphic(Paths.image('menus/chess'));
	chessBG.blend = BlendMode.ADD;
	chessBG.velocity.x = -30;
	chessBG.velocity.y = 30;
	chessBG.antialiasing = true;
	chessBG.alpha = 0.1;
	add(chessBG);

	curChar = charList[FlxG.random.int(0, charList.length-1)];
	bgChar = new FlxSprite(1400, 80).loadGraphic(Paths.image('portrait/' + curChar + '-kosan'));
	bgChar.antialiasing = Options.antialiasing;
	bgChar.scale.set(0.69, 0.69);
	bgChar.updateHitbox();
	bgChar.scrollFactor.set(0, 0.5);
	add(bgChar);

	new FlxTimer().start(0.4, () -> bg.skew.set(FlxG.random.float(-0.5, 0.5), FlxG.random.float(-0.5, 0.5)), 0);

	add(menuItems = new FlxSpriteGroup());

	lineBottom = new FlxSprite().loadGraphic(Paths.image('menus/mainmenu/linebottom'));
	lineBottom.antialiasing = Options.antialiasing;
	lineBottom.scale.set(0.69, 0.69);
	lineBottom.updateHitbox();
	lineBottom.screenCenter();
	lineBottom.scrollFactor.set();
	add(lineBottom);

	lineTop = new FlxSprite().loadGraphic(Paths.image('menus/mainmenu/linetop'));
	lineTop.antialiasing = Options.antialiasing;
	lineTop.scale.set(0.69, 0.69);
	lineTop.updateHitbox();
	lineTop.screenCenter();
	lineTop.scrollFactor.set();
	add(lineTop);

	for (i=>option in options) {
		var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
		menuItem.frames = Paths.getFrames('menus/mainmenu/' + option);
		menuItem.animation.addByPrefix('idle', option + " basic", 24);
		menuItem.animation.addByPrefix('selected', option + " white", 24);
		menuItem.animation.play('idle');
		menuItem.scale.set(0.9, 0.9);
		menuItem.ID = i;
		menuItem.screenCenter(FlxAxes.X);
		menuItems.add(menuItem);
		menuItem.scrollFactor.set();
		menuItem.antialiasing = true;
	}
	changeItem(0);

	bismaSprite = new FlxSprite().loadGraphic(Paths.image('bisma'));
	bismaSprite.setGraphicSize(300, 200);
	bismaSprite.updateHitbox();
	bismaSprite.antialiasing = Options.antialiasing;
	bismaSprite.scrollFactor.set();
	bismaSprite.visible = false;
	bismaSprite.screenCenter();
	add(bismaSprite);

	popupBg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
	popupBg.scrollFactor.set();
	//popupBg.alpha = 0.3;

	blackBox = new FlxSprite().makeSolid(540, 300, FlxColor.BLACK);
	blackBox.scrollFactor.set();
	blackBox.screenCenter();
	//blackBox.alpha = 0.5;

	blackBoxTitle = new FlxSprite(blackBox.x, blackBox.y).makeSolid(540, 80, FlxColor.BLACK);
	blackBoxTitle.scrollFactor.set();

	blackTextInfo = new FlxText(blackBoxTitle.x, blackBoxTitle.y + 20, 540, "info");
	blackTextInfo.setFormat(Paths.font("obelix.ttf"), 38, FlxColor.WHITE, 'center');
	blackTextInfo.scrollFactor.set();

	blackText = new FlxText(blackBoxTitle.x, blackBoxTitle.y + 100, 540,
		"Hehe, you're really impatient, aren't you?" +
		"\n\nAs of now the story are still in progress!" +
		"\nFor now, just open the freeplay songs first." + 
		"\n\nPress BACK / ACCEPT to continue"
	);
	blackText.setFormat(Paths.font("montserrat/medium.ttf"), 24, FlxColor.WHITE, 'center');
	blackText.scrollFactor.set();

	var webcamHint = new FlxText(160, 100, 400, "F8: webcam eyes demo", 16);
	webcamHint.scrollFactor.set();
	add(webcamHint);

	FlxTween.tween(FlxG.camera, {zoom: 1.8}, 1.5, {ease: FlxEase.quintOut, type: FlxTweenType.BACKWARD, onComplete: () -> isZoomLerp = true});
	FlxTween.tween(bgChar, {x: 970 - (bgChar.width/2)}, 2.5, {ease: FlxEase.quintOut});
}

var checkBisma:Float = 0;
var timer:Float = 0;
function getRandomColor() return FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
function update(dt) {
	timer += dt;
	bgChar.angle = Math.sin(timer/2) * 3;
	bgChar.updateHitbox();
	bgChar.offset.y -= Math.cos(timer/2) * 15;

	if (showBisma) {
		if (bismaSprite.x < 0) {
			bismaSprite.x = 0; bismaSprite.velocity.x *= -1;
			bismaSprite.color = getRandomColor();
		} else if (bismaSprite.x + bismaSprite.width > FlxG.width) {
			bismaSprite.x = FlxG.width - bismaSprite.width; bismaSprite.velocity.x *= -1;
			bismaSprite.color = getRandomColor();
		}
		if (bismaSprite.y < 0) {
			bismaSprite.y = 0; bismaSprite.velocity.y *= -1;
			bismaSprite.color = getRandomColor();
		} else if (bismaSprite.y + bismaSprite.height > FlxG.height) {
			bismaSprite.y = FlxG.height - bismaSprite.height; bismaSprite.velocity.y *= -1;
			bismaSprite.color = getRandomColor();
		}
		if (FlxG.mouse.overlaps(bismaSprite) && FlxG.mouse.justReleased) {
			FlxG.sound.play(Paths.sound("bismaAppear"));
		}
	} else if (!transitioning) {
		checkBisma += dt;
		if (checkBisma > 60) {
			checkBisma = 0;
			if (Date.now().getHours() == 22) {
				bismaSprite.visible = showBisma = true;
				bismaSprite.velocity.set(200, 150);
				bismaSprite.color = getRandomColor();
				FlxG.sound.play(Paths.sound("bismaAppear"));
			}
		}
	}

	if (FlxG.sound.music.volume < 1.0) {
		FlxG.sound.music.volume += 0.5 * dt;
		if (FlxG.sound.music.volume > 1.0) FlxG.sound.music.volume = 1.0;
	}

	if (!transitioning) {
		if (popupAppear) {
			if (controls.ACCEPT || controls.BACK) closePopup();
		} else {
			if (FlxG.keys.justPressed.F8) {
				FlxG.switchState(new ModState("TTF/WebcamEyesDemo"));
				return;
			}
			if (canAccessDebugMenus && FlxG.keys.justPressed.SEVEN) {
				persistentUpdate = false;
				persistentDraw = true;
				openSubState(new EditorPicker());
			}

			if (controls.UP_P) changeItem(-1);
			else if (controls.DOWN_P) changeItem(1);
			else if (FlxG.mouse.wheel != 0) changeItem(-FlxG.mouse.wheel);

			if (controls.BACK) FlxG.switchState(new TitleState());
			else if (controls.SWITCHMOD) {
				persistentUpdate = false;
				persistentDraw = true;
				openSubState(new ModSwitchMenu());
			}
			else if (controls.ACCEPT) selectItem(options[curSelected]);
		}
	}

	if (isZoomLerp) FlxG.camera.zoom = lerp(FlxG.camera.zoom, 1, 0.15);
	FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, curSelected * 50, 0.05);

	curSelectLerp = lerp(curSelectLerp, curSelected, 0.15);
	menuItems.forEach((spr:FlxSprite) -> {
		var addY = 230;
		spr.updateHitbox();
		spr.screenCenter();
		spr.x += (Math.sin(spr.ID - curSelectLerp - 1.5) * 200) - 20;
		spr.y += (spr.ID * addY) - (curSelectLerp * addY);
		spr.angle = (-Math.sin(spr.ID - curSelectLerp) * 22);
	});
}
function beatHit() FlxG.camera.zoom += 0.02;

function selectItem(item) {
	if (item == 'story mode') {
		popupAppear = true;
		add(popupBg);
		add(blackBoxTitle);
		add(blackBox);
		add(blackText);
		add(blackTextInfo);

		popupBg.alpha = blackBoxTitle.alpha = blackBox.alpha = blackText.alpha = blackTextInfo.alpha = 0;
		FlxTween.tween(popupBg, {alpha: 0.3}, 0.2, {ease: FlxEase.sineOut});
		FlxTween.tween(blackBoxTitle, {alpha: 1}, 0.2, {ease: FlxEase.sineOut});
		FlxTween.tween(blackBox, {alpha: 0.5}, 0.2, {ease: FlxEase.sineOut});
		FlxTween.tween(blackText, {alpha: 1}, 0.2, {ease: FlxEase.sineOut});
		FlxTween.tween(blackTextInfo, {alpha: 1}, 0.2, {ease: FlxEase.sineOut});
	}
	else {
		isZoomLerp = false;
		transitioning = true;
		FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
		FlxG.camera.flash(FlxColor.WHITE, 1);

		bgChar.loadGraphic(Paths.image('portrait/' + curChar + '-kosan-no-saturation'));
		adjustColorShader.saturation = -100;

		var curSpr:FlxSprite;
		menuItems.forEach((spr:FlxSprite) -> {
			if (spr.ID == curSelected) curSpr = spr;
			else FlxTween.tween(spr, {alpha: 0}, 0.2);
		});

		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera, {zoom: 1.1}, 1, {ease: FlxEase.quintOut, onComplete: () -> {
			FlxTween.tween(FlxG.camera, {zoom: 2.5}, 1.5, {ease: FlxEase.quintIn});
		}});

		FlxFlicker.flicker(curSpr, 1.75, Options.flashingMenu ? 0.06 : 0.15, true, false, (_) -> {
			var state;
			switch (item) {
				case 'freeplay': state = new FreeplayState();
				case 'credits':state = new CreditsMain();
				case 'options': state = new OptionsMenu();
				default: state = new MainMenuState();
			}
			openSubState(new MusicBeatTransition());
			_requestSubStateReset = false;
			resetSubState();

			subState.newState = state;
			subState.transitionCamera.flipY = false;
			subState.blackSpr.y = -subState.transitionCamera.height;
			persistentUpdate = persistentDraw = true;
		});
	}
}

function closePopup() {
	FlxTween.cancelTweensOf(popupBg);
	FlxTween.cancelTweensOf(blackBoxTitle);
	FlxTween.cancelTweensOf(blackBox);
	FlxTween.cancelTweensOf(blackText);
	FlxTween.cancelTweensOf(blackTextInfo);

	FlxTween.tween(popupBg, {alpha: 0}, 0.2, {ease: FlxEase.sineInO});
	FlxTween.tween(blackBoxTitle, {alpha: 0}, 0.2, {ease: FlxEase.sineIn});
	FlxTween.tween(blackBox, {alpha: 0}, 0.2, {ease: FlxEase.sineIn});
	FlxTween.tween(blackText, {alpha: 0}, 0.2, {ease: FlxEase.sineIn});
	FlxTween.tween(blackTextInfo, {alpha: 0}, 0.2, {ease: FlxEase.sineIn, onComplete: () -> {
		popupAppear = false;
		remove(popupBg);
		remove(blackBoxTitle);
		remove(blackBox);
		remove(blackText);
		remove(blackTextInfo);
	}});
}

function changeItem(add:Int) {
	curSelected = FlxMath.wrap(curSelected + add, 0, menuItems.length - 1);
	if (add != 0) FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);

	menuItems.forEach((spr:FlxSprite) -> spr.animation.play(spr.ID == curSelected ? 'selected' : 'idle'));
}
