import flixel.FlxG;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class CamZoomEvent
{
    public static var defaultZoom:Float = 1.0;
    public static var zooming:Bool = false;
    public static var camObj:FlxSprite;

    public static function init():Void
    {
        defaultZoom = FlxG.camera.zoom;
        camObj = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        camObj.y = defaultZoom;
    }

    /**
     * initialize
     * @param zoomLevel if 0 reset to defaultZoom
      @param duration
     */
    public static function trigger(zoomLevel:Float, duration:Float):Void
    {
        if (zoomLevel <= 0 && duration <= 0)
        {
            FlxG.camera.zoom = defaultZoom;
            zooming = false;
            camObj.y = defaultZoom;
            return;
        }

        var targetZoom = (zoomLevel > 0) ? zoomLevel : defaultZoom;

        if (zooming)
        {
            FlxTween.removeTween(camObj);
            zooming = false;
        }

        FlxTween.tween(camObj, { y: targetZoom }, duration, { type: FlxTween.LINEAR, onUpdate: onTweenUpdate, onComplete: onTweenComplete });
        zooming = true;
    }

    static function onTweenUpdate(tween:FlxTween):Void
    {
        FlxG.camera.zoom = camObj.y;
    }

    static function onTweenComplete(tween:FlxTween):Void
    {
        zooming = false;
    }
}
