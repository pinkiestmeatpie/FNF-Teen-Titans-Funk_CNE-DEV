import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

var entries:Array<Dynamic> = [
    {name: 'ROBIN', letter: 'R', color: 0xFFE84E52, note: 'CHARACTER ART // PLACEHOLDER'},
    {name: 'STARFIRE', letter: 'S', color: 0xFFE78A43, note: 'CHARACTER ART // PLACEHOLDER'},
    {name: 'RAVEN', letter: 'R', color: 0xFF7257A6, note: 'CHARACTER ART // PLACEHOLDER'},
    {name: 'BEAST BOY', letter: 'B', color: 0xFF55A96A, note: 'CHARACTER ART // PLACEHOLDER'},
    {name: 'CYBORG', letter: 'C', color: 0xFF4B9CB7, note: 'CHARACTER ART // PLACEHOLDER'}
];

var selected:Int = 0;
var preview:FlxSprite;
var previewLetter:FlxText;
var heading:FlxText;
var note:FlxText;
var count:FlxText;
var thumbs:Array<FlxText> = [];

function create() {
    FlxG.camera.bgColor = 0xFF18233A;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF18233A);
    bg.scrollFactor.set();
    add(bg);

    // Blue checkerboard-inspired gallery chrome.
    for (i in 0...10) {
        var tile = new FlxSprite(i * 130, 0).makeGraphic(65, FlxG.height, i % 2 == 0 ? 0xFF233956 : 0xFF1D304B);
        tile.alpha = 0.25;
        tile.scrollFactor.set();
        add(tile);
    }

    var top = new FlxSprite(36, 35).makeGraphic(1208, 650, 0xFF0B111D);
    top.scrollFactor.set();
    add(top);

    var inner = new FlxSprite(53, 53).makeGraphic(1174, 614, 0xFF2C5270);
    inner.scrollFactor.set();
    add(inner);

    var screen = new FlxSprite(250, 105).makeGraphic(780, 415, 0xFFE5E9E4);
    screen.scrollFactor.set();
    add(screen);

    preview = new FlxSprite(275, 130).makeGraphic(730, 365, 0xFF4D8194);
    preview.scrollFactor.set();
    add(preview);

    previewLetter = new FlxText(275, 180, 730, '');
    previewLetter.setFormat(Paths.font('ttg.ttf'), 230, FlxColor.WHITE, 'center');
    previewLetter.alignment = 'center';
    previewLetter.scrollFactor.set();
    add(previewLetter);

    heading = new FlxText(75, 70, 1100, 'TITANS // GALLERY');
    heading.setFormat(Paths.font('ttg.ttf'), 37, FlxColor.WHITE, 'center');
    heading.alignment = 'center';
    heading.scrollFactor.set();
    add(heading);

    note = new FlxText(250, 530, 780, '');
    note.setFormat(Paths.font('comm.ttf'), 18, FlxColor.WHITE, 'center');
    note.alignment = 'center';
    note.scrollFactor.set();
    add(note);

    for (i in 0...entries.length) {
        var thumb = new FlxText(90 + (i * 220), 580, 200, '');
        thumb.setFormat(Paths.font('ttg.ttf'), 25, FlxColor.WHITE, 'center');
        thumb.alignment = 'center';
        thumb.ID = i;
        thumb.scrollFactor.set();
        thumbs.push(thumb);
        add(thumb);
    }

    count = new FlxText(0, 638, FlxG.width, '');
    count.setFormat(Paths.font('comm.ttf'), 16, FlxColor.WHITE, 'center');
    count.alignment = 'center';
    count.scrollFactor.set();
    add(count);

    refreshGallery();
}

function refreshGallery() {
    preview.color = entries[selected].color;
    previewLetter.text = entries[selected].letter;
    note.text = entries[selected].note;
    count.text = 'LEFT / RIGHT  BROWSE     //     ESC  BACK     //     ' + (selected + 1) + ' / ' + entries.length;

    for (i in 0...thumbs.length) {
        thumbs[i].text = (i == selected ? '> ' : '') + entries[i].name;
        thumbs[i].color = i == selected ? 0xFFFFD52F : FlxColor.WHITE;
        thumbs[i].alpha = i == selected ? 1 : 0.55;
    }
}

function update(elapsed:Float) {
    if (controls.LEFT_P) {
        selected = (selected - 1 + entries.length) % entries.length;
        refreshGallery();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    } else if (controls.RIGHT_P) {
        selected = (selected + 1) % entries.length;
        refreshGallery();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    }

    if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
