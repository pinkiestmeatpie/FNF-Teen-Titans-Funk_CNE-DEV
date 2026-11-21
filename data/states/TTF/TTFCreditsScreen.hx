import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

// Keep names editable until the final contributor list is supplied.
var credits:Array<Dynamic> = [
    {role: 'PROJECT', name: 'TEEN TITANS FUNK!', note: 'A FRIDAY NIGHT FUNKIN’ FAN MOD', color: 0xFF4D8194},
    {role: 'CREATOR / PROJECT LEAD', name: 'NAME GOES HERE', note: 'ADD CREDIT NAME OR HANDLE', color: 0xFFE65B70},
    {role: 'PROGRAMMING', name: 'NAME GOES HERE', note: 'ADD PROGRAMMING CREDITS', color: 0xFF4B9E9B},
    {role: 'ART & ANIMATION', name: 'NAME GOES HERE', note: 'ADD ART AND ANIMATION CREDITS', color: 0xFF9870B4},
    {role: 'MUSIC & CHARTING', name: 'NAME GOES HERE', note: 'ADD MUSIC AND CHARTING CREDITS', color: 0xFFD99B38},
    {role: 'SPECIAL THANKS', name: 'THANK YOU!', note: 'THANKS FOR PLAYING TEEN TITANS FUNK!', color: 0xFF4D8194}
];

var selected:Int = 0;
var card:FlxSprite;
var avatar:FlxSprite;
var avatarLetter:FlxText;
var roleText:FlxText;
var nameText:FlxText;
var noteText:FlxText;
var pageText:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFF9CCBD2;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF9CCBD2);
    bg.scrollFactor.set();
    add(bg);

    var wall = new FlxSprite(0, 0).makeGraphic(FlxG.width, 470, 0xFFB9DDE0);
    wall.scrollFactor.set();
    add(wall);

    // TV cabinet and screen, as shown in the credits thumbnail.
    var cabinet = new FlxSprite(120, 74).makeGraphic(1040, 500, 0xFF246777);
    cabinet.scrollFactor.set();
    add(cabinet);

    var bezel = new FlxSprite(145, 95).makeGraphic(990, 425, 0xFF183D4A);
    bezel.scrollFactor.set();
    add(bezel);

    card = new FlxSprite(170, 120).makeGraphic(940, 375, 0xFFE7F0E9);
    card.scrollFactor.set();
    add(card);

    var screenLine = new FlxSprite(190, 141).makeGraphic(900, 4, 0xFF246777);
    screenLine.scrollFactor.set();
    add(screenLine);

    avatar = new FlxSprite(215, 180).makeGraphic(265, 260, 0xFF4D8194);
    avatar.scrollFactor.set();
    add(avatar);

    avatarLetter = new FlxText(215, 208, 265, 'T');
    avatarLetter.setFormat(Paths.font('ttg.ttf'), 150, FlxColor.WHITE, 'center');
    avatarLetter.alignment = 'center';
    avatarLetter.scrollFactor.set();
    add(avatarLetter);

    roleText = new FlxText(525, 178, 545, '');
    roleText.setFormat(Paths.font('ttg.ttf'), 29, 0xFF246777, 'left');
    roleText.scrollFactor.set();
    add(roleText);

    nameText = new FlxText(525, 237, 545, '');
    nameText.setFormat(Paths.font('ttg.ttf'), 43, 0xFF1E2730, 'left');
    nameText.scrollFactor.set();
    add(nameText);

    noteText = new FlxText(525, 315, 545, '');
    noteText.setFormat(Paths.font('comm.ttf'), 22, 0xFF1E2730, 'left');
    noteText.scrollFactor.set();
    add(noteText);

    var lowerCabinet = new FlxSprite(75, 574).makeGraphic(1130, 78, 0xFF246777);
    lowerCabinet.scrollFactor.set();
    add(lowerCabinet);

    var stand = new FlxSprite(420, 651).makeGraphic(440, 27, 0xFF183D4A);
    stand.scrollFactor.set();
    add(stand);

    pageText = new FlxText(0, 670, FlxG.width, '');
    pageText.setFormat(Paths.font('comm.ttf'), 17, 0xFF202A31, 'center');
    pageText.alignment = 'center';
    pageText.scrollFactor.set();
    add(pageText);

    var help = new FlxText(0, 12, FlxG.width, 'CREDITS // THE PEOPLE BEHIND THE MOD');
    help.setFormat(Paths.font('ttg.ttf'), 30, FlxColor.WHITE, 'center');
    help.alignment = 'center';
    help.scrollFactor.set();
    add(help);

    refreshCredits();
}

function refreshCredits() {
    var entry = credits[selected];
    roleText.text = Std.string(entry.role);
    nameText.text = Std.string(entry.name);
    noteText.text = Std.string(entry.note);
    avatar.color = entry.color;
    avatarLetter.text = selected == 0 ? 'TTF' : (selected == 5 ? '♥' : '?');
    pageText.text = 'LEFT / RIGHT  CHANGE PAGE     //     ESC  BACK     //     ' + (selected + 1) + ' / ' + credits.length;
}

function update(elapsed:Float) {
    if (controls.LEFT_P) {
        selected = (selected - 1 + credits.length) % credits.length;
        refreshCredits();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    } else if (controls.RIGHT_P) {
        selected = (selected + 1) % credits.length;
        refreshCredits();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    }

    if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
