import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

// Comic-panel cold open from the supplied menu storyboard sketch.
var pulse:Float = 0;
var pressText:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFFF7F4EE;

    var paper = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF7F4EE);
    paper.scrollFactor.set();
    add(paper);

    var border = new FlxSprite(42, 62).makeGraphic(1196, 590, 0xFFFFAAB5);
    border.scrollFactor.set();
    add(border);

    var panel = new FlxSprite(54, 74).makeGraphic(1172, 566, 0xFF15151B);
    panel.scrollFactor.set();
    add(panel);

    var tag = new FlxText(82, 88, 360, 'TEEN TITANS // OPENING SCENE');
    tag.setFormat(Paths.font('ttg.ttf'), 25, 0xFFFFE35C, 'left');
    tag.scrollFactor.set();
    add(tag);

    // Two storyboard panels are intentionally simple stand-ins for the final drawings.
    var leftPanel = new FlxSprite(92, 145).makeGraphic(510, 390, 0xFFE8E2D9);
    leftPanel.scrollFactor.set();
    add(leftPanel);

    var rightPanel = new FlxSprite(678, 145).makeGraphic(510, 390, 0xFFD7E8EE);
    rightPanel.scrollFactor.set();
    add(rightPanel);

    var leftSky = new FlxSprite(112, 165).makeGraphic(470, 160, 0xFFB5D5DF);
    leftSky.scrollFactor.set();
    add(leftSky);

    var leftShadow = new FlxSprite(180, 300).makeGraphic(180, 185, 0xFF25232A);
    leftShadow.angle = -8;
    leftShadow.scrollFactor.set();
    add(leftShadow);

    var leftHero = new FlxText(130, 340, 470, 'ROBIN\n[POSE PLACEHOLDER]');
    leftHero.setFormat(Paths.font('ttg.ttf'), 34, 0xFF25232A, 'center');
    leftHero.alignment = 'center';
    leftHero.scrollFactor.set();
    add(leftHero);

    var rightHero = new FlxText(700, 270, 460, 'TITAN\n[POSE PLACEHOLDER]');
    rightHero.setFormat(Paths.font('ttg.ttf'), 40, 0xFF172C3A, 'center');
    rightHero.alignment = 'center';
    rightHero.scrollFactor.set();
    add(rightHero);

    var bubble = new FlxSprite(760, 175).makeGraphic(320, 82, 0xFFFFFFFF);
    bubble.scrollFactor.set();
    add(bubble);

    var bubbleText = new FlxText(770, 190, 300, 'TITANS, GO!');
    bubbleText.setFormat(Paths.font('ttg.ttf'), 32, 0xFF15151B, 'center');
    bubbleText.alignment = 'center';
    bubbleText.scrollFactor.set();
    add(bubbleText);

    pressText = new FlxText(0, 565, FlxG.width, 'PRESS ENTER');
    pressText.setFormat(Paths.font('ttg.ttf'), 30, FlxColor.WHITE, 'center');
    pressText.alignment = 'center';
    pressText.scrollFactor.set();
    add(pressText);

    var credit = new FlxText(0, 615, FlxG.width, 'A TEEN TITANS FUNK! MOD');
    credit.setFormat(Paths.font('comm.ttf'), 16, 0xFFFFE35C, 'center');
    credit.alignment = 'center';
    credit.scrollFactor.set();
    add(credit);
}

function update(elapsed:Float) {
    pulse += elapsed * 4;
    pressText.alpha = 0.58 + (Math.sin(pulse) * 0.32);

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFTitleScreen'));
    }
}
