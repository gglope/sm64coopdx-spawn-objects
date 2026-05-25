# Intro

Spawn objects from a categorized menu and delete nearest object. Objects spawn position is decided by the script.
Depending on the script version more functions are available.

# Which one to choose

I consider the "normal" version this one: `spawn-objects-d.lua`

Other versions can be identified by the letters in the script name:

- **spawn-objects-d.lua** : includes `delete nearest object` feature, allows controls scheme change
- **spawn-objects.lua**: standard version, only allows objects spawn (no delete). Does not allow controls scheme change
- **spawn-objects-2.lua** : like spawn-objects.lua but D-PAD up and down are not used, so that the user can combine this mod with other mods that use D-PAD up and down (e.g. checkpoints). Spawn menu is traversed by only using D-PAD left and right and the X button

# Bugs

# Commands

## Standard

- D-PAD UP/DOWN: next/previous element
- D-PAD RIGHT in menu: enter selected submenu
- D-PAD RIGHT in submenu: jump 5 elements below
- D-PAD LEFT in submenu: return to main menu
- X: spawn selected object
- Y: delete nearest object
- /respawn to respawn when Mario gets stuck for any reason
- /clearall (host only) delete all mod spawned objects

## spawn-object-d with option dpadUDFree enabled

- D-PAD UP/DOWN: **UNUSED**
- D-PAD RIGHT/LEFT: next/previous element
- X in menu: enter submenu
- X in submenu: spawn selected object
- Y in menu: delete nearest object
- Y in submenu: return to main menu
- /respawn to respawn when Mario gets stuck for any reason
- /clearall (host only) delete all mod spawned objects

## spawn-objects-2

- D-PAD RIGHT in menu: next element
- D-PAD LEFT in menu: previous element
- D-PAD RIGHT in submenu: select next element
- D-PAD LEFT in submenu: go back to main menu
- X in menu: enter selected submenu
- X in submenu: spawn selected object

# Settings

Available to anyone:

- Spawn Objects Upright:
  - default: true
  - If disabled, objects will be tilted based on mario face angle. For example, if you spawn a Sinking platform while diving, the platform will be spawned inclined

Available to host only:

- Allow Guest Object Deletion:
  - default: true
  - If enabled, all connected Marios will be able to delete nearest object
- Free buttons DPAD up and down
  - default: false
  - If enabled, control scheme will be changed to avoid use of D-PAD up and down. See sections "Which one to choose" and "Commands" for more informations

# CREDITS

- [Beard's Mod](https://mods.sm64coopdx.com/mods/beards-mod.181/)
- sm64coopdx [forum](https://mods.sm64coopdx.com/forums/) and [documentation](https://github.com/coop-deluxe/sm64coopdx/tree/main/docs/lua)
- Random objects script from [Drenchy drive](https://drive.google.com/drive/folders/169w_iUIyVJBSf-39y1D26-tvpueW92wE)

# Useful info about developing

syntax fmt

```bash
stylua --indent-type Spaces --indent-width 4 --line-endings Unix spawn-objects-d.lua
```

General:

- It seems that if an object does not have a father, then `obj.parentObj == obj` (same pointer)
- While `spawn_sync_object` spawns an object for everyone, the function to delete it `obj_mark_for_deletion` works for everyone only on a subset of objects
- `network_init_object` in the init function of `spawn_sync_object` can cause desync and weird stuff
- gGlobalSyncTable are not good to track the objects


Objects tracking (TODO):

- Every user has its own table cointaining objects spawned by every player. This table also stores the objects spawned in maps different from the one the player's in
- Everytime a new object is spawned, the user who spawned it sends a packet to tell other connected players to add add the new object in their tables too, so that all users have the same table (manual sync)
- Some objects despawn by themselves, without anyone deleting it (for example a shell gets used, or a wing cap hits the despawn timer). So, in order to keep the tracking table consistent, we need to delete these objects from the table as well. By using `HOOK_ON_SYNC_ONJECT_UNLOAD`, when an object disappears, we can implement code to delete the the object is deleted from the tracking table of the users
- One problem with this approach is that if the host launches a /clearall, `HOOK_ON_SYNC_ONJECT_UNLOAD` will be executed 100s of times, traversing the entire tracking table as many times as the deleted objects, instead of having a single traversing that deletes all the deleted objects from the table. Maybe a mixed approach? Code `HOOK_ON_SYNC_ONJECT_UNLOAD` would need to be disabled before clearall function deletes everything
- Another problem is that when a player exits a level and all objects despawn, thsi `HOOK_ON_SYNC_ONJECT_UNLOAD` would also delete the spawned objects from the table, invalidating the entire persistence functionality. Guess if this can be avoided using a flag like `isClearingLevel = 1`, that is set before the object unload happens

Other:

- One can choose to keep the table of objects only on the host device, but this means that everytime a player enters a level visited before, the host would be forced to send the entire list of objects on that level to the player who is entering it, in order for him to restore the objects

# Links

- gGlobalObjectCollisionData: https://github.com/coop-deluxe/sm64coopdx/blob/main/docs/lua/structs.md#GlobalObjectCollisionData
- https://github.com/coop-deluxe/sm64coopdx/blob/main/src/game/macro_presets.c
- https://github.com/coop-deluxe/sm64coopdx/blob/main/docs/lua/guides/object-lists.md
- James S' Kingdom beh values: https://sites.google.com/site/jamesskingdom/Home/video-game-secrets-by-james-s/super-mario-64-exposed/sm64-exposed-behaviour-values

# Future development (maybe)

- Allow to free Y button, so that it can be used by other mods
- **ss**: includes `save map` feature to let players save spawned objects. Spawned object are NOT tracked, so persistence is not included
- **sp** : includes `save map` feature by tracking the spawned objects, and persistence (object don't get lost when all players leave a map)
- **arena**: specialized for use with arena mod

