import flixel.FlxSprite;
import flixel.text.FlxText;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

// Content is editable; only the project-owner handle is populated from this repository.
var entries:Array<Dynamic> = [
    {role: 'MOD CREATOR', name: 'pinkiestmeatpie', description: 'Creator of Teen Titans Funk!', socials: 'github.com/pinkiestmeatpie', icon: 'git'},
    {role: 'MUSIC / CHARTING', name: 'NAME GOES HERE', description: 'Add a short description of their contribution.', socials: 'Socials / portfolio go here', icon: 'sc'},
    {role: 'ART / ANIMATION', name: 'NAME GOES HERE', description: 'Add a short description of their contribution.', socials: 'Socials / portfolio go here', icon: 'ig'},
    {role: 'PROGRAMMING', name: 'NAME GOES HERE', description: 'Add a short description of their contribution.', socials: 'Socials / portfolio go here', icon: 'git'},
    {role: 'SPECIAL THANKS', name: 'THANK YOU!', description: 'Thank you for playing Teen Titans Funk!', socials: 'You are awesome.', icon: 'yt'}
];

var selected:Int = 0;
var roleText:FlxText;
var nameText:FlxText;
var descriptionText:FlxText;
var socialIcon:FlxSprite;
var socialText:FlxText;
var pageText:FlxText;
var avatar:FlxSprite;
var avatarMark:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFF10151A;

    // Existing Cyborg-room TV scene from the project.
    var room = new FlxSprite().loadGraphic(Paths.image('stages/cyborg/screen'));
    room.setGraphicSize(FlxG.width, FlxG.height);
    room.updateHitbox();
    room.scrollFactor.set();
    room.antialiasing = true;
    add(room);

    // Place the credit card within the empty television screen.
    roleText = new FlxText(365, 176, 520, '');
    roleText.setFormat(Paths.font('ttg.ttf'), 20, 0xFF8DE8E9, 'center');
    roleText.alignment = 'center';
    roleText.scrollFactor.set();
    add(roleText);

    avatar = new FlxSprite(382, 229).makeGraphic(112, 128, 0xFF345E70);
    avatar.scrollFactor.set();
    add(avatar);

    avatarMark = new FlxText(382, 249, 112, 'TTF');
    avatarMark.setFormat(Paths.font('ttg.ttf'), 42, 0xFFFFFFFF, 'center');
    avatarMark.alignment = 'center';
    avatarMark.scrollFactor.set();
    add(avatarMark);

    nameText = new FlxText(515, 226, 350, '');
    nameText.setFormat(Paths.font('ttg.ttf'), 28, 0xFFF04F59, 'left');
    nameText.scrollFactor.set();
    add(nameText);

    descriptionText = new FlxText(515, 274, 350, '');
    descriptionText.setFormat(Paths.font('comm.ttf'), 17, 0xFF10151A, 'left');
    descriptionText.scrollFactor.set();
    add(descriptionText);

    socialIcon = new FlxSprite(516, 354);
    socialIcon.setGraphicSize(22, 22);
    socialIcon.updateHitbox();
    socialIcon.scrollFactor.set();
    add(socialIcon);

    socialText = new FlxText(546, 354, 320, '');
    socialText.setFormat(Paths.font('comm.ttf'), 16, 0xFF10151A, 'left');
    socialText.scrollFactor.set();
    add(socialText);

    pageText = new FlxText(0, FlxG.height - 38, FlxG.width, '');
    pageText.setFormat(Paths.font('comm.ttf'), 16, 0xFFFFFFFF, 'center');
    pageText.alignment = 'center';
    pageText.scrollFactor.set();
    add(pageText);

    refreshCredit();
}

function refreshCredit() {
    var entry = entries[selected];
    roleText.text = Std.string(entry.role);
    nameText.text = Std.string(entry.name);
    descriptionText.text = Std.string(entry.description);
    socialText.text = Std.string(entry.socials);
    socialIcon.loadGraphic(Paths.image('menus/credits/' + entry.icon));
    socialIcon.setGraphicSize(22, 22);
    socialIcon.updateHitbox();
    avatarMark.text = selected == 0 ? 'TTF' : (selected == entries.length - 1 ? '♥' : '?');
    pageText.text = 'LEFT / RIGHT  CHANGE CREDIT     //     BACKSPACE  EXIT     //     ' + (selected + 1) + ' / ' + entries.length;
}

function update(elapsed:Float) {
    if (controls.LEFT_P) {
        selected = (selected - 1 + entries.length) % entries.length;
        refreshCredit();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    } else if (controls.RIGHT_P) {
        selected = (selected + 1) % entries.length;
        refreshCredit();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    }

    if (controls.BACK || FlxG.keys.justPressed.BACKSPACE)
        FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}