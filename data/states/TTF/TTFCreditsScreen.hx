// Replace these placeholder entries with the team's credits.
var credits:Array<Dynamic> = [
    {name: 'PINKIESTMEATPIE', role: 'MOD CREATOR', description: 'Teen Titans Funk!'},
    {name: 'YOUR TEAM', role: 'CREDITS', description: 'Add the rest of the team here!'}
];
var selected:Int = 0;
var nameText:FlxText;
var roleText:FlxText;
var descText:FlxText;
var countText:FlxText;
function create() {
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF82BCCB));
    add(new FlxSprite(120, 60).makeGraphic(1040, 560, 0xFF305565));
    add(new FlxSprite(145, 85).makeGraphic(990, 510, 0xFFF7F6ED));
    add(new FlxSprite(190, 180).makeGraphic(300, 300, 0xFFD3D6D3));
    var avatar = new FlxText(190, 290, 300, 'PORTRAIT', 26);
    avatar.setFormat(Paths.font('comm.ttf'), 26, 0xFF666666, 'center');
    add(avatar);
    nameText = new FlxText(525, 165, 560, '', 48);
    nameText.setFormat(Paths.font('baveuse.ttf'), 48, 0xFFD94949, 'left');
    add(nameText);
    roleText = new FlxText(525, 260, 560, '', 25);
    roleText.setFormat(Paths.font('comm.ttf'), 25, FlxColor.BLACK, 'left');
    add(roleText);
    descText = new FlxText(525, 320, 560, '', 24);
    descText.setFormat(Paths.font('comm.ttf'), 24, 0xFF555555, 'left');
    add(descText);
    countText = new FlxText(0, 640, FlxG.width, '', 20);
    countText.setFormat(Paths.font('comm.ttf'), 20, FlxColor.BLACK, 'center');
    add(countText);
    refresh();
}
function refresh() {
    nameText.text = credits[selected].name;
    roleText.text = credits[selected].role;
    descText.text = credits[selected].description;
    for (text in [nameText, roleText, descText]) {
        FlxTween.cancelTweensOf(text);
        text.alpha = 0;
        text.x = 550;
        FlxTween.tween(text, {alpha: 1, x: 525}, 0.25, {ease: FlxEase.quadOut});
    }
    countText.text = '< ' + (selected + 1) + ' / ' + credits.length + ' >     LEFT / RIGHT: BROWSE    ESC: BACK';
}
function update(elapsed:Float) {
    var change = 0;
    if (controls.LEFT_P || controls.UP_P) change = -1;
    if (controls.RIGHT_P || controls.DOWN_P) change = 1;
    if (change != 0) {
        selected = FlxMath.wrap(selected + change, 0, credits.length - 1);
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh();
    }
    if (controls.BACK) FlxG.switchState(new MainMenuState());
}

function destroy() {
    for (text in [nameText, roleText, descText]) FlxTween.cancelTweensOf(text);
}
