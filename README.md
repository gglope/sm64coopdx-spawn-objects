# Intro

This mod is still in development.

Spawn objects from a categorized menu and delete nearest object.
Dpending on the script version more functions are available.

# spawn-objects

The simpler one. Spawn objects using a menu and delete the nearest object.

- spawning code is executed on player's device
- created objects are not tracked
- no persistence (if all player exit a map, all created objects despawn)

# spawn-objects-arena

TODO

# spawn-objects-new

NOT WORKING

Adds spaned objects persistence: if all player exit a map, all created objects despawn but are respawned when another player enters the same map again. All the work is shifted to the host device:

- spawning code is executed on the host device, despite who launched it
- created objects are tracked on the host device only
- persistence (as said above)

