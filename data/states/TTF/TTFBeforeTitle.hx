// The PLAY panel between the title screen and the main menu.
var leaving:Bool = false;
function create() {
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF5F4EE));
    add(new FlxSprite(60, 60).makeGraphic(1160, 600, FlxColor.BLACK));
    add(new FlxSprite(72, 72).makeGraphic(1136, 576, 0xFFF5F4EE));
    var play = new FlxText(110, 170, 650, 'PLAY', 180);
    play.setFormat(Paths.font('baveuse.ttf'), 180, FlxColor.BLACK, 'center');
    play.angle = -8;
    add(play);
    add(new FlxSprite(860, 155).makeGraphic(260, 380, 0xFFD1D1D1));
    var art = new FlxText(870, 300, 240, 'CHARACTER\nART', 35);
    art.setFormat(Paths.font('comm.ttf'), 35, 0xFF555555, 'center');
    add(art);
    var hint = new FlxText(100, 580, 700, 'ENTER: PLAY    ESC: BACK', 24);
    hint.setFormat(Paths.font('comm.ttf'), 24, FlxColor.BLACK, 'center');
    add(hint);
}
function update(elapsed:Float) {
    if (leaving) return;
    if (controls.ACCEPT) {
        leaving = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new MainMenuState());
    } else if (controls.BACK) {
        leaving = true;
        FlxG.switchState(new TitleState());
    }
}
