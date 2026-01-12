

function onEvent(event) {
		case 'CN':
			var image = new FlxSprite().loadGraphic(Paths.image(event.event.params[0]));
            image.updateHitbox();
            image.screenCenter();
            image.cameras = [camHUD];
            image.scale.set(FlxG.height/image.height, FlxG.height/image.height);
            add(image);
}

/* function postCreate() {
        var logo = new Entity();
        logo.loadGraphic("CN");
        logo.setPosition(10, 10);
        logo.setCamera("hud");
        addEntity(logo);
    }