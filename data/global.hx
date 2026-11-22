import Type;
import openfl.display.StageQuality;
import funkin.backend.utils.WindowUtils;

function new() {
    FlxG.mouse.useSystemCursor = false;
    FlxG.mouse.load(Paths.image("Tcursor"));
}

static var redirectStates:Map<FlxState, String> = [
    FreeplayState => "TTF/TTFFreeplayScreen",
    MainMenuState => "TTF/TTFMainMenu",
    TitleState => "TTF/TTFTitleScreen"
];

function preStateSwitch() {
    WindowUtils.resetTitle();
    window.title = "Teen Titans Funk!";
    FlxG.camera.bgColor = FlxColor.BLACK;
    FlxG.stage.quality = StageQuality.BEST;
    var redirectState = redirectStates.get(Type.getClass(FlxG.game._requestedState));
    if (redirectState != null) FlxG.game._requestedState = new ModState(redirectState);
}

function destroy() {
    FlxG.mouse.useSystemCursor = true;
    FlxG.mouse.unload();
    WindowUtils.resetTitle();
}
