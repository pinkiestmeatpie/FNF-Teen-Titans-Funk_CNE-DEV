import funkin.options.OptionsMenu;
import funkin.options.TreeMenu;

var options:Array<String> = ['FREEPLAY', 'OPTIONS', 'CREDITS', 'GALLERY'];
var items:Array<FlxText> = [];
var selected:Int = 0;
var leaving:Bool = false;
var selectionTween:FlxTween;

function create() {
    CoolUtil.playMenuSong();
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF5F4EE));
    // A pair of simple bands stand in for the curved black lines in the sketch.
    var left = new FlxSprite(90, -70).makeGraphic(24, 860, FlxColor.BLACK);
    left.angle = 8;
    add(left);
    var right = new FlxSprite(1160, -70).makeGraphic(24, 860, FlxColor.BLACK);
    right.angle = -8;
    add(right);
    var heading = new FlxText(0, 45, FlxG.width, 'TEEN TITANS FUNK!', 24);
    heading.setFormat(Paths.font('comm.ttf'), 24, 0xFF777777, 'center');
    add(heading);
    for (i in 0...options.length) {
        var item = new FlxText(0, 160 + i * 95, FlxG.width, options[i], 62);
        item.setFormat(Paths.font('baveuse.ttf'), 62, FlxColor.BLACK, 'center');
        items.push(item);
        add(item);
        item.alpha = 0;
        item.y += 25;
        FlxTween.tween(item, {alpha: 1, y: 160 + i * 95}, 0.25, {ease: FlxEase.quadOut, startDelay: i * 0.055});
    }
    // Placeholder communicator badge from the sketch.
    add(new FlxSprite(1020, 495).makeGraphic(130, 105, FlxColor.BLACK));
    add(new FlxSprite(1025, 500).makeGraphic(120, 95, 0xFFFFDD32));
    var badge = new FlxText(1025, 506, 120, 'T\nSTATUS:\nSHUT IT!', 20);
    badge.setFormat(Paths.font('comm.ttf'), 20, FlxColor.BLACK, 'center');
    add(badge);
    var hint = new FlxText(0, 640, FlxG.width, 'UP / DOWN: CHOOSE    ENTER: SELECT    ESC: BACK', 20);
    hint.setFormat(Paths.font('comm.ttf'), 20, 0xFF555555, 'center');
    add(hint);
    refresh();
}
function refresh() {
    for (i in 0...items.length) {
        items[i].text = (i == selected ? '>  ' : '') + options[i] + (i == selected ? '  <' : '');
        items[i].color = i == selected ? 0xFF119DCB : FlxColor.BLACK;
    }
}
function update(elapsed:Float) {
    if (leaving) return;
    var change = 0;
    if (controls.UP_P) change = -1;
    if (controls.DOWN_P) change = 1;
    if (change != 0) {
        selected = FlxMath.wrap(selected + change, 0, options.length - 1);
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh();
        var previous = items[FlxMath.wrap(selected - change, 0, options.length - 1)];
        if (selectionTween != null) selectionTween.cancel();
        previous.scale.set(1, 1);
        var item = items[selected];
        item.scale.set(1.08, 1.08);
        selectionTween = FlxTween.tween(item.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.quadOut});
    }
    if (controls.BACK) {
        leaving = true;
        FlxG.switchState(new ModState('TTF/TTFTitleScreen', {showPlay: true}));
    } else if (controls.ACCEPT) {
        leaving = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        switch (selected) {
            case 0: FlxG.switchState(new FreeplayState());
            case 1:
                TreeMenu.lastState = MainMenuState;
                FlxG.switchState(new OptionsMenu());
            case 2: FlxG.switchState(new ModState('TTF/TTFCreditsScreen'));
            case 3: FlxG.switchState(new ModState('TTF/TTFGalleryScreen'));
        }
    }
}

function destroy() {
    for (item in items) FlxTween.cancelTweensOf(item);
    if (selectionTween != null) selectionTween.cancel();
}
