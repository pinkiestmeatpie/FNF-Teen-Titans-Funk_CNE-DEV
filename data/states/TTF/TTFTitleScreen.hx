import openfl.display.BlendMode;

import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween.FlxTweenType;

import funkin.backend.utils.DiscordUtil;
import funkin.backend.MusicBeatState;
import funkin.menus.TitleState;
import funkin.menus.MainMenuState;

function coolLerp(a, b, ratio, dt) FlxMath.lerp(b, a, Math.pow(1 - ratio, dt * 60));

var curWackIdx:Int = 0;
var curWacky:Array<Array<String>> = [];

var logoProps = {
	scale: 1,
	offset: {x: -10, y: 10},
	angleTime: 0
};

var chessBG:FlxBackdrop;
var shadow:FlxSprite;
var overlayGradient:FlxSprite;
var titleBop:FlxSprite;
var bars:FlxSprite;
var logo:FlxSprite;

var titleText:FlxSprite;
var titleGlow:FlxSprite;
var glowTime:Float = 0;

var dajoli:FlxSprite;
var indoCoy:FlxSprite;

var kjStudio:FlxSprite;
var kjStudioTxt:FlxSprite;
var blackScreen:FlxSprite;

var kosan:FlxSprite;
var seru:FlxSprite;
var crot:FlxSprite;

var skippedIntro:Bool = false;
var transitioning:Bool = false;

