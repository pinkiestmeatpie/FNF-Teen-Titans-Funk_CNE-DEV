import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;

var time:Float = 0;
var prompt:FlxText;
var titleA:FlxText;
var titleB:FlxText;

function create() {
    FlxG.camera.bgColor = 0xFFF2F0EA;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF2F0EA);
    bg.scrollFactor.set();
    add(bg);

    var blur = new FlxText(0, 175, FlxG.width, 'TEEN TITANS');
    blur.setFormat(Paths.font('ttg.ttf'), 104, 0xFFB8B6B0, 'center');
    blur.alignment = 'center';
    blur.alpha = 0.3;
    blur.scrollFactor.set();
    add(blur);

    var blur2 = new FlxText(0, 285, FlxG.width, 'FUNK!');
    blur2.setFormat(Paths.font('ttg.ttf'), 156, 0xFFB8B6B0, 'center');
    blur2.alignment = 'center';
    blur2.alpha = 0.3;
    blur2.scrollFactor.set();
    add(blur2);

    var frame = new FlxSprite(82, 112).makeGraphic(1116, 495, 0xFFFFA8B2);
    frame.scrollFactor.set();
    add(frame);

    var inset = new FlxSprite(94, 124).makeGraphic(1092, 471, 0xFFFAF8F2);
    inset.scrollFactor.set();
    add(inset);

    titleA = new FlxText(0, 205, FlxG.width, 'TEEN TITANS');
    titleA.setFormat(Paths.font('ttg.ttf'), 100, 0xFF20B8D3, 'center');
    titleA.alignment = 'center';
    titleA.scrollFactor.set();
    add(titleA);

    titleB = new FlxText(0, 305, FlxG.width, 'FUNK!');
    titleB.setFormat(Paths.font('ttg.ttf'), 150, 0xFFFFD52F, 'center');
    titleB.alignment = 'center';
    titleB.scrollFactor.set();
    add(titleB);

    var subtitle = new FlxText(0, 455, FlxG.width, 'A FRIDAY NIGHT FUNKIN’ FAN MOD');
    subtitle.setFormat(Paths.font('comm.ttf'), 19, 0xFF282832, 'center');
    subtitle.alignment = 'center';
    subtitle.scrollFactor.set();
    add(subtitle);

    prompt = new FlxText(0, 630, FlxG.width, 'PRESS ENTER TO START');
    prompt.setFormat(Paths.font('ttg.ttf'), 27, 0xFF20202A, 'center');
    prompt.alignment = 'center';
    prompt.scrollFactor.set();
    add(prompt);
}

function update(elapsed:Float) {
    time += elapsed;
    titleB.angle = Math.sin(time * 1.5) * 1.2;
    prompt.alpha = 0.58 + Math.sin(time * 4) * 0.3;

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFMainMenu'));
    }
}
