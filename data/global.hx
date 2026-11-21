import Type;
import Std;
import Sys;
import sys.io.Process;
import lime.graphics.Image;
import openfl.display.StageQuality;
import openfl.Lib;
import funkin.backend.system.MainState;
import funkin.backend.utils.WindowUtils;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.framerate.FramerateCounter;
import funkin.menus.credits.CreditsMain;

function new() {
    FlxG.mouse.useSystemCursor = false;
    FlxG.mouse.load(Paths.image("Tcursor"));
}
function destroy() {
    FlxG.mouse.useSystemCursor = true;
    FlxG.mouse.unload();
}

static var windowTitleTitan:String = "Teen Titans Funk!";
static var redirectStates:Map<FlxState, String> = [
	FreeplayState => "TTF/TTFFreeplayScreen",
	MainMenuState => "TTF/TTFMainMenu",
	TitleState => "TTF/TTFBeforeTitle",
	// StoryMenuState => "TTF/TTFFreeplayScreen",
	// CreditsMain => "TTF/TTFCreditsScreen"
];

static var initialized:Bool = false;
function preStateSwitch() {
	if (!initialized) {
		window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image('iconOG'))));
		initialized = true;
    	Framerate.codenameBuildField.visible = false;
	}
	WindowUtils.resetTitle();
	window.title = windowTitleTitan;
	FlxG.camera.bgColor = 0xFF000000;
	FlxG.stage.quality = StageQuality.BEST;
	var redirectState = redirectStates.get(Type.getClass(FlxG.game._requestedState));
	if (redirectState != null) FlxG.game._requestedState = new ModState(redirectState);
	else if (Std.string(Type.getClass(FlxG.game._requestedState)) == "funkin.menus.BetaWarningState")
	FlxG.game._requestedState = new ModState("TTF/TTFBeforeTitle");
}
function destroy() {
	WindowUtils.resetTitle();
	initialized = false;
}