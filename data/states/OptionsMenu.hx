// Leave CNE's options tree intact and ease in its header.
function postCreate() {
    for (item in [pathBG, pathLabel, pathDesc]) {
        var opacity = item.alpha;
        item.alpha = 0;
        FlxTween.tween(item, {alpha: opacity}, 0.28, {ease: FlxEase.quadOut});
    }
}

function destroy() {
    for (item in [pathBG, pathLabel, pathDesc]) FlxTween.cancelTweensOf(item);
}
