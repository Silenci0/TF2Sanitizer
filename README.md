# TF2Sanitizer
TF2 plugin that cleans up certain entities/actions from happening. 

This plugin was primarily created for the Halloween holiday mode in TF2 in order to allow players to use their halloween items/effects/cosmetics without all the more annoying aspects of the mode. It also cleans up other things such as teleporter bread as well.

This plugin does the following:

- Removes Thriller taunt (is turned off completely with no random chance of happening)
- Removes the halloween souls effect from the game (this includes their annoying sound effects).
- Removes the ability to get pumpkin loot (crit candy) randomly from killing a player.
- Removes bread from spawning when teleporting (too many entities as is, we need less to run an efficient server!)
- Replaces halloween healthkits with "normal" health kits (some people are annoyed by halloween health).
- Checks tf_forced_holiday for Halloween or Fullmoon modes in order to disable stuff related to that holiday. If the server is not set, it will not attempt to remove halloween-based entities.

This plugin will, over time, have more uses in blocking certain undesirable effects from the game as they come up. It is also configurable, so you can pick and choose what to remove and what to keep.

# Cvars
These cvars are present in the plugin and can be edited from the configuration file:

- `sm_tf2s_sanitizer_enabled` - Enable/Disable TF2 Sanitization plugin. Default value: "1"
- `sm_tf2s_remove_bread` - Enable/Disable removal of bread from teleporters. Default value: "1"
- `sm_tf2s_remove_pumpkin_loot` - Enable/Disable removal of pumpkin loot/candy dropped from players in halloween mode. Default value: "1"
- `sm_tf2s_remove_souls` - Enable/Disable removal of halloween souls (removes sound as well). Default value: "1"
- `sm_tf2s_remove_thriller_taunt` - Enable/Disable the thriller taunt from being activated. Default value: "1"
- `sm_tf2s_replace_hkits` - Enable/Disable replacement of holiday healthkits with normal healthkits. Default value: "1"

# Installation
All relevant files/gamedata have been included in the projects, you will simply need to do the following to install:

- Download the files (including the gamedata).
- Copy all files into relevant directories (all directories are setup the same as they appear in the normal tf2/sourcemod install).
- Configure the plugin via plugins.tf2sanitizer.cfg.
- Run server and have fun!

Not very difficult, especially if you have installed Sourcemod/metamod before. If this is your first time, please consult the sourcemod wiki for how to install plugins/sourcemod/metamod.

# Finally
Support for this plugin will be done on a case by case basis when I feel like it. Please don't add me to get an update for the plugin as the code files are there to edit/use.

# Changelog
1.3.0 Gamedata Update (09-06-2021)
-----------------
- Updated the gamedata so that it the thriller taunt would be removed properly for Linux servers. Found info about that in this thread: https://forums.alliedmods.net/showthread.php?t=171343

1.3.0 Update (12-04-2019)
-----------------
- Updated plugin code to use the new syntax.
- Removed a few debug messages from the plugin.
- Compiled plugins for SM 1.10


1.2 Update/Release (02-02-2019)
-----------------
- Public Release. Testing was done by me on a few test servers to verify how well it works.

