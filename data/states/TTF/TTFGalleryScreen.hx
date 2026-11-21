var entries:Array<Dynamic> = [];
var selected:Int = 0;
var artwork:FlxSprite;
var placeholder:FlxText;
var title:FlxText;
var description:FlxText;
var count:FlxText;
function create() {
    var path = Paths.image('gallery/data', null, false, 'json');
    if (Assets.exists(path)) entries = Json.parse(Assets.getText(path)).images;
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF15334A));
    add(new FlxSprite(220, 80).makeGraphic(840, 490, 0xFFF5F4EE));
    artwork = new FlxSprite();
    add(artwork);
    placeholder = new FlxText(220, 285, 840, 'GALLERY ART', 35);
    placeholder.setFormat(Paths.font('comm.ttf'), 35, 0xFF777777, 'center');
    add(placeholder);
    title = new FlxText(0, 20, FlxG.width, '', 27);
    title.setFormat(Paths.font('comm.ttf'), 27, FlxColor.WHITE, 'center');
    add(title);
    description = new FlxText(210, 585, 860, '', 20);
    description.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    add(description);
    count = new FlxText(0, 660, FlxG.width, '', 19);
    count.setFormat(Paths.font('comm.ttf'), 19, FlxColor.WHITE, 'center');
    add(count);
    refresh();
}
function refresh() {
    if (entries == null || entries.length == 0) {
        artwork.visible = false;
        title.text = 'GALLERY';
        count.text = 'NO ART YET    ESC: BACK';
        return;
    }
    var entry = entries[selected];
    title.text = entry.title;
    description.text = entry.description;
    count.text = '< ' + (selected + 1) + ' / ' + entries.length + ' >     LEFT / RIGHT: BROWSE    ESC: BACK';
    var path = Paths.image('gallery/images/' + entry.filename);
    if (Assets.exists(path)) {
        artwork.loadGraphic(path);
        var scale = Math.min(800 / artwork.width, 450 / artwork.height);
        artwork.setGraphicSize(Std.int(artwork.width * scale), Std.int(artwork.height * scale));
        artwork.updateHitbox();
        artwork.x = (FlxG.width - artwork.width) / 2;
        artwork.y = 325 - artwork.height / 2;
        artwork.antialiasing = entry.antialiasing;
        artwork.visible = true;
        placeholder.visible = false;
    } else {
        artwork.visible = false;
        placeholder.visible = true;
    }
}
function update(elapsed:Float) {
    var change = 0;
    if (controls.LEFT_P || controls.UP_P) change = -1;
    if (controls.RIGHT_P || controls.DOWN_P) change = 1;
    if (change != 0 && entries != null && entries.length > 0) {
        selected = FlxMath.wrap(selected + change, 0, entries.length - 1);
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh();
    }
    if (controls.BACK) FlxG.switchState(new MainMenuState());
}