function create() {
	DiscordUtil.changePresence("Currently Crimefighting...", null);
	MusicBeatState.skipTransIn = true;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/bgmainRamadhan'));
	bg.setGraphicSize(FlxG.width, FlxG.height);
	bg.scrollFactor.set(0, 0);
	bg.updateHitbox();
	bg.antialiasing = Options.antialiasing;
	add(bg);

	chessBG = new FlxBackdrop();
	chessBG.loadGraphic(Paths.image('menus/chess'));
	chessBG.blend = BlendMode.ADD;
	chessBG.velocity.x = -10;
	chessBG.velocity.y = 10;
	chessBG.antialiasing = true;
	chessBG.alpha = 0.1;
	add(chessBG);

	shadow = new FlxSprite(-1, -1).loadGraphic(Paths.image('menus/titlescreen/shadow'));
	shadow.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
	shadow.scrollFactor.set(0, 0);
	shadow.updateHitbox();
	shadow.antialiasing = Options.antialiasing;
	shadow.blend = BlendMode.MULTIPLY;
	add(shadow);

	overlayGradient = new FlxSprite(-1).loadGraphic(Paths.image('menus/titlescreen/overlayRamadhan'));
	overlayGradient.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
	overlayGradient.scrollFactor.set(0, 0);
	overlayGradient.updateHitbox();
	overlayGradient.antialiasing = Options.antialiasing;
	overlayGradient.blend = BlendMode.OVERLAY;
	overlayGradient.alpha = 0.7;
	add(overlayGradient);

	add(titleBop = new FlxSprite());
	titleBop.frames = Paths.getFrames('menus/titlescreen/TitleBopRamadhan');
	titleBop.animation.addByPrefix('bop', 'bop', 24, false);
	titleBop.animation.play('bop');
	titleBop.antialiasing = Options.antialiasing;
	titleBop.visible = false;
	titleBop.scale.set(.6, .6);
	titleBop.updateHitbox();
	//titleBop.animation.curAnim.frameRate = 27;

	bars = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/bars'));
	bars.setGraphicSize(FlxG.width, FlxG.height);
	bars.updateHitbox();
	bars.scrollFactor.set(0, 0);
	bars.antialiasing = Options.antialiasing;
	add(bars);

	logo = new FlxSprite();
	logo.frames = Paths.getFrames('menus/titlescreen/logo_bump');
	logo.animation.addByPrefix('bump', "logo bumpin", 24, false);
	logo.animation.play('bump');
	logo.antialiasing = Options.antialiasing;
	logo.visible = false;
	add(logo);

	titleText = new FlxSprite(220, 1000);
	titleText.frames = Paths.getFrames('menus/titlescreen/titlebegin');
	titleText.animation.addByPrefix('text', "text", 24);
	titleText.animation.play('text');
	titleText.scale.set(0.7, 0.7);
	titleText.updateHitbox();
	titleText.antialiasing = Options.antialiasing;
	add(titleText);

	titleGlow = new FlxSprite(192, 1000);
	titleGlow.frames = Paths.getFrames('menus/titlescreen/titlebegin');
	titleGlow.animation.addByPrefix('glow', "glow", 24);
	titleGlow.animation.play('glow');
	titleGlow.scale.set(0.7, 0.7);
	titleGlow.updateHitbox();
	titleGlow.antialiasing = Options.antialiasing;
	add(titleGlow);

	kjStudio = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/kj_studio'));
	kjStudio.setGraphicSize(200, 200);
	kjStudio.updateHitbox();
	kjStudio.screenCenter();
	kjStudio.visible = false;
	kjStudio.antialiasing = Options.antialiasing;

	kjStudioTxt = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/kj_studio_txt'));
	kjStudioTxt.setGraphicSize(260, 200);
	kjStudioTxt.updateHitbox();
	kjStudioTxt.screenCenter(FlxAxes.X);
	kjStudioTxt.visible = false;
	kjStudioTxt.antialiasing = Options.antialiasing;

	dajoli = new FlxSprite(0, FlxG.height * 0.46).loadGraphic(Paths.image('dajoli'));
	dajoli.setGraphicSize(200, 200);
	dajoli.updateHitbox();
	dajoli.screenCenter(FlxAxes.X);
	dajoli.visible = false;
	dajoli.antialiasing = Options.antialiasing;

	kosan = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/logo/kosan'));
	kosan.scale.set(0.7, 0.7);
	kosan.updateHitbox();
	kosan.screenCenter();
	kosan.visible = false;
	kosan.antialiasing = Options.antialiasing;

	seru = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/logo/seru'));
	seru.scale.set(0.7, 0.7);
	seru.updateHitbox();
	seru.screenCenter();
	seru.visible = false;
	seru.antialiasing = Options.antialiasing;

	crot = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/logo/crot'));
	crot.scale.set(0, 0);
	crot.updateHitbox();
	crot.screenCenter();
	crot.visible = false;
	crot.antialiasing = Options.antialiasing;

	blackScreen = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
	blackScreen.scrollFactor.set(0, 0);
	add(blackScreen);

	add(kjStudio);
	add(kjStudioTxt);
	add(dajoli);

	add(crot);
	add(kosan);
	add(seru);

	indoCoy = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/indo_coy'));
	indoCoy.setGraphicSize(300, 300);
	indoCoy.updateHitbox();
	indoCoy.screenCenter();
	indoCoy.visible = false;
	indoCoy.antialiasing = Options.antialiasing;
	add(indoCoy);

	textGroup = new FlxSpriteGroup();
	add(textGroup);

	/*
	dust = new FlxSprite();
	dust.frames = Paths.getFrames('menus/titlescreen/dust');
	dust.animation.addByPrefix('dust', 'dust', 24);
	dust.animation.play('dust');
	dust.setGraphicSize(FlxG.width, FlxG.height);
	dust.updateHitbox();
	dust.antialiasing = Options.antialiasing;
	dust.blend = BlendMode.SCREEN;
	dust.alpha = 0.00001;
	add(dust); 
	*/

	if (TitleState.initialized) skipIntro();
	else {
		curWacky = getIntroTextShits();

		TitleState.initialized = true;
		CoolUtil.playMenuSong();
	}
}

function getIntroTextShits():Array<Array<String>> {
	var fullText:String = Assets.getText(Paths.txt('titlescreen/introText'));
	var lines:Array<String> = fullText.split('\n');
	var swagGoodArray:Array<Array<String>> = [];
	for (i in lines) swagGoodArray.push(i.split('--'));

	var gotIndices:Array<Int> = [];
	var results:Array<Array<String>> = [];
	for (i in 0...Math.min(swagGoodArray.length, 3)) {
		var gotIndex = FlxG.random.int(0, swagGoodArray.length - 1);
		while (gotIndices.contains(gotIndex)) gotIndex = FlxMath.wrap(gotIndex + 1, 0, swagGoodArray.length - 1);

		gotIndices.push(gotIndex);
		results.push(swagGoodArray[gotIndex]);
	}

	return results;
}

