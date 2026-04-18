# Intro

THIS MOD IS STILL IN DEVELOPMENT.

Spawn objects from a categorized menu and delete nearest object. Dending on the script version more functions are available (for example save and persistence).

# Menu options

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

# spawn-objects-simplesave

Adds save map functionality, but does not track objects. Every spawned object is marked, so that during save process only the marked objects will be saved.

- spawning code is executed on the host device, despite who launched it
- created objects are tracked on the host device only
- persistence (as said above)

# spawn-obejcts-persistence

IN DEVELOPMENT

Tracks spanwed object in tables. Enables save/load map and persistence (objects despawned from last player exiting a level gets respawned when a player enter that level)

# Useful info about developing

- gGlobalSyncTable are not good to track the obejct

