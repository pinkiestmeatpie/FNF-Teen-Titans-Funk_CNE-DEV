import funkin.menus.TitleState;

var acceptPressed:Bool = false;
var canSkip:Bool = false;
function create() {
    var noteText:String = 'evil robin';
    var noteTxt:FlxText = new FlxText(0, 0, 0, noteText);
    noteTxt.setFormat(Paths.font('baveuse.ttf'), 32, FlxColor.WHITE, 'center');
    noteTxt.screenCenter();
    noteTxt.antialiasing = true;
    noteTxt.setPosition(Math.floor(noteTxt.x), Math.floor(noteTxt.y));
    add(noteTxt);

    var pressTxt:FlxText = new FlxText(0, FlxG.height-120, 0, 'Press Enter to Continue');
    pressTxt.setFormat(Paths.font('akira.otf'), 28, FlxColor.WHITE, 'center');
    pressTxt.screenCenter(FlxAxes.X);
    pressTxt.alpha = 0;
    pressTxt.antialiasing = true;
    pressTxt.setPosition(Math.floor(pressTxt.x), Math.floor(pressTxt.y));
    add(pressTxt);

    new FlxTimer().start(2, () -> {
        canSkip = true;
        FlxTween.tween(pressTxt, {alpha: 1}, 0.6, {ease: FlxEase.circOut});
    });
}

function update() {
    if (!acceptPressed && canSkip && controls.ACCEPT) {
        acceptPressed = true;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
		FlxG.camera.flash(FlxColor.WHITE, 2, () -> {
            FlxG.camera.fade(FlxColor.BLACK, 2, false, () -> {
                FlxG.switchState(new TitleState());
            });
        });
    }
}