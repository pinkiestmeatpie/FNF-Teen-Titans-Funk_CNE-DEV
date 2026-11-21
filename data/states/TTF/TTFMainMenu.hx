import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.game.PlayState;

var options:Array<String> = ['FREEPLAY', 'OPTIONS', 'CREDITS', 'GALLERY'];
var items:Array<FlxText> = [];
var curSelected:Int = 0;
var transitioning:Bool = false;
var pulse:Float = 0;
var statusText:FlxText;
var communicator:FlxSprite;

function create() {
    FlxG.camera.bgColor = 0xFFF5F2EC;
    CoolUtil.playMenuSong();

    // Faded scene backdrop from the mod's own stage art.
    var scene = new FlxSprite().loadGraphic(Paths.image('stages/warehouse/bg'));
    scene.setGraphicSize(FlxG.width, FlxG.height);
    scene.updateHitbox();
    scene.scrollFactor.set();
    scene.alpha = 0.28;
    add(scene);

    var paper = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xBFF5F2EC);
    paper.scrollFactor.set();
    add(paper);

    var frame = new FlxSprite(44, 80).makeGraphic(650, 560, 0xFFFFAAB5);
    frame.scrollFactor.set();
    add(frame);

    var menuPanel = new FlxSprite(56, 92).makeGraphic(626, 536, 0xFFFDFCF8);
    menuPanel.scrollFactor.set();
    add(menuPanel);

    var label = new FlxText(92, 112, 500, 'MENU');
    label.setFormat(Paths.font('comm.ttf'), 18, 0xFF7C7B80, 'left');
    label.scrollFactor.set();
    add(label);

    // Large, unrotated parentheses form the curved brackets around the menu list.
    var leftBracket = new FlxText(50, 163, 115, '(');
    leftBracket.setFormat(Paths.font('ttg.ttf'), 395, 0xFF101015, 'center');
    leftBracket.alignment = 'center';
    leftBracket.scrollFactor.set();
    add(leftBracket);

    var rightBracket = new FlxText(574, 163, 115, ')');
    rightBracket.setFormat(Paths.font('ttg.ttf'), 395, 0xFF101015, 'center');
    rightBracket.alignment = 'center';
    rightBracket.scrollFactor.set();
    add(rightBracket);

    for (i in 0...options.length) {
        var item = new FlxText(140, 212 + (i * 83), 420, '');
        item.setFormat(Paths.font('ttg.ttf'), 48, 0xFF101015, 'center');
        item.alignment = 'center';
        item.ID = i;
        item.scrollFactor.set();
        items.push(item);
        add(item);
    }

    // Round communicator: yellow casing, black face, green side details.
    communicator = new FlxSprite(825, 220).makeGraphic(218, 218, FlxColor.TRANSPARENT, true);
    FlxSpriteUtil.drawCircle(communicator, 109, 109, 105, 0xFFFFD52F);
    FlxSpriteUtil.drawCircle(communicator, 109, 109, 91, 0xFF111116);
    FlxSpriteUtil.drawCircle(communicator, 109, 109, 82, 0xFF050508);
    communicator.scrollFactor.set();
    add(communicator);

    var tabLeft = new FlxSprite(812, 264).makeGraphic(25, 62, 0xFF36A96B);
    tabLeft.angle = -24;
    tabLeft.scrollFactor.set();
    add(tabLeft);

    var tabRight = new FlxSprite(1027, 264).makeGraphic(25, 62, 0xFF36A96B);
    tabRight.angle = 24;
    tabRight.scrollFactor.set();
    add(tabRight);

    var commLetter = new FlxText(850, 230, 168, 'T');
    commLetter.setFormat(Paths.font('ttg.ttf'), 85, 0xFF18B9D5, 'center');
    commLetter.alignment = 'center';
    commLetter.scrollFactor.set();
    add(commLetter);

    statusText = new FlxText(851, 318, 166, 'STATUS:\nSHUT IT!');
    statusText.setFormat(Paths.font('ttg.ttf'), 19, 0xFFFF5366, 'center');
    statusText.alignment = 'center';
    statusText.scrollFactor.set();
    add(statusText);

    var communicatorLabel = new FlxText(790, 455, 285, 'STATUS!');
    communicatorLabel.setFormat(Paths.font('ttg.ttf'), 31, 0xFF15151B, 'center');
    communicatorLabel.alignment = 'center';
    communicatorLabel.scrollFactor.set();
    add(communicatorLabel);

    var statusDetail = new FlxText(775, 501, 315, 'TITAN COMMUNICATOR // ONLINE');
    statusDetail.setFormat(Paths.font('comm.ttf'), 16, 0xFF4C4A50, 'center');
    statusDetail.alignment = 'center';
    statusDetail.scrollFactor.set();
    add(statusDetail);

    var help = new FlxText(40, FlxG.height - 42, FlxG.width - 80,
        'UP / DOWN  SELECT     ENTER  CONFIRM     H  HYPNOTIZED     ESC  TITLE');
    help.setFormat(Paths.font('comm.ttf'), 17, 0xFF25252D, 'center');
    help.alignment = 'center';
    help.scrollFactor.set();
    add(help);

    changeSelection(0);
}

function update(elapsed:Float) {
    if (transitioning) return;

    pulse += elapsed * 2;
    statusText.alpha = 0.82 + Math.sin(pulse) * 0.15;

    if (controls.UP_P) changeSelection(-1);
    else if (controls.DOWN_P) changeSelection(1);

    // H is a direct song shortcut; there is deliberately no secret-menu state.
    if (FlxG.keys.justPressed.H) {
        transitioning = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        PlayState.loadSong('HYPNOTIZED', 'hard', null, false, false);
        FlxG.switchState(new PlayState());
        return;
    }

    if (controls.ACCEPT) selectItem();

    if (controls.BACK) {
        transitioning = true;
        FlxG.switchState(new ModState('TTF/TTFTitleScreen'));
    }
}

function changeSelection(change:Int) {
    curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
    if (change != 0) FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);

    for (i in 0...items.length) {
        var active = i == curSelected;
        items[i].text = (active ? '>  ' : '   ') + options[i];
        items[i].color = active ? 0xFFE5B600 : 0xFF15151B;
        items[i].alpha = active ? 1 : 0.72;
    }
}

function selectItem() {
    transitioning = true;
    FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);

    switch (curSelected) {
        case 0: FlxG.switchState(new ModState('TTF/TTFFreeplayScreen'));
        case 1: FlxG.switchState(new ModState('TTF/TTFOptionsScreen'));
        case 2: FlxG.switchState(new ModState('TTF/TTFCreditsScreen'));
        case 3: FlxG.switchState(new ModState('TTF/GalleryState'));
    }
}
