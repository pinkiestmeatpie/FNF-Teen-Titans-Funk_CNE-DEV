function onNoteCreation(note)
{
    switch(SONG.meta.name)
    {
        case "song1": // change to your song and noteskin
            note.noteSprite = "game/notes/noteskin1";
        case "song2":
            note.noteSprite = "game/notes/noteskin2";
    }
}

function onStrumCreation(note)
{
   switch(SONG.meta.name)
    {
        case "song1":
            note.sprite = "game/notes/noteskin1";
        case "song2":
            note.sprite = "game/notes/noteskin2";
    }
}