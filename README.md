# Sven-Coop-Server-Plugins
A few simple but useful Angelscript Plugins for the "Monogon on Tour" Sven Coop Server.

## Installation
You can install whichever one you want, they are not dependent on one another.
To install the plugins first put the .as files into the `/svencoop/scripts/plugins` folder.
Then open the `/svencoop/default_plugins.txt` and add text to the file following this example:

```
"plugin"
    {
    "name" "helloThere"
    "script" "helloThere"
    }
```

## helloThere.as
Plays a soundfile `hellothere.mp3`(not provided) from the this folder `/svencoop/sound/music` (You can choose any sound of your liking) and shows a message "General Kenobi!" in chat when a player joins the server.

## help.as

## lastManSound.as

## mapChanger.as

## mapMenu.as