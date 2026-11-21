// Placeholder title screen. Replace the text and shapes with final title artwork.
var leaving:Bool = false;
var prompt:FlxText;
var time:Float = 0;

function create() {
    CoolUtil.playMenuSong();
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFE7E7E7));
    var panel = new FlxSprite(65, 65).makeGraphic(1150, 590, 0xFFD5D5D5);
    add(panel);
    var shadow = new FlxText(0, 173, FlxG.width, "TEEN TITANS\nFUNK!", 100);
    shadow.setFormat(Paths.font('baveuse.ttf'), 100, FlxColor.BLACK, 'center');
    shadow.angle = -3;
    add(shadow);
    var logo = new FlxText(-7, 163, FlxG.width, "TEEN TITANS\nFUNK!", 100);
    logo.setFormat(Paths.font('baveuse.ttf'), 100, 0xFF27B5E7, 'center');
    logo.angle = -3;
    add(logo);
    var byline = new FlxText(0, 488, FlxG.width, "A MOD BY PINKIESTMEATPIE", 22);
    byline.setFormat(Paths.font('comm.ttf'), 22, FlxColor.BLACK, 'center');
    add(byline);
    prompt = new FlxText(0, 595, FlxG.width, "PRESS ENTER", 26);
    prompt.setFormat(Paths.font('comm.ttf'), 26, FlxColor.BLACK, 'center');
    add(prompt);
}

function update(elapsed:Float) {
    time += elapsed;
    prompt.alpha = 0.65 + Math.sin(time * 3) * 0.35;
    if (!leaving && controls.ACCEPT) {
        leaving = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFBeforeTitle'));
    }
}