function update(elapsed:Float) {
	glowTime += elapsed * 5;
	titleGlow.alpha = 0.7 + (Math.sin(glowTime) / 3);

	if (FlxG.keys.justPressed.ENTER) {
		if (skippedIntro) {
			if (transitioning) {
				FlxG.camera.stopFX();
				FlxG.switchState(new MainMenuState());
			}
			else
				pressEnter();
		}
		else
			skipIntro();
	}

	FlxG.camera.scroll.x = FlxG.random.float(-1, 1);
	FlxG.camera.scroll.y = FlxG.random.float(-1, 1);

	kjStudioTxt.y = kjStudio.y;

	if (skippedIntro && !transitioning) FlxG.camera.zoom = coolLerp(FlxG.camera.zoom, 1, 0.12, elapsed);
	overlayGradient.alpha = coolLerp(overlayGradient.alpha, 0.3, 0.08, elapsed);

	logo.scale.set(logoProps.scale, logoProps.scale);
	logo.updateHitbox();
	logo.x = Math.floor((FlxG.width - logo.width) / 2) + logoProps.offset.x;
	logo.y = Math.floor((FlxG.height - logo.height) / 2) + logoProps.offset.y;

	titleBop.x = Math.floor((FlxG.width - titleBop.width) / 2) - logoProps.offset.x;
	titleBop.y = Math.floor((FlxG.height - titleBop.height) / 2) - logoProps.offset.y + 100;
	if (transitioning) titleBop.y += ((FlxG.camera.zoom - 1) * 500);

	logoProps.angleTime += elapsed;
	logo.angle = 3 * Math.sin(logoProps.angleTime);
}

function pressEnter() {
	FlxG.camera.flash(FlxColor.WHITE, 1);
	FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);

	var bs:FlxSprite = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
	bs.alpha = 0;
	bs.blend = BlendMode.NORMAL;
	add(bs);

//	FlxTween.tween(dust, {alpha: 0.00001}, 1.9, {ease: FlxEase.expoIn});
	FlxTween.tween(bs, {alpha: 1}, 1.9, {ease: FlxEase.expoIn});
	FlxTween.tween(logoProps.offset, {x: -10}, 2, {ease: FlxEase.expoOut});
	FlxTween.tween(FlxG.camera, {zoom: 2}, 1.9, {ease: FlxEase.expoIn});
	FlxTween.tween(chessBG.velocity, {x: 0, y: 1000}, 1, {ease: FlxEase.quartIn});
	FlxTween.color(titleBop, 2, titleBop.color, FlxColor.BLACK, {ease: FlxEase.expoOut});

	transitioning = true;

	FlxFlicker.flicker(titleGlow, 2, 0.06, false, false);
	FlxFlicker.flicker(titleText, 2, 0.06, false, false, function(flick:FlxFlicker) {
		FlxG.switchState(new MainMenuState());
	});
}

function createCoolText(textArray:Array<String>) {
	for (i=>text in textArray) {
		if (text == "" || text == null) continue;
		var money:FlxText = new FlxText(0, (i * 60) + 200, 0, text.toUpperCase());
		money.setFormat(Paths.font('montserrat/bold.ttf'), 44, FlxColor.WHITE);
		money.screenCenter(FlxAxes.X);
		money.x = Math.floor(money.x);
		textGroup.add(money);
		textGroup.screenCenter(FlxAxes.Y);
		textGroup.y = Math.floor(textGroup.y - 200);
	}
}

function addMoreText(text:String) {
	var coolText:FlxText = new FlxText(0, (textGroup.length * 60) + 200, 0, text.toUpperCase());
	coolText.setFormat(Paths.font('montserrat/bold.ttf'), 44, FlxColor.WHITE);
	coolText.screenCenter(FlxAxes.X);
	coolText.x = Math.floor(coolText.x);
	textGroup.add(coolText);
	textGroup.screenCenter(FlxAxes.Y);
	textGroup.y = Math.floor(textGroup.y - 200);
}

function deleteCoolText() {
	while (textGroup.members.length > 0) {
		textGroup.members[0].destroy();
		textGroup.remove(textGroup.members[0], true);
	}
}

