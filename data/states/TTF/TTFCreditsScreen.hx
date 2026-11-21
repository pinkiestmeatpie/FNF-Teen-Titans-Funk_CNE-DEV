import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
// Credits layout template. Replace the generic roles with confirmed names and links.
import funkin.backend.Paths;
import funkin.menus.MainMenuState;

var pages:Array<Dynamic> = [
    {role: 'PROJECT', detail: 'TEEN TITANS FUNK!'},
    {role: 'MOD CREATOR', detail: 'NAME / HANDLE TO BE ADDED'},
    {role: 'PROGRAMMING', detail: 'CREDITS TO BE ADDED'},
    {role: 'ART & ANIMATION', detail: 'CREDITS TO BE ADDED'},
    {role: 'MUSIC & CHARTING', detail: 'CREDITS TO BE ADDED'},
    {role: 'SPECIAL THANKS', detail: 'THANK YOU FOR PLAYING!'}
];

var selected:Int = 0;
var roleText:FlxText;
var detailText:FlxText;
var pageText:FlxText;

function create() {
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF07131C);
    bg.scrollFactor.set();
    add(bg);

    var stripe = new FlxSprite(0, 0).makeGraphic(FlxG.width, 22, 0xFFFFD52A);
    stripe.scrollFactor.set();
    add(stripe);

    var screen = new FlxSprite(110, 90).makeGraphic(1060, 520, 0xFF173B4B);
    screen.scrollFactor.set();
    add(screen);

    var inset = new FlxSprite(135, 115).makeGraphic(1010, 470, 0xFFDBE5E3);
    inset.scrollFactor.set();
    add(inset);

    var heading = new FlxText(0, 34, FlxG.width, 'CREDITS // THE TITANS CREW');
    heading.setFormat(Paths.font('ttg.ttf'), 42, FlxColor.WHITE, 'center');
    heading.alignment = 'center';
    heading.scrollFactor.set();
    add(heading);

    var label = new FlxText(205, 190, 870, 'PROJECT ARCHIVE');
    label.setFormat(Paths.font('ttg.ttf'), 36, 0xFF182D3A, 'center');
    label.alignment = 'center';
    label.scrollFactor.set();
    add(label);

    roleText = new FlxText(205, 270, 870, '');
    roleText.setFormat(Paths.font('ttg.ttf'), 34, 0xFFB52B38, 'center');
    roleText.alignment = 'center';
    roleText.scrollFactor.set();
    add(roleText);

    detailText = new FlxText(205, 335, 870, '');
    detailText.setFormat(Paths.font('comm.ttf'), 28, 0xFF182D3A, 'center');
    detailText.alignment = 'center';
    detailText.scrollFactor.set();
    add(detailText);

    pageText = new FlxText(0, FlxG.height - 55, FlxG.width, '');
    pageText.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    pageText.alignment = 'center';
    pageText.scrollFactor.set();
    add(pageText);

    refreshCredits();
}

function refreshCredits() {
    roleText.text = pages[selected].role;
    detailText.text = pages[selected].detail;
    pageText.text = 'UP / DOWN  BROWSE     //     ESC  BACK     //     ' + (selected + 1) + ' OF ' + pages.length;
}

function update(elapsed:Float) {
    if (controls.UP_P) {
        selected = (selected - 1 + pages.length) % pages.length;
        refreshCredits();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    } else if (controls.DOWN_P) {
        selected = (selected + 1) % pages.length;
        refreshCredits();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    }

    if (controls.BACK) FlxG.switchState(new MainMenuState());
}
