// Placeholder HUD placement based on the sketch; keeps CNE's health and score logic.
var ttfTime:FlxText;
function postCreate() {
    ttfTime = new FlxText(FlxG.width / 2 - 70, 20, 140, '0:00', 24);
    ttfTime.setFormat(Paths.font('comm.ttf'), 24, FlxColor.WHITE, 'center');
    ttfTime.cameras = [camHUD];
    ttfTime.scrollFactor.set();
    add(ttfTime);
}
function postUpdate(elapsed:Float) {
    var seconds = Std.int(Math.max(0, Conductor.songPosition) / 1000);
    var minutes = Std.int(seconds / 60);
    seconds = seconds % 60;
    ttfTime.text = minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
    iconP2.x = healthBar.x - iconP2.width / 2;
    iconP1.x = healthBar.x + healthBar.width - iconP1.width / 2;
}
