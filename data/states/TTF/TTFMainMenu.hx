import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.options.OptionsMenu;

var options:Array<String> = ['FREEPLAY', 'OPTIONS', 'CREDITS', 'GALLERY'];
var items:Array<FlxText> = [];
var curSelected:Int = 0;
var transitioning:Bool = false;
var time:Float = 0;
var statusText:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFFF6F3EC;
    CoolUtil.playMenuSong();

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF6F3EC);
    bg.scrollFactor.set();
    add(bg);

    // Pink registration-frame language from the design sheet.
    var frame = new FlxSprite(42, 86).makeGraphic(690, 552, 0xFFFFAAB5);
    frame.scrollFactor.set();
    add(frame);

    var paper = new FlxSprite(54, 98).makeGraphic(666, 528, 0xFFFFFFFF);
    paper.scrollFactor.set();
    add(paper);

    var title = new FlxText(80, 115, 575, 'TEEN TITANS FUNK!');
    title.setFormat(Paths.font('ttg.ttf'), 42, 0xFF20202A, 'left');
    title.scrollFactor.set();
    add(title);

    var line = new FlxSprite(80, 172).makeGraphic(565, 5, 0xFFFFAAB5);
    line.scrollFactor.set();
    add(line);

    // Oversized bracket shapes echo the sweeping black marks in the sketch.
    var leftBracket = new FlxText(54, 205, 90, '(((');
    leftBracket.setFormat(Paths.font('ttg.ttf'), 104, 0xFF17171D, 'center');
    leftBracket.angle = -90;
    leftBracket.alpha = 0.85;
    leftBracket.scrollFactor.set();
    add(leftBracket);

    var rightBracket = new FlxText(612, 205, 90, ')))');
    rightBracket.setFormat(Paths.font('ttg.ttf'), 104, 0xFF17171D, 'center');
    rightBracket.angle = 90;
    rightBracket.alpha = 0.85;
    rightBracket.scrollFactor.set();
    add(rightBracket);

    for (i in 0...options.length) {
        var label = new FlxText(140, 225 + (i * 82), 470, '');
        label.setFormat(Paths.font('ttg.ttf'), 49, 0xFF17171D, 'center');
        label.alignment = 'center';
        label.ID = i;
        label.scrollFactor.set();
        items.push(label);
        add(label);
    }

    // Status badge from the sketch.
    var badge = new FlxSprite(815, 205).makeGraphic(300, 300, 0xFFFFD52F);
    badge.scrollFactor.set();
    add(badge);

    var badgeInner = new FlxSprite(832, 222).makeGraphic(266, 266, 0xFF17171D);
    badgeInner.scrollFactor.set();
    add(badgeInner);

    var badgeLetter = new FlxText(832, 220, 266, 'T');
    badgeLetter.setFormat(Paths.font('ttg.ttf'), 150, 0xFF20B8D3, 'center');
    badgeLetter.alignment = 'center';
    badgeLetter.scrollFactor.set();
    add(badgeLetter);

    statusText = new FlxText(805, 520, 320, 'STATUS:  SHUT IT!');
    statusText.setFormat(Paths.font('ttg.ttf'), 25, 0xFF17171D, 'center');
    statusText.alignment = 'center';
    statusText.scrollFactor.set();
    add(statusText);

    var team = new FlxText(790, 565, 360, 'ROBIN  //  STARFIRE  //  RAVEN');
    team.setFormat(Paths.font('comm.ttf'), 17, 0xFF34343B, 'center');
    team.alignment = 'center';
    team.scrollFactor.set();
    add(team);

    var help = new FlxText(45, FlxG.height - 42, FlxG.width - 90, 'UP / DOWN  SELECT     ENTER  CONFIRM     H  ???');
    help.setFormat(Paths.font('comm.ttf'), 18, 0xFF24242B, 'center');
    help.alignment = 'center';
    help.scrollFactor.set();
    add(help);

    changeSelection(0);
}

function update(elapsed:Float) {
    if (transitioning) return;
    time += elapsed;

    badgePulse();
    if (controls.UP_P) changeSelection(-1);
    else if (controls.DOWN_P) changeSelection(1);

    if (FlxG.keys.justPressed.H) {
        transitioning = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFSecretScreen'));
        return;
    }

    if (controls.ACCEPT) selectItem();
    if (controls.BACK) {
        transitioning = true;
        FlxG.switchState(new ModState('TTF/TTFTitleScreen'));
    }
}

function badgePulse() {
    statusText.alpha = 0.83 + Math.sin(time * 2) * 0.12;
}

function changeSelection(change:Int) {
    curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
    if (change != 0) FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);

    for (i in 0...items.length) {
        var active = i == curSelected;
        items[i].text = (active ? '>  ' : '   ') + options[i];
        items[i].color = active ? 0xFFE3A900 : 0xFF17171D;
        items[i].alpha = active ? 1 : 0.72;
        items[i].size = active ? 51 : 45;
    }
}

function selectItem() {
    transitioning = true;
    FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
    switch (curSelected) {
        case 0: FlxG.switchState(new ModState('TTF/TTFFreeplayScreen'));
        case 1: FlxG.switchState(new ModState('TTF/TTFOptionsScreen'));
        case 2: FlxG.switchState(new ModState('TTF/TTFCreditsScreen'));
        case 3: FlxG.switchState(new ModState('TTF/TTFGalleryScreen'));
    }
}
