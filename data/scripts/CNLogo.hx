// Optional Cartoon Network logo event.
import flixel.FlxSprite;
import funkin.backend.Paths;

function onEvent(event) {
    if (event.event.name == 'CN') {
        var image = new FlxSprite().loadGraphic(Paths.image(event.event.params[0]));
        image.updateHitbox();
        image.screenCenter();
        image.cameras = [camHUD];
        image.scale.set(FlxG.height / image.height, FlxG.height / image.height);
        add(image);
    }
}
