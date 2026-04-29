# Intro

THIS MOD IS STILL IN DEVELOPMENT.

Spawn objects from a categorized menu and delete nearest object. Dending on the script version more functions are available (for example save and persistence).

# Which one to choose

The versions can be identified by these letters in the script name:
- **d** : includes `delete nearest object` feature
- **s** : includes `save map` feature to let players save spawned objects. Save Tracks all objects created 
- **p** : includes persistence (objects on a level won't be lost even if all players exit that level)

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

IN DEVELOPMENT, NOT WORKING

- Spawn objects using a menu and delete the nearest object
- no persistence
- no save and load feature

# spawn-objects-arena

TODO

# spawn-objects-singlelevel

IN DEVELOPMENT, NOT WORKING

- No persistence, hence only a single level is allowed
- Allows map saving (all) and loading (host only). Make sure to delete everything before using /loadmap

# spawn-obejcts-persistence

IN DEVELOPMENT, NOT WORKING

Tracks spanwed object in tables. Enables save/load map and persistence (objects despawned from last player exiting a level gets respawned when a player enter that level)

# CREDITS

- [Beard's Mod](https://mods.sm64coopdx.com/mods/beards-mod.181/)

# Useful info about developing

syntax fmt

```bash
stylua --indent-type Spaces --indent-width 4 --line-endings Unix spawn-objects-singlelevel.lua
```

General:
- gGlobalSyncTable are not good to track the objects

What is the problem with tracking objects (i guess race conditions):
- If an object despaws by itself (for example a shell gets used, or a wing cap hits the despawn timer) the object would still be in the tracking table?
- I thought of using hooks everytime an object loads or unloads (this solution can possibily even avoid using `network_send`), so we are sure that even thought an object autodespawn by itself the deletion is tracked in the users tables
- But another problem came up. When a player exits a level and all objects despawn, hook on object unload also deletes the spawned objects from the table, invalidating the entire persistence functionality
- Will try avoiding this using a flag (like `isClearingLevel = 1`)

Other:
- One can choose to keep the table of objects only on the host device, but this means that everytime a player enters a level visited before, the host would be forced to send the entire list of objects on that level to the player who is entering it in order for the him to restore the objects

