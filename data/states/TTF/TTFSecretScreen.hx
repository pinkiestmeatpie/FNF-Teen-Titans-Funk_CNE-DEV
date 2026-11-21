// Hidden HYPNOTIZED page. Press H from the main menu to open it.
import funkin.backend.Paths;
import funkin.menus.MainMenuState;

var cover:FlxSprite;
var pulse:Float = 0;

function create() {
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF07050D);
    bg.scrollFactor.set();
    add(bg);

    var redWash = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF310A18);
    redWash.alpha = 0.35;
    redWash.scrollFactor.set();
    add(redWash);

    var panel = new FlxSprite(70, 70).makeGraphic(FlxG.width - 140, FlxG.height - 140, 0xE6000000);
    panel.scrollFactor.set();
    add(panel);

    var heading = new FlxText(0, 38, FlxG.width, 'CLASSIFIED // HYPNOTIZED');
    heading.setFormat(Paths.font('ttg.ttf'), 46, FlxColor.RED, 'center');
    heading.alignment = 'center';
    heading.scrollFactor.set();
    add(heading);

    cover = new FlxSprite(0, 0).loadGraphic(Paths.image('covers/hypnotized'));
    cover.setGraphicSize(520);
    cover.updateHitbox();
    cover.x = (FlxG.width - cover.width) / 2;
    cover.y = 130;
    cover.scrollFactor.set();
    cover.antialiasing = true;
    add(cover);

    var warning = new FlxText(160, 545, FlxG.width - 320, 'A HIDDEN TRACK HAS BEEN FOUND.');
    warning.setFormat(Paths.font('ttg.ttf'), 30, FlxColor.WHITE, 'center');
    warning.alignment = 'center';
    warning.scrollFactor.set();
    add(warning);

    var controlsText = new FlxText(80, FlxG.height - 55, FlxG.width - 160, 'ENTER  PLAY HYPNOTIZED     //     ESC  RETURN');
    controlsText.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    controlsText.alignment = 'center';
    controlsText.scrollFactor.set();
    add(controlsText);
}

function update(elapsed:Float) {
    pulse += elapsed * 2.5;
    cover.alpha = 0.86 + (Math.sin(pulse) * 0.14);

    if (controls.ACCEPT) {
        PlayState.loadSong('HYPNOTIZED', 'hard', false, false);
        FlxG.switchState(new PlayState());
    }
    if (controls.BACK) FlxG.switchState(new MainMenuState());
}
