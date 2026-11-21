import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.menus.FreeplaySonglist;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.game.PlayState;

var songs:Array<Any> = [];
var curSelected:Int = 0;
var lastSelected:Int = -1;
var songLabels:Array<FlxText> = [];
var cover:FlxSprite;
var songTitle:FlxText;
var songMeta:FlxText;
var emptyText:FlxText;

function create() {
    CoolUtil.playMenuSong();
    FlxG.camera.bgColor = 0xFF08080D;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF08080D);
    bg.scrollFactor.set();
    add(bg);

    // The black inset and pink frame follow the song-select mockup.
    var frame = new FlxSprite(42, 82).makeGraphic(1196, 558, 0xFFFFAAB5);
    frame.scrollFactor.set();
    add(frame);

    var panel = new FlxSprite(54, 94).makeGraphic(1172, 534, 0xFF09090F);
    panel.scrollFactor.set();
    add(panel);

    var heading = new FlxText(88, 112, 600, 'FREEPLAY');
    heading.setFormat(Paths.font('ttg.ttf'), 48, FlxColor.WHITE, 'left');
    heading.scrollFactor.set();
    add(heading);

    var subheading = new FlxText(91, 165, 500, 'SELECT A TRACK');
    subheading.setFormat(Paths.font('comm.ttf'), 18, 0xFFFFD52F, 'left');
    subheading.scrollFactor.set();
    add(subheading);

    var divider = new FlxSprite(620, 130).makeGraphic(4, 445, 0xFFFFAAB5);
    divider.scrollFactor.set();
    add(divider);

    var songList = FreeplaySonglist.get();
    songs = songList == null || songList.songs == null ? [] : songList.songs;

    for (i in 0...songs.length) {
        var label = new FlxText(90, 235, 490, '');
        label.setFormat(Paths.font('ttg.ttf'), 37, FlxColor.YELLOW, 'left');
        label.scrollFactor.set();
        label.ID = i;
        songLabels.push(label);
        add(label);
    }

    var coverFrame = new FlxSprite(690, 153).makeGraphic(475, 360, 0xFF24242C);
    coverFrame.scrollFactor.set();
    add(coverFrame);

    cover = new FlxSprite(702, 165);
    cover.scrollFactor.set();
    cover.antialiasing = true;
    add(cover);

    songTitle = new FlxText(690, 530, 475, 'SONG COVER');
    songTitle.setFormat(Paths.font('ttg.ttf'), 32, FlxColor.YELLOW, 'center');
    songTitle.alignment = 'center';
    songTitle.scrollFactor.set();
    add(songTitle);

    songMeta = new FlxText(690, 570, 475, 'ENTER TO PLAY');
    songMeta.setFormat(Paths.font('comm.ttf'), 18, FlxColor.WHITE, 'center');
    songMeta.alignment = 'center';
    songMeta.scrollFactor.set();
    add(songMeta);

    emptyText = new FlxText(85, 255, 500, 'NO TRACKS FOUND');
    emptyText.setFormat(Paths.font('ttg.ttf'), 30, FlxColor.WHITE, 'center');
    emptyText.alignment = 'center';
    emptyText.scrollFactor.set();
    emptyText.visible = songs.length == 0;
    add(emptyText);

    var footer = new FlxText(40, FlxG.height - 45, FlxG.width - 80, 'UP / DOWN  BROWSE     ENTER  PLAY     ESC  BACK');
    footer.setFormat(Paths.font('comm.ttf'), 18, FlxColor.WHITE, 'center');
    footer.alignment = 'center';
    footer.scrollFactor.set();
    add(footer);

    if (songs.length > 0) refreshSelection();
}

function refreshSelection() {
    if (songs.length == 0) return;

    for (i in 0...songLabels.length) {
        var distance = i - curSelected;
        songLabels[i].visible = Math.abs(distance) <= 3;
        songLabels[i].y = 250 + (distance * 76);
        songLabels[i].text = (i == curSelected ? '>  ' : '   ') + Std.string(songs[i].displayName).toUpperCase();
        songLabels[i].color = i == curSelected ? 0xFFFFD52F : FlxColor.WHITE;
        songLabels[i].alpha = i == curSelected ? 1 : 0.58;
        songLabels[i].size = i == curSelected ? 42 : 35;
    }

    var songName = Std.string(songs[curSelected].name).toLowerCase();
    var coverKey = 'covers/idk';
    switch (songName) {
        case 'abc': coverKey = 'covers/abc';
        case 'hypnotized': coverKey = 'covers/hypnotized';
        case 'idk': coverKey = 'covers/idk';
    }

    cover.loadGraphic(Paths.image(coverKey));
    cover.setGraphicSize(440);
    cover.updateHitbox();
    cover.x = 707 + (440 - cover.width) / 2;
    cover.y = 172 + (330 - cover.height) / 2;

    songTitle.text = Std.string(songs[curSelected].displayName).toUpperCase();
    songMeta.text = 'TRACK ' + (curSelected + 1) + ' / ' + songs.length + '     //     ENTER TO PLAY';
    lastSelected = curSelected;
}

function update(elapsed:Float) {
    if (songs.length == 0) {
        if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
        return;
    }

    var moved = false;
    if (controls.UP_P) {
        curSelected--;
        moved = true;
    } else if (controls.DOWN_P) {
        curSelected++;
        moved = true;
    }

    if (curSelected < 0) curSelected = songs.length - 1;
    if (curSelected >= songs.length) curSelected = 0;

    if (moved && curSelected != lastSelected) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);
        refreshSelection();
    }

    if (controls.ACCEPT) {
        var difficulty = 'normal';
        if (songs[curSelected].difficulties != null && songs[curSelected].difficulties.length > 0)
            difficulty = Std.string(songs[curSelected].difficulties[0]).toLowerCase();

        var variant = songs[curSelected].variant;
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        PlayState.loadSong(songs[curSelected].name, difficulty, variant, false, false);
        FlxG.switchState(new PlayState());
    }

    if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
