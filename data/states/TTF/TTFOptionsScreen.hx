import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.scripting.ModState;
import funkin.backend.Paths;
import funkin.options.OptionsMenu;

var categories:Array<Dynamic> = [
    {title: 'NOTE COLORS', hint: 'Customize note appearance and color accessibility.'},
    {title: 'CONTROLS', hint: 'Keybinds, controls, and input configuration.'},
    {title: 'ADJUST DELAY AND COMBO', hint: 'Timing offset, judgement behavior, and combo display.'},
    {title: 'GRAPHICS', hint: 'Performance and rendering settings.'},
    {title: 'VISUALS AND UI', hint: 'HUD, visual effects, and interface preferences.'},
    {title: 'GAMEPLAY', hint: 'Gameplay behavior and quality-of-life settings.'}
];

var selected:Int = 5;
var rows:Array<FlxText> = [];
var hintText:FlxText;
var pulse:Float = 0;

function create() {
    FlxG.camera.bgColor = 0xFF7B35B1;

    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF9A55C9);
    bg.scrollFactor.set();
    add(bg);

    // Purple, low-contrast polygon-like backdrop.
    for (i in 0...9) {
        var stripe = new FlxSprite(i * 165 - 60, 0).makeGraphic(78, FlxG.height, 0xFF6E2D9D);
        stripe.angle = -12;
        stripe.alpha = 0.22;
        stripe.scrollFactor.set();
        add(stripe);
    }

    var frame = new FlxSprite(55, 54).makeGraphic(1170, 620, 0xFFFFB2C0);
    frame.scrollFactor.set();
    add(frame);

    var panel = new FlxSprite(67, 66).makeGraphic(1146, 596, 0xFF9D53C7);
    panel.scrollFactor.set();
    add(panel);

    var inner = new FlxSprite(105, 102).makeGraphic(1070, 520, 0xFF8741B5);
    inner.alpha = 0.46;
    inner.scrollFactor.set();
    add(inner);

    var title = new FlxText(0, 72, FlxG.width, 'OPTIONS');
    title.setFormat(Paths.font('ttg.ttf'), 43, FlxColor.WHITE, 'center');
    title.alignment = 'center';
    title.scrollFactor.set();
    add(title);

    var leftRule = new FlxSprite(260, 130).makeGraphic(760, 3, 0xFFFFD9FA);
    leftRule.alpha = 0.75;
    leftRule.scrollFactor.set();
    add(leftRule);

    for (i in 0...categories.length) {
        var row = new FlxText(0, 155 + (i * 61), FlxG.width, '');
        row.setFormat(Paths.font('ttg.ttf'), 31, FlxColor.WHITE, 'center');
        row.alignment = 'center';
        row.ID = i;
        row.scrollFactor.set();
        rows.push(row);
        add(row);
    }

    hintText = new FlxText(160, 555, 960, '');
    hintText.setFormat(Paths.font('comm.ttf'), 19, FlxColor.WHITE, 'center');
    hintText.alignment = 'center';
    hintText.scrollFactor.set();
    add(hintText);

    var footer = new FlxText(0, 632, FlxG.width, 'UP / DOWN  SELECT     ENTER  OPEN CODE NAME SETTINGS     ESC  BACK');
    footer.setFormat(Paths.font('comm.ttf'), 16, FlxColor.WHITE, 'center');
    footer.alignment = 'center';
    footer.scrollFactor.set();
    add(footer);

    refreshSelection();
}

function refreshSelection() {
    for (i in 0...rows.length) {
        var active = i == selected;
        rows[i].text = (active ? '>  ' : '   ') + categories[i].title + (active ? '  <' : '');
        rows[i].color = active ? 0xFFFFFFC9 : FlxColor.WHITE;
        rows[i].alpha = active ? 1 : 0.68;
        rows[i].size = active ? 34 : 29;
    }
    hintText.text = categories[selected].hint + '\nENTER opens Codename Engine settings, where the full option category can be edited.';
}

function update(elapsed:Float) {
    pulse += elapsed * 2.8;
    rows[selected].alpha = 0.84 + Math.sin(pulse) * 0.16;

    if (controls.UP_P) {
        selected = (selected - 1 + categories.length) % categories.length;
        refreshSelection();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    } else if (controls.DOWN_P) {
        selected = (selected + 1) % categories.length;
        refreshSelection();
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.6);
    }

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
        FlxG.switchState(new OptionsMenu());
    }

    if (controls.BACK) FlxG.switchState(new ModState('TTF/TTFMainMenu'));
}
