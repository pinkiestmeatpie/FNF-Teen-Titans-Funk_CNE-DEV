import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

// Opening comic panel shown before the title screen.
var pulse:Float = 0;
var prompt:FlxText;
var caption:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFFF5F1EA;

    var paper = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF5F1EA);
    paper.scrollFactor.set();
    add(paper);

    var frame = new FlxSprite(44, 70).makeGraphic(FlxG.width - 88, FlxG.height - 145, 0xFFFFA9B5);
    frame.scrollFactor.set();
    add(frame);

    var inset = new FlxSprite(56, 82).makeGraphic(FlxG.width - 112, FlxG.height - 169, 0xFF181821);
    inset.scrollFactor.set();
    add(inset);

    // Scene plate: use the mod's own stage art, not the unrelated old menu theme.
    var scene = new FlxSprite().loadGraphic(Paths.image('stages/warehouse/bg'));
    scene.setGraphicSize(FlxG.width - 142, FlxG.height - 245);
    scene.updateHitbox();
    scene.x = 71;
    scene.y = 115;
    scene.scrollFactor.set();
    scene.antialiasing = true;
    add(scene);

    var shade = new FlxSprite(71, 115).makeGraphic(FlxG.width - 142, FlxG.height - 245, 0x66000000);
    shade.scrollFactor.set();
    add(shade);

    var tag = new FlxText(88, 94, 500, 'TEEN TITANS FUNK!  //  INTRO');
    tag.setFormat(Paths.font('ttg.ttf'), 27, 0xFFFFD52F, 'left');
    tag.scrollFactor.set();
    add(tag);

    var speech = new FlxSprite(FlxG.width - 465, 155).makeGraphic(340, 105, 0xFFF8F5EE);
    speech.angle = 2;
    speech.scrollFactor.set();
    add(speech);

    var speechText = new FlxText(FlxG.width - 452, 180, 310, 'TITANS, GO!');
    speechText.setFormat(Paths.font('ttg.ttf'), 38, 0xFF17171D, 'center');
    speechText.alignment = 'center';
    speechText.scrollFactor.set();
    add(speechText);

    var lowerPanel = new FlxSprite(71, FlxG.height - 120).makeGraphic(FlxG.width - 142, 48, 0xF20A0A10);
    lowerPanel.scrollFactor.set();
    add(lowerPanel);

    caption = new FlxText(95, FlxG.height - 114, FlxG.width - 190, 'THE CITY IS IN TROUBLE. THE TITANS ARE ON THEIR WAY.');
    caption.setFormat(Paths.font('ttg.ttf'), 24, FlxColor.WHITE, 'center');
    caption.alignment = 'center';
    caption.scrollFactor.set();
    add(caption);

    prompt = new FlxText(0, FlxG.height - 58, FlxG.width, 'PRESS ENTER TO CONTINUE');
    prompt.setFormat(Paths.font('ttg.ttf'), 22, 0xFF20202A, 'center');
    prompt.alignment = 'center';
    prompt.scrollFactor.set();
    add(prompt);
}

function update(elapsed:Float) {
    pulse += elapsed * 4;
    prompt.alpha = 0.58 + Math.sin(pulse) * 0.32;

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFTitleScreen'));
    }
}
