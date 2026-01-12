function onEvent(eventEvent) {
    if (eventEvent.event.name == "zoom") {
        defaultHudZoom = eventEvent.event.params[1] != null ? eventEvent.event.params[1] : 1;
        defaultCamZoom = eventEvent.event.params[0] != null ? eventEvent.event.params[0] : 0.9;
    }
}