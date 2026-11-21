import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
// Teen Titans Funk! - custom freeplay screen
import funkin.menus.FreeplaySonglist;
import funkin.backend.Paths;
import funkin.backend.CoolUtil;
import funkin.menus.MainMenuState;

var songs:Array<Any> = [];
var curSelected:Int = 0;
var previousSelected:Int = -1;
var songItems:Array<FlxText> = [];
var cover:FlxSprite;
var songTitle:FlxText;
var songInfo:FlxText;
var emptyMessage:FlxText;

function create() {
    CoolUtil.playMenuSong();

    var bg = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/bg'));
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.updateHitbox();
    bg.scrollFactor.set();
    bg.antialiasing = true;
    add(bg);

    var shade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    shade.alpha = 0.38;
    shade.scrollFactor.set();
    add(shade);

    var leftPanel = new FlxSprite(35, 95).makeGraphic(570, 535, 0xD9000710);
    leftPanel.scrollFactor.set();
    add(leftPanel);

    var rightPanel = new FlxSprite(645, 95).makeGraphic(600, 535, 0xD9000710);
    rightPanel.scrollFactor.set();
    add(rightPanel);

    var header = new FlxText(55, 28, 900, 'FREEPLAY // SELECT A SONG');
    header.setFormat(Paths.font('ttg.ttf'), 42, FlxColor.WHITE, 'left');
    header.scrollFactor.set();
    add(header);

    var songList = FreeplaySonglist.get();
    songs = songList == null || songList.songs == null ? [] : songList.songs;

    for (i in 0...songs.length) {
        var label = new FlxText(70, 170, 490, '');
        label.setFormat(Paths.font('ttg.ttf'), 36, FlxColor.WHITE, 'left');
        label.scrollFactor.set();
        label.ID = i;
        songItems.push(label);
        add(label);
    }

    cover = new FlxSprite(0, 0);
    cover.scrollFactor.set();
    cover.antialiasing = true;
    add(cover);

    songTitle = new FlxText(675, 470, 540, 'NO SONG SELECTED');
    songTitle.setFormat(Paths.font('ttg.ttf'), 34, FlxColor.YELLOW, 'center');
    songTitle.alignment = 'center';
    songTitle.scrollFactor.set();
    add(songTitle);

    songInfo = new FlxText(685, 520, 520, 'Use UP / DOWN to browse');
    songInfo.setFormat(Paths.font('comm.ttf'), 22, FlxColor.WHITE, 'center');
    songInfo.alignment = 'center';
    songInfo.scrollFactor.set();
    add(songInfo);

    emptyMessage = new FlxText(65, 210, 510, 'No songs were found in the freeplay song list.');
    emptyMessage.setFormat(Paths.font('comm.ttf'), 28, FlxColor.WHITE, 'center');
    emptyMessage.alignment = 'center';
    emptyMessage.scrollFactor.set();
    emptyMessage.visible = songs.length == 0;
    add(emptyMessage);

    var footer = new FlxText(40, FlxG.height - 48, FlxG.width - 80, 'ENTER  PLAY     //     ESC  BACK');
    footer.setFormat(Paths.font('comm.ttf'), 20, FlxColor.WHITE, 'center');
    footer.alignment = 'center';
    footer.scrollFactor.set();
    add(footer);

    if (songs.length > 0) refreshSelection();
}

function refreshSelection() {
    if (songs.length <= 0) return;

    for (i in 0...songItems.length) {
        var distance:Int = i - curSelected;
        var label:FlxText = songItems[i];
        label.visible = Math.abs(distance) <= 3;
        label.y = 178 + (distance * 88);
        label.x = 70 + (Math.abs(distance) * 18);
        label.text = (i == curSelected ? '> ' : '  ') + songs[i].displayName;
        label.color = i == curSelected ? FlxColor.YELLOW : FlxColor.WHITE;
        label.alpha = i == curSelected ? 1 : 0.58;
        label.size = i == curSelected ? 40 : 32;
    }

    var coverPath:String = 'menus/freeplay/covers/placeholder';
    var songName:String = songs[curSelected].name == null ? '' : Std.string(songs[curSelected].name).toLowerCase();
    switch (songName) {
        case 'abc': coverPath = 'covers/abc';
        case 'hypnotized': coverPath = 'covers/hypnotized';
    }

    cover.loadGraphic(Paths.image(coverPath));
    cover.setGraphicSize(440);
    cover.updateHitbox();
    cover.x = 725 + (440 - cover.width) / 2;
    cover.y = 125 + (390 - cover.height) / 2;

    songTitle.text = songs[curSelected].displayName.toUpperCase();
    songInfo.text = 'TRACK ' + (curSelected + 1) + ' / ' + songs.length + '     //     ENTER TO PLAY';
    previousSelected = curSelected;
}

function update(elapsed:Float) {
    if (songs.length <= 0) {
        if (controls.BACK) FlxG.switchState(new MainMenuState());
        return;
    }

    var moved:Bool = false;
    if (controls.UP_P) {
        curSelected--;
        moved = true;
    } else if (controls.DOWN_P) {
        curSelected++;
        moved = true;
    }

    if (curSelected < 0) curSelected = songs.length - 1;
    if (curSelected >= songs.length) curSelected = 0;

    if (moved && curSelected != previousSelected) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);
        refreshSelection();
    }

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        PlayState.loadSong(songs[curSelected].name, 'hard', false, false);
        FlxG.switchState(new PlayState());
    }

    if (controls.BACK) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
        FlxG.switchState(new MainMenuState());
    }
}
