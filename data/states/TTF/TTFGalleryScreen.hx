import flixel.addons.display.FlxBackdrop;
// Gallery screen - the images here are placeholders and can be replaced freely.
import funkin.backend.Paths;
import funkin.menus.MainMenuState;

var entries:Array<Dynamic> = [
    {file: 'squareImageTest', title: 'ARTWORK PLACEHOLDER', description: 'Replace this image with finished promotional art.'},
    {file: 'widthTestImage', title: 'CHARACTER ART PLACEHOLDER', description: 'A space for sketches, character poses, or concept art.'},
    {file: 'heightTestImage', title: 'SCENE ART PLACEHOLDER', description: 'A space for backgrounds, screenshots, and other extras.'}
];

var selected:Int = 0;
var art:FlxSprite;
var titleText:FlxText;
var descriptionText:FlxText;
var counterText:FlxText;

function create() {
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF170D28);
    bg.scrollFactor.set();
    add(bg);

    var pattern = new FlxBackdrop();
    pattern.loadGraphic(Paths.image('gallery/prettyCheckers'));
    pattern.velocity.set(-18, 9);
    pattern.alpha = 0.16;
    pattern.scrollFactor.set();
    add(pattern);

    var panel = new FlxSprite(90, 105).makeGraphic(1100, 520, 0xE8090712);
    panel.scrollFactor.set();
    add(panel);

    var heading = new FlxText(0, 28, FlxG.width, 'TITANS // GALLERY');
    heading.setFormat(Paths.font('ttg.ttf'), 44, FlxColor.WHITE, 'center');
    heading.alignment = 'center';
    heading.scrollFactor.set();
    add(heading);

    art = new FlxSprite();
    art.scrollFactor.set();
    art.antialiasing = true;
    add(art);

    titleText = new FlxText(150, 540, 980, '');
    titleText.setFormat(Paths.font('ttg.ttf'), 34, FlxColor.YELLOW, 'center');
    titleText.alignment = 'center';
    titleText.scrollFactor.set();
    add(titleText);

    descriptionText = new FlxText(160, 585, 960, '');
    descriptionText.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    descriptionText.alignment = 'center';
    descriptionText.scrollFactor.set();
    add(descriptionText);

    counterText = new FlxText(0, FlxG.height - 45, FlxG.width, '');
    counterText.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    counterText.alignment = 'center';
    counterText.scrollFactor.set();
    add(counterText);

    refreshGallery();
}

function refreshGallery() {
    if (entries.length == 0) return;

    art.loadGraphic(Paths.image('gallery/images/' + entries[selected].file));
    art.setGraphicSize(740);
    art.updateHitbox();
    art.x = (FlxG.width - art.width) / 2;
    art.y = 105 + (395 - art.height) / 2;

    titleText.text = entries[selected].title;
    descriptionText.text = entries[selected].description;
    counterText.text = 'LEFT / RIGHT  BROWSE     //     ESC  BACK     //     ' + (selected + 1) + ' OF ' + entries.length;
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

    if (controls.BACK) FlxG.switchState(new MainMenuState());
}
