import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;

function create() {
    for (event in events) {
        if (event.name == 'PA Lyrics') {
            dalyricsa = new FlxText(0, 475, 1200, "", 70);
            dalyricsa.setFormat(
                Paths.font("baveuse.ttf"),
                35,
                0xFFFFFFFF,
                "center",
                FlxTextBorderStyle.OUTLINE,
                FlxColor.BLACK
            );
            dalyricsa.borderSize = 2; //border thickness
            dalyricsa.scrollFactor.set();
            dalyricsa.screenCenter(FlxAxes.X);
            add(dalyricsa);
            dalyricsa.cameras = [camHUD];
        }
    }
}

function onEvent(e) {
    if (e.event.name == "PA Lyrics") {
        dalyricsa.text = e.event.params[0] + ':' + '\n' + e.event.params[1];
        dalyricsa.color = Std.parseInt(e.event.params[2]); // make sure color is int
        // keep border color black and border size 2 or it will break
        dalyricsa.borderColor = 0xFF000000;
        dalyricsa.borderSize = 2;

        if (e.event.params[1] == '') dalyricsa.text = ''; 
        if (e.event.params[3] == true) enableit = true;
        else if (e.event.params[3] == false) enableit = false;
        if (e.event.params[4] == true) hideit = true;
        else if (e.event.params[4] == false) hideit = false;
    }
}
function stepHit(step:Int)
{
    var distortIntensity:Float = FlxG.random.float(6, 3);
    coolassshader.binaryIntensity = distortIntensity;
}
function postUpdate(elapsed){
    if (enableit) {
    dalyricsa.shader = coolassshader;
    }
    if (!enableit){
    dalyricsa.shader = null;
    }
}