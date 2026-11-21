import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.game.PlayState;

// Five titles from the supplied TTF storyboard. Missing charts are shown as unavailable.
var tracks:Array<Dynamic> = [
    {title: 'DRIVEBOT', chart: 'Drivebot'},
    {title: "THAT'S SO FUNNY", chart: "That's So Funny"},
    {title: 'SISTER SIBLINGS', chart: 'Sister Siblings'},
    {title: 'SCOTT MENVILLE', chart: 'Scott Menville'},
    {title: 'SPIKY TIME!', chart: 'Spiky Time!'}
];
var availableCharts:Array<Dynamic> = [];
var curSelected:Int = 0;
var labels:Array<FlxText> = [];
var cover:FlxSprite;
var coverTitle:FlxText;
var songStatus:FlxText;
var footer:FlxText;

function create() {
    CoolUtil.playMenuSong();
    FlxG.camera.bgColor = 0xFF09090D;

    var border = new FlxSprite(42, 82).makeGraphic(FlxG.width - 84, FlxG.height - 155, 0xFFFFAAB5);
    border.scrollFactor.set();
    add(border);

    var panel = new FlxSprite(54, 94).makeGraphic(FlxG.width - 108, FlxG.height - 179, 0xFF08080C);
    panel.scrollFactor.set();
    add(panel);

    var fps = new FlxText(70, 97, 75, 'FPS');
    fps.setFormat(Paths.font('comm.ttf'), 14, 0xFFAAAAAA, 'left');
    fps.scrollFactor.set();
    add(fps);

    var heading = new FlxText(85, 115, 540, 'FREEPLAY');
    heading.setFormat(Paths.font('ttg.ttf'), 44, FlxColor.WHITE, 'left');
    heading.scrollFactor.set();
    add(heading);

    var listLine = new FlxSprite(85, 168).makeGraphic(520, 3, 0xFF393942);
    listLine.scrollFactor.set();
    add(listLine);

    // CreativeBlock BB Bold is not in the repository's fonts folder yet.
    // Use the closest included project font until the requested font file is supplied.
    for (i in 0...tracks.length) {
        var row = new FlxText(88, 205 + i * 66, 500, '');
        row.setFormat(Paths.font('ttg.ttf'), 34, 0xFFFFE82F, 'left');
        row.scrollFactor.set();
        row.ID = i;
        labels.push(row);
        add(row);
    }

    var coverFrame = new FlxSprite(660, 156).makeGraphic(FlxG.width - 765, 370, 0xFF292932);
    coverFrame.scrollFactor.set();
    add(coverFrame);

    cover = new FlxSprite(670, 166).loadGraphic(Paths.image('menus/freeplay/covers/placeholder'));
    cover.setGraphicSize(FlxG.width - 785, 350);
    cover.updateHitbox();
    cover.scrollFactor.set();
    cover.antialiasing = true;
    add(cover);

    var coverShade = new FlxSprite(670, 430).makeGraphic(FlxG.width - 785, 86, 0xCC000000);
    coverShade.scrollFactor.set();
    add(coverShade);

    coverTitle = new FlxText(685, 440, FlxG.width - 815, '');
    coverTitle.setFormat(Paths.font('ttg.ttf'), 29, FlxColor.WHITE, 'center');
    coverTitle.alignment = 'center';
    coverTitle.scrollFactor.set();
    add(coverTitle);

    songStatus = new FlxText(675, 545, FlxG.width - 795, '');
    songStatus.setFormat(Paths.font('comm.ttf'), 20, 0xFFFFE82F, 'center');
    songStatus.alignment = 'center';
    songStatus.scrollFactor.set();
    add(songStatus);

    footer = new FlxText(55, FlxG.height - 48, FlxG.width - 110, '');
    footer.setFormat(Paths.font('comm.ttf'), 17, FlxColor.WHITE, 'center');
    footer.alignment = 'center';
    footer.scrollFactor.set();
    add(footer);

    var songList = FreeplaySonglist.get();
    if (songList != null && songList.songs != null) availableCharts = songList.songs;
    refreshSelection();
}

function chartForTrack(track:Dynamic):Dynamic {
    var target = Std.string(track.chart).toLowerCase();
    var compactTarget = target.replace(' ', '').replace("'", '').replace('!', '');
    for (chart in availableCharts) {
        var name = chart.name == null ? '' : Std.string(chart.name).toLowerCase();
        var displayName = chart.displayName == null ? '' : Std.string(chart.displayName).toLowerCase();
        var compactName = name.replace(' ', '').replace("'", '').replace('!', '');
        var compactDisplay = displayName.replace(' ', '').replace("'", '').replace('!', '');
        if (name == target || displayName == target || compactName == compactTarget || compactDisplay == compactTarget)
            return chart;
    }
    return null;
}

function refreshSelection() {
    for (i in 0...labels.length) {
        var active = i == curSelected;
        labels[i].text = (active ? '> ' : '  ') + tracks[i].title;
        labels[i].color = active ? 0xFFFFFF36 : FlxColor.WHITE;
        labels[i].alpha = active ? 1 : 0.76;
        labels[i].size = active ? 37 : 33;
    }

    var chart = chartForTrack(tracks[curSelected]);
    coverTitle.text = tracks[curSelected].title;
    if (chart == null) {
        songStatus.text = 'CHART NOT IN REPOSITORY YET';
        songStatus.color = 0xFFFF7777;
        footer.text = 'UP / DOWN  SELECT     ENTER  CHART INFO     BACKSPACE  BACK';
    } else {
        songStatus.text = 'READY TO PLAY';
        songStatus.color = 0xFFFFFF36;
        footer.text = 'UP / DOWN  SELECT     ENTER  PLAY     BACKSPACE  BACK';
    }
}

function update(elapsed:Float) {
    if (controls.UP_P) {
        curSelected = (curSelected - 1 + tracks.length) % tracks.length;
        refreshSelection();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);
    } else if (controls.DOWN_P) {
        curSelected = (curSelected + 1) % tracks.length;
        refreshSelection();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.65);
    }

    if (controls.ACCEPT) {
        var chart = chartForTrack(tracks[curSelected]);
        if (chart == null) {
            songStatus.text = 'THIS SONG NEEDS ITS CHART FILE';
            songStatus.color = 0xFFFF7777;
            FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
        } else {
            var difficulty = Flags.DEFAULT_DIFFICULTY;
            if (chart.difficulties != null && chart.difficulties.length > 0)
                difficulty = Std.string(chart.difficulties[0]).toLowerCase();
            PlayState.loadSong(chart.name, difficulty, chart.variant, false, false);
            FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
            FlxG.switchState(new PlayState());
        }
    }

    if (controls.BACK || FlxG.keys.justPressed.BACKSPACE)
        FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
