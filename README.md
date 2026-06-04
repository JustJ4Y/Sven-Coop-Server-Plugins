# Sven-Coop-Server-Plugins
A few simple but useful Angelscript Plugins for the "Monogon on Tour" Sven Coop Server.

## Installation
You can install whichever one you want, they are not dependent on one another.  
1. To install the plugins put the .as files into the `/svencoop/scripts/plugins` folder.  
2. Open the `/svencoop/default_plugins.txt` and add text to the file following this example:

```
"plugin"
    {
    "name" "helloThere"
    "script" "helloThere"
    }
```

## helloThere.as
Plays a soundfile `hellothere.mp3`(not provided) from the this folder `/svencoop/sound/as_scripts` (You can choose any sound of your liking) and shows a message "General Kenobi!" in chat when a player joins the server.

## help.as
Only helpful if you install all plugins from here. If you type `help` in chat it shows you all possible commands.

## lastManSound.as
Plays a soundfile `lastMan.mp3`(not provided) from the this folder `/svencoop/sound/as_scripts` (You can choose any sound of your liking) and shows a message "Only one living player left!" whenever only one living player is left, but more than one player is connected.

## mapChanger.as
Let's you do a simple map change by typing `map` and the mapname in chat (admins only).

## mapMenu.as
You can type `mapmenu` in chat to open the map change menu (admins only). The map names need to be listed in `scripts/plugins/cfg/maps.txt` or else the map menu will not work.

## mapTime.as
Saves how long a map took to complete. When the level changes the elapsed play time is measured and the fastest completion per map is stored in `scripts/plugins/store/maptimes.txt` (create the `store` folder if it does not exist). A new record is announced in chat. Any player can type `maptime` (or `besttime`) in chat to see the best saved time for the current map.

## monsterKillFeed.as
Shows monsters getting killed in the kill feed. It also plays the `pling.wav`found in `/svencoop/sound/as_scripts` everytime a player gets a kill for the given player.

## survivalToggler.as
As and admin you can type `survival` in chat to toggle survival mode.

## voteMenu.as
You can type `votemap` in chat to open the map vote menu. Selecting a map will start the mapvote. The map names need to be listed in `scripts/plugins/cfg/maps.txt` or else the map menu will not work.
