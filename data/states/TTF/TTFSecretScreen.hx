import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.game.PlayState;

var pulse:Float = 0;
var playLabel:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFF090910;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF090910);
    bg.scrollFactor.set();
    add(bg);

    var border = new FlxSprite(44, 56).makeGraphic(1192, 600, 0xFFFFAAB5);
    border.scrollFactor.set();
    add(border);

    var panel = new FlxSprite(56, 68).makeGraphic(1168, 576, 0xFF11111A);
    panel.scrollFactor.set();
    add(panel);

    var heading = new FlxText(90, 82, 900, 'HYPNOTIZED // SECRET FILE');
    heading.setFormat(Paths.font('ttg.ttf'), 43, 0xFFFFD52F, 'left');
    heading.scrollFactor.set();
    add(heading);

    var sidebar = new FlxSprite(82, 160).makeGraphic(125, 405, 0xFF242431);
    sidebar.scrollFactor.set();
    add(sidebar);

    for (i in 0...5) {
        var icon = new FlxSprite(98, 180 + (i * 72)).makeGraphic(93, 54, i == 0 ? 0xFF9F47B8 : 0xFF4A4A58);
        icon.scrollFactor.set();
        add(icon);
        var iconText = new FlxText(98, 190 + (i * 72), 93, i == 0 ? '???' : 'LOCK');
        iconText.setFormat(Paths.font('comm.ttf'), 18, FlxColor.WHITE, 'center');
        iconText.alignment = 'center';
        iconText.scrollFactor.set();
        add(iconText);
    }

    var scene = new FlxSprite(240, 160).makeGraphic(940, 405, 0xFF20202D);
    scene.scrollFactor.set();
    add(scene);

    var leftFigure = new FlxSprite(355, 245).makeGraphic(210, 230, 0xFF486D91);
    leftFigure.scrollFactor.set();
    add(leftFigure);

    var rightFigure = new FlxSprite(840, 245).makeGraphic(210, 230, 0xFF5D6874);
    rightFigure.scrollFactor.set();
    add(rightFigure);

    var leftName = new FlxText(335, 485, 250, 'ROBIN');
    leftName.setFormat(Paths.font('ttg.ttf'), 28, FlxColor.WHITE, 'center');
    leftName.alignment = 'center';
    leftName.scrollFactor.set();
    add(leftName);

    var rightName = new FlxText(820, 485, 250, 'CYBORG');
    rightName.setFormat(Paths.font('ttg.ttf'), 28, FlxColor.WHITE, 'center');
    rightName.alignment = 'center';
    rightName.scrollFactor.set();
    add(rightName);

    var versus = new FlxText(570, 315, 250, 'VS');
    versus.setFormat(Paths.font('ttg.ttf'), 70, 0xFFFFD52F, 'center');
    versus.alignment = 'center';
    versus.scrollFactor.set();
    add(versus);

    playLabel = new FlxText(265, 535, 880, 'ENTER  //  PLAY HYPNOTIZED');
    playLabel.setFormat(Paths.font('ttg.ttf'), 30, 0xFFFFD52F, 'center');
    playLabel.alignment = 'center';
    playLabel.scrollFactor.set();
    add(playLabel);

    var hint = new FlxText(0, 675, FlxG.width, 'ESC  RETURN TO MENU');
    hint.setFormat(Paths.font('comm.ttf'), 18, FlxColor.WHITE, 'center');
    hint.alignment = 'center';
    hint.scrollFactor.set();
    add(hint);
}

function update(elapsed:Float) {
    pulse += elapsed * 3;
    playLabel.alpha = 0.7 + Math.sin(pulse) * 0.25;

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        PlayState.loadSong('HYPNOTIZED', 'hard', null, false, false);
        FlxG.switchState(new PlayState());
    }

    if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
