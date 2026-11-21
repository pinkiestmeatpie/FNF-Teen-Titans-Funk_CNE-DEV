import funkin.menus.FreeplayState.FreeplaySonglist;

var songs:Array<Dynamic> = [];
var selected:Int = 0;
var difficulty:Int = 0;
var rows:Array<FlxText> = [];
var cover:FlxSprite;
var coverLabel:FlxText;
var diffLabel:FlxText;
var leaving:Bool = false;

function create() {
    CoolUtil.playMenuSong();
    songs = FreeplaySonglist.get().songs;
    add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
    var heading = new FlxText(55, 45, 560, 'FREEPLAY', 36);
    heading.setFormat(Paths.font('comm.ttf'), 36, FlxColor.WHITE, 'left');
    add(heading);
    for (i in 0...5) {
        var row = new FlxText(65, 135 + i * 75, 570, '', 38);
        row.setFormat(Paths.font('comm.ttf'), 38, 0xFFFFFF00, 'left');
        rows.push(row);
        add(row);
    }
    add(new FlxSprite(690, 85).makeGraphic(525, 510, 0xFF252525));
    cover = new FlxSprite();
    add(cover);
    coverLabel = new FlxText(710, 315, 485, 'SONG COVER', 30);
    coverLabel.setFormat(Paths.font('comm.ttf'), 30, 0xFFAAAAAA, 'center');
    add(coverLabel);
    diffLabel = new FlxText(55, 570, 570, '', 24);
    diffLabel.setFormat(Paths.font('comm.ttf'), 24, FlxColor.WHITE, 'left');
    add(diffLabel);
    var hint = new FlxText(55, 655, 1170, 'UP / DOWN: SONG    LEFT / RIGHT: DIFFICULTY    ENTER: PLAY    ESC: BACK', 19);
    hint.setFormat(Paths.font('comm.ttf'), 19, 0xFFAAAAAA, 'center');
    add(hint);
    refresh();
}
function refresh() {
    if (songs.length == 0) {
        rows[0].text = 'NO SONGS FOUND';
        cover.visible = false;
        diffLabel.text = '';
        return;
    }
    var first = Std.int(Math.max(0, Math.min(selected - 2, songs.length - 5)));
    for (i in 0...rows.length) {
        var index = first + i;
        rows[i].text = index < songs.length ? (index == selected ? '> ' : '  ') + songs[index].displayName.toUpperCase() : '';
        rows[i].alpha = index == selected ? 1 : 0.6;
    }
    var diffs = songs[selected].difficulties;
    diffLabel.text = diffs.length > 0 ? '<  ' + diffs[difficulty].toUpperCase() + '  >' : 'NO CHART AVAILABLE';
    var coverPath = Paths.image('covers/' + songs[selected].name.toLowerCase());
    if (Assets.exists(coverPath)) {
        cover.loadGraphic(coverPath);
        var scale = Math.min(485 / cover.width, 470 / cover.height);
        cover.setGraphicSize(Std.int(cover.width * scale), Std.int(cover.height * scale));
        cover.updateHitbox();
        cover.x = 952 - cover.width / 2;
        cover.y = 340 - cover.height / 2;
        cover.visible = true;
        coverLabel.visible = false;
    } else {
        cover.visible = false;
        coverLabel.visible = true;
    }
}
function update(elapsed:Float) {
    if (leaving) return;
    var change = 0;
    if (controls.UP_P) change = -1;
    if (controls.DOWN_P) change = 1;
    if (change != 0 && songs.length > 0) {
        selected = FlxMath.wrap(selected + change, 0, songs.length - 1);
        difficulty = 0;
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh();
    }
    change = 0;
    if (controls.LEFT_P) change = -1;
    if (controls.RIGHT_P) change = 1;
    if (change != 0 && songs.length > 0 && songs[selected].difficulties.length > 0) {
        difficulty = FlxMath.wrap(difficulty + change, 0, songs[selected].difficulties.length - 1);
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
        refresh();
    }
    if (controls.BACK) {
        leaving = true;
        FlxG.switchState(new MainMenuState());
    } else if (controls.ACCEPT && songs.length > 0 && songs[selected].difficulties.length > 0) {
        leaving = true;
        Options.freeplayLastSong = songs[selected].name;
        Options.freeplayLastDifficulty = songs[selected].difficulties[difficulty];
        PlayState.loadSong(songs[selected].name, songs[selected].difficulties[difficulty], false, false);
        FlxG.switchState(new PlayState());
    }
}
