function beatHit(curBeat:Int)
    switch (curBeat) 
{
             case 324:
            FlxG.camera.fade(FlxColor.BLACK, 25, false);
             case 68:
            FlxG.camera.flash(FlxColor.WHITE, 1);
            FlxG.camera.zoom = 0.8;
    }