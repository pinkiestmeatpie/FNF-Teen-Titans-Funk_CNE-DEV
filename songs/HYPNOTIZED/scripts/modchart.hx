import lime.app.Application;

var windows = Application.current.window;
var windowNameCycle:String = " YOUR MIND IS MINE ";
var delay = 0;

var pos:Array<Float> = []; // da x 4 da strums
var nY:Float;              // da y 4 da strums
var phaseActive = false;

// init shader
var bloom = new CustomShader('bloom2');

// window bounce vars
var originalPos:Array<Float> = [];
var offset:Int = 50;

function postCreate() {
    // original strum note positions
    nY = strumLines.members[1].members[0].y;
    for (i in 0...4) pos.push(strumLines.members[1].members[i].x);

    // add bloom shader (if not disabled already)
    if (!FlxG.save.data.mcm_noshaders) {
        for (cam in [camHUD, camGame]) cam.addShader(bloom);
    }

    bloom.Size = 0;
    bloom.dim = 2;

    // store original window position
    originalPos = [windows.x, windows.y];
}

function beatHit(curBeat) {
    // start anim
    if (curBeat == 272) {
        phaseActive = true;
    }

    // stop anim
    if (curBeat == 336) {
        phaseActive = false;
        window.title = " YOUR MIND IS MINE ";
    }

    // WINDOW CONFIG
    switch (curBeat) {
        case 272:
            windows.y = originalPos[1] - offset; // W
        case 274:
            windows.x = originalPos[0] - offset; // A
        case 276:
            windows.y = originalPos[1] + offset; // S
        case 278:
            windows.x = originalPos[0] + offset; // D
        case 279:
            windows.y = originalPos[1] - offset; // W
            windows.x = originalPos[0] - offset; // A
        case 280:
            windows.y = originalPos[1] + offset; // S
        case 282:
            windows.x = originalPos[0] + offset; // D
        case 284:
            windows.y = originalPos[1] - offset; // W
        case 286:
            windows.x = originalPos[0] - offset; // A
    }
}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 1128:
            windows.y = originalPos[1] - offset; // W
        case 1132:
            windows.x = originalPos[0] + offset; // D
        case 1134:
            windows.y = originalPos[1] + offset; // S
    }
}

function update(elapsed) {
    // Animate window title only
    if (phaseActive) {
        if (delay == 0) {
            windowNameCycle = windowNameCycle.charAt(windowNameCycle.length - 1) + windowNameCycle;
            windowNameCycle = windowNameCycle.substring(0, windowNameCycle.length - 1);
            window.title = windowNameCycle;
        }

        delay = (delay + 1) % 3;
    }
}

function bounceWindow(x:Float, y:Float) {
    FlxTween.tween(windows, {x: x, y: y}, 0.2, {
        ease: FlxEase.quadOut,
        onComplete: function(_) {
            FlxTween.tween(windows, {x: originalPos[0], y: originalPos[1]}, 0.3, {
                ease: FlxEase.bounceOut
            });
        }
    });
}
//728 cyborg