import flixel.group.FlxSpriteGroup;

static var ttfIntroSeen:Bool = false;
var phase:String;
var blurred:FlxSprite;
var intro:FlxText;
var logo:FlxSpriteGroup;
var prompt:FlxText;
var play:FlxText;
var robin:FlxSprite;
var introTime:Float = 0;
var introCard:Int = -1;
var titleParts:Array<FlxSprite> = [];
var bops:Array<FlxTween> = [];
var cards:Array<String> = ['PINKIESTMEATPIE PRESENTS', 'TITANS, GO!', 'TEEN TITANS FUNK!'];

function label(x, y, width, value, size, color, font) {
    var text = new FlxText(x, y, width, value, size);
    text.setFormat(Paths.font(font), size, color, 'center');
    text.antialiasing = true;
    return text;
}

function create() {
    CoolUtil.playMenuSong();
    var path = Paths.image('stages/Tcar/car2');
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF163044));
    var sharp = new FlxSprite().loadGraphic(path);
    sharp.setGraphicSize(FlxG.width, FlxG.height);
    sharp.updateHitbox();
    sharp.antialiasing = true;
    add(sharp);

    blurred = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/ttf-car-blurred'));
    blurred.setGraphicSize(FlxG.width, FlxG.height);
    blurred.updateHitbox();
    blurred.antialiasing = true;
    add(blurred);

    play = label(135, 105, 570, 'PLAY', 150, 0xFFFFDE38, 'baveuse.ttf');
    play.angle = -8;
    play.visible = false;
    add(play);

    robin = new FlxSprite();
    robin.frames = Paths.getFrames('characters/robinnew');
    robin.animation.addByPrefix('idle', 'robinnew idle', 18, true);
    robin.animation.play('idle');
    robin.setGraphicSize(0, 490);
    robin.updateHitbox();
    robin.setPosition(22, FlxG.height - robin.height);
    robin.antialiasing = true;
    robin.visible = false;
    add(robin);

    logo = new FlxSpriteGroup();
    var name = label(0, 170, FlxG.width, 'TEEN TITANS', 95, 0xFF27B5E7, 'baveuse.ttf');
    logo.add(name);
    var funk = label(0, 275, FlxG.width, 'FUNK!', 120, 0xFFFFDE38, 'baveuse.ttf');
    logo.add(funk);
    logo.add(label(0, 455, FlxG.width, 'A MOD BY PINKIESTMEATPIE', 24, FlxColor.WHITE, 'comm.ttf'));
    titleParts = [name, funk];
    add(logo);
    prompt = label(0, 605, FlxG.width, 'PRESS ENTER', 27, FlxColor.WHITE, 'comm.ttf');
    add(prompt);

    intro = label(0, 310, FlxG.width, '', 45, FlxColor.WHITE, 'comm.ttf');
    add(intro);

    if (data != null && data.showPlay == true) {
        phase = 'play';
        logo.visible = false;
        blurred.visible = false;
        showPlay(false);
    } else if (ttfIntroSeen) {
        phase = 'title';
    } else {
        ttfIntroSeen = true;
        phase = 'intro';
        logo.visible = false;
        prompt.text = 'ENTER: SKIP INTRO';
    }
}

function showPlay(animate:Bool) {
    play.visible = robin.visible = true;
    prompt.visible = true;
    prompt.text = 'ENTER / CLICK PLAY     ESC: BACK';
    if (animate) {
        play.alpha = robin.alpha = 0;
        FlxTween.tween(play, {alpha: 1}, 0.28);
        FlxTween.tween(robin, {alpha: 1}, 0.28);
    }
}

function finishIntro() {
    phase = 'title';
    FlxTween.cancelTweensOf(intro);
    intro.visible = false;
    logo.visible = true;
    logo.alpha = 0;
    FlxTween.tween(logo, {alpha: 1}, 0.3);
    prompt.text = 'PRESS ENTER';
}

function clearBops() {
    for (tween in bops) tween.cancel();
    bops = [];
}

function bop(sprite:FlxSprite) {
    sprite.scale.set(1.07, 1.07);
    bops.push(FlxTween.tween(sprite.scale, {x: 1, y: 1}, 0.24, {ease: FlxEase.quadOut}));
}

function beatHit(beat:Int) {
    if (phase == 'reveal' || phase == 'intro') return;
    clearBops();
    if (phase == 'title') {
        for (part in titleParts) bop(part);
    } else if (phase == 'play') {
        bop(play);
    }
}

function update(elapsed:Float) {
    if (phase == 'intro') {
        if (controls.ACCEPT) {
            finishIntro();
            return;
        }
        introTime += elapsed;
        var card = Std.int(introTime / 1.35);
        if (card >= cards.length) {
            finishIntro();
        } else if (card != introCard) {
            introCard = card;
            FlxTween.cancelTweensOf(intro);
            intro.text = cards[card];
            intro.alpha = 0;
            intro.y = 325;
            FlxTween.tween(intro, {alpha: 1, y: 310}, 0.28, {ease: FlxEase.quadOut});
        }
    } else if (phase == 'title' && controls.ACCEPT) {
        phase = 'reveal';
        prompt.visible = false;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxTween.cancelTweensOf(logo);
        FlxTween.tween(blurred, {alpha: 0}, 0.65, {ease: FlxEase.sineInOut});
        FlxTween.tween(logo, {y: FlxG.height}, 0.65, {ease: FlxEase.quadIn, onComplete: function(_) {
            logo.visible = false;
            blurred.visible = false;
            showPlay(true);
            phase = 'play';
        }});
    } else if (phase == 'play') {
        var hover = FlxG.mouse.overlaps(play);
        play.color = hover ? 0xFFFFFAAE : 0xFFFFDE38;
        if (controls.ACCEPT || (hover && FlxG.mouse.justPressed)) {
            phase = 'leaving';
            FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
            FlxG.switchState(new MainMenuState());
        } else if (controls.BACK) {
            phase = 'reveal';
            blurred.visible = true;
            logo.visible = true;
            play.visible = robin.visible = false;
            prompt.text = 'PRESS ENTER';
            FlxTween.tween(blurred, {alpha: 1}, 0.4);
            FlxTween.tween(logo, {y: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(_) phase = 'title'});
        }
    }
}

function destroy() {
    for (sprite in [intro, logo, blurred, play, robin]) FlxTween.cancelTweensOf(sprite);
    clearBops();
}
