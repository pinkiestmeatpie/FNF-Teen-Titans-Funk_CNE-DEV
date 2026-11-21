import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import openfl.filters.BlurFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

var time:Float = 0;
var logoTop:FlxText;
var logoBottom:FlxText;
var pressText:FlxText;
var blurredBG:FlxSprite;

function createBlurredScene():FlxSprite {
    var source = Paths.image('stages/warehouse/bg').bitmap;
    var bitmap = source.clone();
    bitmap.applyFilter(source, new Rectangle(0, 0, source.width, source.height), new Point(0, 0), new BlurFilter(9, 9, 2));
    var sprite = new FlxSprite().loadGraphic(bitmap);
    sprite.setGraphicSize(FlxG.width, FlxG.height);
    sprite.updateHitbox();
    sprite.scrollFactor.set();
    return sprite;
}

function create() {
    FlxG.camera.bgColor = 0xFFF5F2EC;
    CoolUtil.playMenuSong();

    blurredBG = createBlurredScene();
    blurredBG.alpha = 0.78;
    add(blurredBG);

    // Pale veil keeps the logo readable over the softly blurred scene.
    var wash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xB8F5F2EC);
    wash.scrollFactor.set();
    add(wash);

    var logoShadowTop = new FlxText(0, 208, FlxG.width, 'TEEN TITANS');
    logoShadowTop.setFormat(Paths.font('ttg.ttf'), 92, 0xFF17171D, 'center');
    logoShadowTop.alignment = 'center';
    logoShadowTop.x += 7;
    logoShadowTop.y += 8;
    logoShadowTop.scrollFactor.set();
    add(logoShadowTop);

    logoTop = new FlxText(0, 202, FlxG.width, 'TEEN TITANS');
    logoTop.setFormat(Paths.font('ttg.ttf'), 92, 0xFF18B9D5, 'center');
    logoTop.alignment = 'center';
    logoTop.scrollFactor.set();
    add(logoTop);

    var logoShadowBottom = new FlxText(0, 305, FlxG.width, 'FUNK!');
    logoShadowBottom.setFormat(Paths.font('ttg.ttf'), 146, 0xFF17171D, 'center');
    logoShadowBottom.alignment = 'center';
    logoShadowBottom.x += 8;
    logoShadowBottom.y += 9;
    logoShadowBottom.scrollFactor.set();
    add(logoShadowBottom);

    logoBottom = new FlxText(0, 296, FlxG.width, 'FUNK!');
    logoBottom.setFormat(Paths.font('ttg.ttf'), 146, 0xFFFFD52F, 'center');
    logoBottom.alignment = 'center';
    logoBottom.scrollFactor.set();
    add(logoBottom);

    var credit = new FlxText(0, 457, FlxG.width, 'a mod by pinkiestmeatpie');
    credit.setFormat(Paths.font('comm.ttf'), 22, 0xFF25252D, 'center');
    credit.alignment = 'center';
    credit.scrollFactor.set();
    add(credit);

    pressText = new FlxText(0, FlxG.height - 72, FlxG.width, 'PRESS ENTER TO START');
    pressText.setFormat(Paths.font('ttg.ttf'), 27, 0xFF20202A, 'center');
    pressText.alignment = 'center';
    pressText.scrollFactor.set();
    add(pressText);
}

function beatHit(curBeat:Int) {
    logoTop.scale.set(1.055, 1.055);
    logoBottom.scale.set(1.075, 1.075);
}

function update(elapsed:Float) {
    time += elapsed;
    logoTop.scale.x = FlxMath.lerp(logoTop.scale.x, 1, 0.22);
    logoTop.scale.y = FlxMath.lerp(logoTop.scale.y, 1, 0.22);
    logoBottom.scale.x = FlxMath.lerp(logoBottom.scale.x, 1, 0.22);
    logoBottom.scale.y = FlxMath.lerp(logoBottom.scale.y, 1, 0.22);
    pressText.alpha = 0.62 + Math.sin(time * 4) * 0.28;

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new ModState('TTF/TTFMainMenu'));
    }
}
