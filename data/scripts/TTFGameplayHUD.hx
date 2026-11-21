// Gameplay HUD accents based on the TTF storyboard UI thumbnail.
// Codename Engine's own health icons, score, judgement, and gameplay systems remain intact.
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.Paths;
import funkin.backend.system.Conductor;

var ttfClock:FlxText;
var ttfTitle:FlxText;

function postCreate() {
    // Top title strip and thin registration line.
    var topStrip = new FlxSprite(0, 0).makeGraphic(FlxG.width, 54, 0xC9000000);
    topStrip.scrollFactor.set();
    topStrip.cameras = [camHUD];
    add(topStrip);

    var accent = new FlxSprite(0, 52).makeGraphic(FlxG.width, 3, 0xFFFFAAB5);
    accent.scrollFactor.set();
    accent.cameras = [camHUD];
    add(accent);

    var leftMark = new FlxText(20, 5, 245, 'TTF');
    leftMark.setFormat(Paths.font('ttg.ttf'), 38, 0xFF20B8D3, 'left');
    leftMark.scrollFactor.set();
    leftMark.cameras = [camHUD];
    add(leftMark);

    ttfClock = new FlxText(FlxG.width * 0.5 - 105, 13, 210, '00:00');
    ttfClock.setFormat(Paths.font('comm.ttf'), 25, FlxColor.WHITE, 'center');
    ttfClock.alignment = 'center';
    ttfClock.scrollFactor.set();
    ttfClock.cameras = [camHUD];
    add(ttfClock);

    ttfTitle = new FlxText(FlxG.width - 290, 9, 270, 'TEEN TITANS');
    ttfTitle.setFormat(Paths.font('ttg.ttf'), 27, 0xFFFFD52F, 'right');
    ttfTitle.alignment = 'right';
    ttfTitle.scrollFactor.set();
    ttfTitle.cameras = [camHUD];
    add(ttfTitle);

    // Keep Codename Engine's health bar/icons/score, but give its fill the TTF palette.
    if (healthBar != null) {
        healthBar.createFilledBar(0xFF20B8D3, 0xFFB7E46B);
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
