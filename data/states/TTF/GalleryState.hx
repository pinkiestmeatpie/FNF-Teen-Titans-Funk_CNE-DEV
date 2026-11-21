import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

// Replace these test images and artist labels with the final gallery artwork.
var entries:Array<Dynamic> = [
    {file: 'squareImageTest', title: 'CHARACTER CONCEPT', artist: 'ARTIST NAME'},
    {file: 'widthTestImage', title: 'TITANS GROUP ART', artist: 'ARTIST NAME'},
    {file: 'heightTestImage', title: 'SCENE / BACKGROUND', artist: 'ARTIST NAME'}
];

var selected:Int = 0;
var preview:FlxSprite;
var titleText:FlxText;
var artistText:FlxText;
var countText:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFF182D49;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF182D49);
    bg.scrollFactor.set();
    add(bg);

    var pattern = new FlxBackdrop();
    pattern.loadGraphic(Paths.image('gallery/prettyCheckers'));
    pattern.velocity.set(-18, 12);
    pattern.alpha = 0.32;
    pattern.scrollFactor.set();
    add(pattern);

    var outer = new FlxSprite(35, 35).makeGraphic(FlxG.width - 70, FlxG.height - 80, 0xFF070A10);
    outer.scrollFactor.set();
    add(outer);

    var inner = new FlxSprite(49, 49).makeGraphic(FlxG.width - 98, FlxG.height - 108, 0xFF31587B);
    inner.scrollFactor.set();
    add(inner);

    var screen = new FlxSprite(240, 92).makeGraphic(800, 430, 0xFFE4E7E3);
    screen.scrollFactor.set();
    add(screen);

    preview = new FlxSprite(252, 104);
    preview.antialiasing = true;
    preview.scrollFactor.set();
    add(preview);

    var leftArrow = new FlxText(78, 270, 130, '<');
    leftArrow.setFormat(Paths.font('ttg.ttf'), 90, FlxColor.WHITE, 'center');
    leftArrow.alignment = 'center';
    leftArrow.scrollFactor.set();
    add(leftArrow);

    var rightArrow = new FlxText(1075, 270, 130, '>');
    rightArrow.setFormat(Paths.font('ttg.ttf'), 90, FlxColor.WHITE, 'center');
    rightArrow.alignment = 'center';
    rightArrow.scrollFactor.set();
    add(rightArrow);

    titleText = new FlxText(220, 535, 840, '');
    titleText.setFormat(Paths.font('ttg.ttf'), 30, FlxColor.WHITE, 'center');
    titleText.alignment = 'center';
    titleText.scrollFactor.set();
    add(titleText);

    artistText = new FlxText(220, 576, 840, '');
    artistText.setFormat(Paths.font('comm.ttf'), 19, 0xFFFFD52F, 'center');
    artistText.alignment = 'center';
    artistText.scrollFactor.set();
    add(artistText);

    countText = new FlxText(220, 613, 840, '');
    countText.setFormat(Paths.font('comm.ttf'), 16, FlxColor.WHITE, 'center');
    countText.alignment = 'center';
    countText.scrollFactor.set();
    add(countText);

    var backPrompt = new FlxText(0, FlxG.height - 48, FlxG.width, 'BKSP  TO EXIT');
    backPrompt.setFormat(Paths.font('ttg.ttf'), 23, FlxColor.WHITE, 'center');
    backPrompt.alignment = 'center';
    backPrompt.scrollFactor.set();
    add(backPrompt);

    refreshGallery();
}

function refreshGallery() {
    var entry = entries[selected];
    preview.loadGraphic(Paths.image('gallery/images/' + entry.file));
    preview.setGraphicSize(770, 400);
    preview.updateHitbox();
    preview.x = 255 + (770 - preview.width) / 2;
    preview.y = 107 + (400 - preview.height) / 2;

    titleText.text = Std.string(entry.title);
    artistText.text = 'DRAWN BY: ' + Std.string(entry.artist);
    countText.text = (selected + 1) + ' / ' + entries.length + '     //     LEFT / RIGHT TO BROWSE';
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

    if (controls.BACK || FlxG.keys.justPressed.BACKSPACE)
        FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}