<!-- coderabbit-ai-generated:v1 -->

# Teen Titans Funk menu states

These scripts target Codename Engine 0.1.0-legacy. Put this folder in the engine's `mods` directory and select the mod. The flow is title → PLAY → main menu. Use the configured menu controls (normally arrows, Enter, and Escape).

- `data/states/TTF/TTFTitleScreen.hx` and `TTFBeforeTitle.hx`: placeholder title and PLAY art. Replace their text and shapes with sprites when final art is ready.
- `TTFMainMenu.hx`: Freeplay, CNE Options, Credits, and Gallery. The communicator badge is a placeholder.
- `TTFFreeplayScreen.hx`: reads the engine's song list and each song's available difficulties. Add covers at `images/covers/<lowercase-song-name>.png`; missing covers display a placeholder. Add `data/freeplaySonglist.txt` if you want a specific song order, following CNE's song list format.
- `TTFCreditsScreen.hx`: edit the `credits` array and replace the portrait placeholder with final art.
- `TTFGalleryScreen.hx`: reads the `images` entries in `images/gallery/data.json`; put each PNG in `images/gallery/images/`. The existing entries are examples.
- `songs/TTFHud.hx`: adds a timer and places the health icons at the ends of the engine health bar. The note graphics and health bar art remain the engine's current assets.

Keep song folder names lowercase: CNE looks up song metadata and charts using lowercase paths, including on case-sensitive systems. The song display name can still use capitals in `meta.json`.