function beatHit(curBeat:Int) {
	logo.animation.play('bump', true);
	titleBop.animation.play('bop', true);

	if (skippedIntro) return;

	switch (curBeat) {
		case 1:
			FlxFlicker.flicker(kjStudio, 0.2, 0.01, true, false);
			FlxTween.tween(blackScreen, {alpha: 0.4}, 10);
		case 3:
			FlxFlicker.flicker(kjStudioTxt, 0.2, 0.01, true, false);
			FlxTween.tween(kjStudio, {y: 800}, 1, {ease: FlxEase.quartIn, startDelay: 0.1});
		case 5: createCoolText(['valen pratama', 'ayambrut', 'rendem', 'yukira ishikawa']);
		case 7: addMoreText('present');
		case 8: deleteCoolText();
		case 9: createCoolText(['this mod is based on']);
		case 11: addMoreText('kosan jodent discord');
		case 12: deleteCoolText();
		case 13 | 17 | 21: createCoolText([curWacky[curWackIdx][0]]);
		case 14 | 18 | 22: if (curWacky[curWackIdx].length > 2) addMoreText(curWacky[curWackIdx][1]);
		case 15 | 19 | 23: if (curWacky[curWackIdx].length > 2) addMoreText(curWacky[curWackIdx++][2]); else addMoreText(curWacky[curWackIdx++][1]);
		case 16 | 20 | 24: deleteCoolText();
		case 25: createCoolText(['dajoli']);
		case 27:
			addMoreText('is real');
			dajoli.visible = true;
			textGroup.y -= 105;
		case 28:
			deleteCoolText();
			dajoli.visible = false;
			blackScreen.alpha = 1;
			FlxFlicker.flicker(kosan, 0.2, 0.01, true, false);
		case 29: FlxFlicker.flicker(seru, 0.2, 0.01, true, false);
		case 30:
			crot.visible = true;
			FlxTween.tween(crot.scale, {x: 0.7, y: 0.7}, 0.3, {ease: FlxEase.quartOut});

			FlxTween.tween(kosan, {y: 800}, 0.7, {ease: FlxEase.quartIn, startDelay: 0.1});
			FlxTween.tween(seru, {y: 800}, 0.7, {ease: FlxEase.quartIn, startDelay: 0.1});
			FlxTween.tween(crot, {y: 900}, 0.7, {ease: FlxEase.quartIn, startDelay: 0.1});
		case 31:
			indoCoy.visible = true;
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.crochet / 1000) - 0.1, {ease: FlxEase.quartOut});
		case 32: skipIntro();
	}
}

function skipIntro() {
	skippedIntro = true;

	FlxTween.cancelTweensOf(blackScreen);
	FlxTween.cancelTweensOf(FlxG.camera);
	FlxTween.cancelTweensOf(kjStudio);
	FlxTween.cancelTweensOf(kjStudioTxt);
	FlxTween.cancelTweensOf(kosan);
	FlxTween.cancelTweensOf(seru);
	FlxTween.cancelTweensOf(crot);

	FlxG.camera.zoom += 1.5;

	chessBG.velocity.x = -100;
	chessBG.velocity.y = 100;

	blackScreen.alpha = 0.1;

	FlxG.camera.flash(FlxColor.WHITE, 3);

	remove(kjStudio);
	kjStudio.destroy();
	remove(kjStudioTxt);
	kjStudioTxt.destroy();

	remove(kosan);
	kosan.destroy();
	remove(seru);
	seru.destroy();
	remove(crot);
	crot.destroy();

	remove(dajoli);
	dajoli.destroy();

	remove(indoCoy);
	indoCoy.destroy();
	remove(textGroup);
	textGroup.destroy();

	titleBop.visible = logo.visible = true;
	skippedIntro = true;

	titleBop.color = FlxColor.BLACK;
	FlxTween.color(titleBop, 1, titleBop.color, FlxColor.WHITE, {ease: FlxEase.quartInOut, startDelay: 1});

	FlxTween.tween(logoProps.offset, {y: 900}, 1, {ease: FlxEase.quintOut, type: FlxTweenType.BACKWARD});
	FlxTween.tween(logoProps.offset, {x: 280}, 1.2, {ease: FlxEase.quartInOut, startDelay: 1});
	FlxTween.tween(logoProps, {scale: 0.8}, 1, {ease: FlxEase.quartInOut, startDelay: 1.2});

	FlxTween.tween(titleGlow, {y: 618}, 2, {ease: FlxEase.quartInOut, startDelay: 1.5});
	FlxTween.tween(titleText, {y: 620}, 2, {ease: FlxEase.quartInOut, startDelay: 1.5, onComplete: function(twn:FlxTween) {
		canPressEnter = true;
	}});
}