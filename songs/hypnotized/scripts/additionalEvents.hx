import lime.app.Application;
//import PlayState;

// Camera zoom settings
var originalZoom:Float = 0.9;       // Default camera zoom
var suspenseZoom:Float = 1.2;       // Zoom level for suspense
var suspenseZoom2:Float = 1; 
var zoomDuration:Float = 2.1;       // Duration of suspense zoom (in seconds)
var zoomDuration2:Float = 19; 

// Overlay toggle and sprite
var overlayEnabled:Bool = false;    // Controls whether overlay is visible
var pinkOverlay:FlxSprite;          // The pink overlay sprite

function postCreate() {
    // 1. Middle scroll setup
    // Hide opponent notes (Dad's side)
    for (i in 0...4) {
        strumLines.members[0].members[i].visible = false;
    }

    // Center BF's notes horizontally
    for (i in 0...4) {
        strumLines.members[1].members[i].x = 412 + (i * 112);
    }

    // 5. Create pink overlay (initially hidden)
    pinkOverlay = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFFFFAACC); // Pink: #ff0066ff
    pinkOverlay.scrollFactor.set();     // Prevents camera movement affecting overlay
    pinkOverlay.alpha = 0.25;           // Transparency level
    pinkOverlay.blend = overlay;            // Blend mode for glowing effect
    pinkOverlay.visible = false;        // Start hidden
    add(pinkOverlay);                   // Add to scene
}

function beatHit(curBeat:Int) {
    switch (curBeat) {
        case 140:
            // 2. Suspense zoom in (ease in)
            FlxTween.tween(FlxG.camera, {zoom: suspenseZoom}, zoomDuration, {ease: FlxEase.quadIn});
            FlxTween.tween(camHUD, {zoom: suspenseZoom}, zoomDuration, {ease: FlxEase.quadIn});

        case 144:
// 1. Reset camera zoom to original
    FlxG.camera.zoom = originalZoom;
    camHUD.zoom = originalZoom;
// 2. Restore opponent notes with fade-in
    for (i in 0...4) {
        var oppNote = strumLines.members[0].members[i];
        oppNote.visible = true;
        oppNote.alpha = 0;
        FlxTween.tween(oppNote, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
    }
 // 3. Tween player notes back to default positions
    for (i in 0...4) {
        var playerNote = strumLines.members[1].members[i];
        var targetX = 732 + (i * 112); // Default layout
        FlxTween.tween(playerNote, {x: targetX}, 0.5, {ease: FlxEase.sineOut});
    }

    case 272:
        // wtf i have to add this because the friggin modchart is makin the strums position in the middle??
       // PlayState.allowNoteShake = false; nvm
            
        case 336: // beast boy
            // 4. Bounce transition (back in)
            bounceCamera();
            // 5. Enable pink overlay
            overlayEnabled = true;
            pinkOverlay.visible = true;

        case 472:
            // 6. Disable pink overlay
            overlayEnabled = false;
            pinkOverlay.visible = false;

        case 728:
            // 7. Another bounce transition
            bounceCamera();

        case 920:
            // 8. Suspense zoom again
            FlxTween.tween(FlxG.camera, {zoom: suspenseZoom2}, zoomDuration2, {ease: FlxEase.quadIn});
            FlxTween.tween(camHUD, {zoom: suspenseZoom2}, zoomDuration2, {ease: FlxEase.quadIn});

        case 984:
            // 9. Reset zoom again
            FlxG.camera.zoom = originalZoom;
            camHUD.zoom = originalZoom;

        case 993:
            // 10. Camera flash (white)
            FlxG.camera.flash(FlxColor.WHITE, 0.3);

        case 1013:
            // 11. Fade out to black
            FlxG.camera.fade(FlxColor.BLACK, 2, false);
    }
}

// Bounce transition function
function bounceCamera() {
    // Zoom in slightly with bounce effect
    FlxTween.tween(FlxG.camera, {zoom: 1.05}, 0.2, {
        ease: FlxEase.backIn,
        onComplete: function(_) {
            // Return to original zoom smoothly
            FlxTween.tween(FlxG.camera, {zoom: originalZoom}, 0.3, {ease: FlxEase.sineOut});
        }
    });

    // Apply same bounce to HUD
    FlxTween.tween(camHUD, {zoom: 1.05}, 0.2, {
        ease: FlxEase.backIn,
        onComplete: function(_) {
            FlxTween.tween(camHUD, {zoom: originalZoom}, 0.3, {ease: FlxEase.sineOut});
        }
    });
}