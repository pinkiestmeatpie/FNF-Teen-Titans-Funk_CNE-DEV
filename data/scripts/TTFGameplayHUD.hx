// Teen Titans Funk! gameplay interface:
// TTF mark + timer above, Robin's staff as the health-bar frame, custom rating text.
// The engine still owns health, score, judgement calculation, and note scoring.
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.Paths;
import funkin.backend.system.Conductor;

var ttfStaff:FlxSprite;
var ttfClock:FlxText;
var ttfLogo:FlxText;
var ttfRating:FlxText;
var ttfRatingTimer:Float = 0;

function postCreate() {
    // Compact title strip at the top.
    var topStrip = new FlxSprite(0, 0).makeGraphic(FlxG.width, 48, 0xB8000000);
    topStrip.scrollFactor.set();
    topStrip.cameras = [camHUD];
    add(topStrip);

    var topRule = new FlxSprite(0, 46).makeGraphic(FlxG.width, 3, 0xFFFFAAB5);
    topRule.scrollFactor.set();
    topRule.cameras = [camHUD];
    add(topRule);

    ttfLogo = new FlxText(22, 3, 240, 'TTF');
    ttfLogo.setFormat(Paths.font('ttg.ttf'), 38, 0xFF20B8D3, 'left');
    ttfLogo.scrollFactor.set();
    ttfLogo.cameras = [camHUD];
    add(ttfLogo);

    ttfClock = new FlxText(FlxG.width * 0.5 - 110, 10, 220, '00:00');
    ttfClock.setFormat(Paths.font('comm.ttf'), 25, FlxColor.WHITE, 'center');
    ttfClock.alignment = 'center';
    ttfClock.scrollFactor.set();
    ttfClock.cameras = [camHUD];
    add(ttfClock);

    var songName = PlayState.SONG != null && PlayState.SONG.meta != null
        ? Std.string(PlayState.SONG.meta.displayName).toUpperCase()
        : 'TEEN TITANS FUNK!';
    var songText = new FlxText(FlxG.width - 350, 8, 325, songName);
    songText.setFormat(Paths.font('ttg.ttf'), 23, 0xFFFFD52F, 'right');
    songText.alignment = 'right';
    songText.scrollFactor.set();
    songText.cameras = [camHUD];
    add(songText);

    // Existing Robin staff asset is the health bar frame from the storyboard.
    ttfStaff = new FlxSprite().loadGraphic(Paths.image('game/ttghealthbar'));
    ttfStaff.setGraphicSize(930);
    ttfStaff.updateHitbox();
    ttfStaff.x = (FlxG.width - ttfStaff.width) * 0.5;
    ttfStaff.y = FlxG.height - ttfStaff.height - 16;
    ttfStaff.scrollFactor.set();
    ttfStaff.cameras = [camHUD];

    if (healthBarBG != null) healthBarBG.visible = false;

    // Reposition the actual engine health bar into the staff's open centre.
    if (healthBar != null) {
        remove(healthBar, false);
        healthBar.setGraphicSize(565, 17);
        healthBar.updateHitbox();
        healthBar.x = ttfStaff.x + 183;
        healthBar.y = ttfStaff.y + 67;
        healthBar.createFilledBar(0xFFE34F60, 0xFF70D2BF);
        healthBar.scrollFactor.set();
        healthBar.cameras = [camHUD];
        add(ttfStaff);
        add(healthBar);
        healthBar.updateBar();
    } else {
        add(ttfStaff);
    }

    // Keep the real player/opponent icons, but move them to the staff handles.
    if (iconP1 != null) {
        iconP1.setGraphicSize(64, 64);
        iconP1.updateHitbox();
        iconP1.x = ttfStaff.x - 2;
        iconP1.y = ttfStaff.y + (ttfStaff.height - iconP1.height) * 0.5;
        iconP1.cameras = [camHUD];
    }
    if (iconP2 != null) {
        iconP2.setGraphicSize(64, 64);
        iconP2.updateHitbox();
        iconP2.x = ttfStaff.x + ttfStaff.width - iconP2.width + 2;
        iconP2.y = ttfStaff.y + (ttfStaff.height - iconP2.height) * 0.5;
        iconP2.cameras = [camHUD];
    }

    // Rating callout above the staff, using the real rating name from CNE's note event.
    ttfRating = new FlxText(0, FlxG.height - 155, FlxG.width, '');
    ttfRating.setFormat(Paths.font('ttg.ttf'), 42, 0xFFFFFF36, 'center');
    ttfRating.alignment = 'center';
    ttfRating.scrollFactor.set();
    ttfRating.cameras = [camHUD];
    ttfRating.visible = false;
    add(ttfRating);
}

function onNoteHit(event) {
    if (!event.player) return;

    // Replace only the default rating sprite; engine accuracy and scoring stay untouched.
    event.displayRating = false;
    ttfRating.text = Std.string(event.rating).toUpperCase() + '!';
    ttfRating.color = switch (Std.string(event.rating).toLowerCase()) {
        case 'sick': 0xFF62D9CC;
        case 'good': 0xFFB9E86B;
        case 'bad': 0xFFFFB347;
        case 'shit': 0xFFFF6575;
        default: 0xFFFFFF36;
    };
    ttfRating.visible = true;
    ttfRating.alpha = 1;
    ttfRating.y = FlxG.height - 155;
    ttfRatingTimer = 0.55;
}

function onPlayerMiss(event) {
    ttfRating.text = 'MISS!';
    ttfRating.color = 0xFFFF6575;
    ttfRating.visible = true;
    ttfRating.alpha = 1;
    ttfRating.y = FlxG.height - 155;
    ttfRatingTimer = 0.55;
}

function postUpdate(elapsed:Float) {
    if (ttfClock != null) {
        var totalSeconds:Int = Std.int(Math.max(0, Conductor.songPosition) / 1000);
        var minutes:Int = Std.int(totalSeconds / 60);
        var seconds:Int = totalSeconds % 60;
        ttfClock.text =
            (minutes < 10 ? '0' : '') + minutes + ':' +
            (seconds < 10 ? '0' : '') + seconds;
    }

    if (ttfRating != null && ttfRating.visible) {
        ttfRatingTimer -= elapsed;
        ttfRating.y -= elapsed * 14;
        ttfRating.alpha = Math.max(0, ttfRatingTimer / 0.55);
        if (ttfRatingTimer <= 0) ttfRating.visible = false;
    }
}
