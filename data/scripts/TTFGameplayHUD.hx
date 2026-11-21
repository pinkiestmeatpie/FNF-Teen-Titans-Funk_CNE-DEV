// Teen Titans Funk! gameplay HUD accents.
// This keeps Codename Engine's normal health bar, icons, score, and judgement system;
// it only adds the custom top strip and a live song timer.
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.Paths;

var ttfClock:FlxText;

function postCreate() {
    var topStrip = new FlxSprite(0, 0).makeGraphic(FlxG.width, 76, 0xB80A0D18);
    topStrip.scrollFactor.set();
    topStrip.cameras = [camHUD];
    add(topStrip);

    var lowerAccent = new FlxSprite(0, 74).makeGraphic(FlxG.width, 4, 0xFF20D5C4);
    lowerAccent.scrollFactor.set();
    lowerAccent.cameras = [camHUD];
    add(lowerAccent);

    var leftLogo = new FlxText(28, 7, 260, 'TTF');
    leftLogo.setFormat(Paths.font('ttg.ttf'), 48, 0xFF33D3E4, 'left');
    leftLogo.scrollFactor.set();
    leftLogo.cameras = [camHUD];
    add(leftLogo);

    var rightLogo = new FlxText(FlxG.width - 288, 7, 260, 'TTF');
    rightLogo.setFormat(Paths.font('ttg.ttf'), 48, 0xFFFFD52A, 'right');
    rightLogo.alignment = 'right';
    rightLogo.scrollFactor.set();
    rightLogo.cameras = [camHUD];
    add(rightLogo);

    ttfClock = new FlxText(FlxG.width / 2 - 100, 23, 200, '00:00');
    ttfClock.setFormat(Paths.font('comm.ttf'), 30, FlxColor.WHITE, 'center');
    ttfClock.alignment = 'center';
    ttfClock.scrollFactor.set();
    ttfClock.cameras = [camHUD];
    add(ttfClock);

    // Recolour the existing engine bar instead of replacing its gameplay logic.
    if (healthBar != null) {
        healthBar.createFilledBar(0xFFE94869, 0xFF20D5C4);
        healthBar.updateBar();
    }
}

function postUpdate(elapsed:Float) {
    if (ttfClock == null) return;

    var totalSeconds:Int = Std.int(Math.max(0, Conductor.songPosition) / 1000);
    var minutes:Int = Std.int(totalSeconds / 60);
    var seconds:Int = totalSeconds % 60;

    ttfClock.text =
        (minutes < 10 ? '0' : '') + minutes + ':' +
        (seconds < 10 ? '0' : '') + seconds;
}
