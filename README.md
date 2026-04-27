# Intro

THIS MOD IS STILL IN DEVELOPMENT.

Spawn objects from a categorized menu and delete nearest object. Dending on the script version more functions are available (for example save and persistence).

# Bugs

- Desync problems when nearest object to delete is a composite object, and during /clearall

# Settings and commands

## Commands

- D-Pad right and left to navigate submmenu
- X to spawn
- Y to delete nearest object
- /savemap to save all the spawned objects from every player
- /loadmap (host only) to load saved map
- /clearall (host only) delete all mod spawned objects

## Settings

Available to anyone:

- Spawn Objects Upright:
  - default: true
  - If enabled, objects will be tilted based on mario face angle. For example, if you spawn a Sinking platform while diving, the platform will be spawned inclined

Available to host only:

- Allow Guest Object Deletion:
  - default: true
  - If enabled, all connected Marios will be able to delete nearest object

# spawn-objects

The simpler one. Spawn objects using a menu and delete the nearest object.

- spawning code is executed on player's device
- created objects are not tracked
- no persistence (if all player exit a map, all created objects despawn)

# spawn-objects-arena

TODO

# spawn-objects-singlelevel

- No persistence. Hence only a single level is allowed
- Allows map saving (all) and loading (host only). Make sure to delete everything before using /loadmap

# spawn-obejcts-persistence

IN DEVELOPMENT

Tracks spanwed object in tables. Enables save/load map and persistence (objects despawned from last player exiting a level gets respawned when a player enter that level)

# CREDITS

- [Beard's Mod](https://mods.sm64coopdx.com/mods/beards-mod.181/)

# Useful info about developing

General:
- gGlobalSyncTable are not good to track the object

What is the problem with tracking objects (i guess race conditions):
- If an object despaws by itself (for example a shell gets used, or a wing cap hits the despawn timer) the object would still be in the tracking table?
- I thought of using hooks everytime an object loads or unloads (this solution can possibily even avoid using `network_send`), so we are sure that even thought an object autodespawn by itself the deletion is tracked in the users tables
- But another problem came up. When a player exits a level and all objects despawn, hook on object unload also deletes the spawned objects from the table, invalidating the entire persistence functionality
- Can't even avoid this by using a flag (like `isClearingLevel = 1`), because what if another for example a player manually deletes an object while the flag is true? The object would simply not be deleted from the table


In case someone can make it work:
- One can introduce more complexity and make it work, but my goal is to keep the script as simple as possible. I could reconsider
- One can choose to keep the table of objects only on the host device, but this means that everytime a player enters a level visited before, the host would be forced to send the entire list of objects on that level to the player who is entering it in order for the him to restore the objects

