-- name: Spawn Objects Arena (beta)
-- description: Lets players spawn limited objects selection and delete close objects
-- Differences with spawn objects base:
-- - Less spawnable objects
-- - Reduced delete range
-- - Cooldown timer also for deletion
-- - Despawns all arena objects on level init
-- - Tries to avoid unmap the Y button for the Arena mod

local vowels = {
    ["A"] = true, ["E"] = true, ["I"] = true, ["O"] = true, ["U"] = true
}

local COOLDOWN_FRAMES = 80
local COOLDOWN_FRAMES_DEL = 20
-- local SPEED_MULTIPLIER = 1.5
local SPEED_MULTIPLIER = 5.0

-- Menu: allow guest object deletion
gGlobalSyncTable.allowGuestDeletion = true
-- Only the host sees this checkbox in the mod menu
if network_is_server() then
    hook_mod_menu_checkbox("Allow Guest Object Deletion", true, function(index, value)
        if network_is_server() then
            gGlobalSyncTable.allowGuestDeletion = value
        end
end

-- Menu categories and subcategories
local categories = {
    -- (all your categories stay exactly the same - no changes here)
    {
        name = "Powerups",
        items = {
            { behavior = id_bhvKoopaShell, model = E_MODEL_KOOPA_SHELL, name = "Shell", spawnOffset = 50 },
            { behavior = id_bhvWingCap, model = E_MODEL_TOADS_WING_CAP, name = "Wing Cap", spawnOffset = 200 },
            { behavior = id_bhvHoot, model = E_MODEL_HOOT,name = "Owl", spawnOffset = 0 },
        }
    },
    {
        name = "Platforms",
        items = {
            {name = "Wood piece", model = E_MODEL_LLL_WOOD_BRIDGE, behavior = id_bhvLllWoodPiece, spawnYOffset = -100},
            { behavior = id_bhvTtmRollingLog, model = E_MODEL_TTM_ROLLING_LOG, name = "Log", spawnYOffset = -250 },
            {name = "Log LLL", model = E_MODEL_LLL_ROLLING_LOG, behavior = id_bhvLllRollingLog, spawnYOffset = -250},
            { behavior = id_bhvTree, model = E_MODEL_BUBBLY_TREE, name = "Tree", spawnOffset = 250, spawnYOffset = -100 },
            { behavior = id_bhvTweester, model = E_MODEL_TWEESTER, name = "Tweester", spawnOffset = 0, spawnYOffset = 0 },
            { behavior = id_bhvBitfsSinkingPlatforms, model = E_MODEL_BITFS_SINKING_PLATFORMS, name = "Sinking Platform", spawnOffset = 0, spawnYOffset = -100 },
            {name = "Sinking rectangular platform", model = E_MODEL_LLL_SINKING_RECTANGULAR_PLATFORM, behavior = id_bhvLllSinkingRectangularPlatform},
            {name = "Sinking rock block", model = E_MODEL_LLL_SINKING_ROCK_BLOCK, behavior = id_bhvLllSinkingRockBlock, spawnOffset = 200, spawnYOffset = -200},
            {name = "Sinking square platforms", model = E_MODEL_LLL_SINKING_SQUARE_PLATFORMS, behavior = id_bhvLllSinkingSquarePlatforms},
            {name = "Sinking cage platform", behavior = id_bhvBitfsSinkingCagePlatform, model = E_MODEL_BITFS_SINKING_CAGE_PLATFORM, spawnOffset = 200, spawnYOffset = -150},
            { behavior = id_bhvSquarishPathMoving, model = E_MODEL_BITDW_SQUARE_PLATFORM, name = "Moving Pyramid", spawnOffset = 0, spawnYOffset = -80 },
            { behavior = id_bhvTTC2DRotator, model = E_MODEL_TTC_CLOCK_HAND, name = "Clock Hand", spawnOffset = 0, spawnYOffset = -40 },
            { behavior = id_bhvSeesawPlatform, model = E_MODEL_BITDW_SEESAW_PLATFORM, name = "Seesaw", spawnOffset = 200, spawnYOffset = -60 },
            -- Koopa flag always goes on the ground, so i make it spawn higher
            { behavior = id_bhvLllDrawbridge, model = E_MODEL_LLL_DRAWBRIDGE_PART, name = "Drawbridge", spawnOffset = 200, spawnYOffset = -50 },
            {name = "Mesh elevator", model = E_MODEL_BBH_MESH_ELEVATOR, behavior = id_bhvMeshElevator, spawnOffset = 200, spawnYOffset = -50},
            {name = "Moving octagon", model = E_MODEL_LLL_MOVING_OCTAGONAL_MESH_PLATFORM, behavior = id_bhvLllMovingOctagonalMeshPlatform, spawnOffset = 200, spawnYOffset = -200},
            {name = "Bits octagonal platform", model = E_MODEL_BITS_OCTAGONAL_PLATFORM, behavior = id_bhvOctagonalPlatformRotating, spawnYOffset = -300},
            {name = "RR octagonal platform", model = E_MODEL_RR_OCTAGONAL_PLATFORM, behavior = id_bhvOctagonalPlatformRotating, spawnYOffset = -300},
            { behavior = id_bhvDonutPlatform, model = E_MODEL_RR_DONUT_PLATFORM, name = "Donut Platform", spawnOffset = 200, spawnYOffset = -200 },
            { behavior = id_bhvSwingPlatform, model = E_MODEL_RR_SWINGING_PLATFORM, name = "Swing", spawnOffset = -100, spawnYOffset = 400 },
            {name = "Checkerboard elevator", behavior = id_bhvCheckerboardPlatformSub, model = E_MODEL_CHECKERBOARD_PLATFORM, spawnOffset = 300, spawnYOffset = -200},
            { behavior = id_bhvCheckerboardElevatorGroup, model = E_MODEL_CHECKERBOARD_PLATFORM, name = "Checkerboard Elevator Group", spawnYOffset = -80 },
            {name = "HMC elevator platform", model = E_MODEL_HMC_ELEVATOR_PLATFORM, behavior = id_bhvHmcElevatorPlatform, spawnOffset = 0, spawnYOffset = -80},
            {name = "Merry go round", model = E_MODEL_BBH_MERRY_GO_ROUND, behavior = id_bhvMerryGoRound, spawnOffset = 300},
            { behavior = id_bhvSquishablePlatform, model = E_MODEL_BITFS_STRETCHING_PLATFORMS, name = "Stretching Platforms", spawnOffset = 0, spawnYOffset = -120 },
            {name = "Koopa flag", model = E_MODEL_KOOPA_FLAG, behavior = id_bhvKoopaFlag, spawnOffset = 200, spawnYOffset = 20 },
            -- {name = "Koopa race endpoint", model = E_MODEL_KOOPA_FLAG, behavior = id_bhvKoopaRaceEndpoint},
            { behavior = id_bhvKickableBoard, model = E_MODEL_WF_KICKABLE_BOARD, name = "Kickable Board", spawnYOffset = -30 },
            { behavior = id_bhvLllRotatingHexagonalRing, model = E_MODEL_LLL_ROTATING_HEXAGONAL_RING, name = "Spinning Hexagon" },
            {name = "Bitfs elevator", behavior = id_bhvActivatedBackAndForthPlatform, model = E_MODEL_BITFS_ELEVATOR, spawnOffset = 100, spawnYOffset = -150},
            {name = "Tilting floor platform", behavior = id_bhvBbhTiltingTrapPlatform, model = E_MODEL_BBH_TILTING_FLOOR_PLATFORM, spawnYOffset = -200},
            {name = "Bitfs Tilting inverted pyramid", behavior = id_bhvBitfsTiltingInvertedPyramid, model = E_MODEL_BITFS_TILTING_SQUARE_PLATFORM, spawnYOffset = -300},
            {name = "LLL Tilting inverted pyramid", model = E_MODEL_LLL_TILTING_SQUARE_PLATFORM, behavior = id_bhvLllTiltingInvertedPyramid, spawnYOffset = -300},
            {name = "Floor trap", model = E_MODEL_CASTLE_BOWSER_TRAP, behavior = id_bhvFloorTrapInCastle},
            {name = "JRB floating platform", model = E_MODEL_JRB_FLOATING_PLATFORM, behavior = id_bhvJrbFloatingPlatform},
            {name = "Bits ferris wheel", model = E_MODEL_BITS_FERRIS_WHEEL_AXLE, behavior = id_bhvFerrisWheelAxle},
            {name = "Bitdw ferris wheel", model = E_MODEL_BITDW_FERRIS_WHEEL_AXLE, behavior = id_bhvFerrisWheelAxle},
            {name = "Controllable platform", behavior = id_bhvControllablePlatform, model = E_MODEL_HMC_METAL_PLATFORM},
            {name = "Arrow lift", behavior = id_bhvArrowLift, model = E_MODEL_WDW_ARROW_LIFT, spawnOffset = 0, spawnYOffset = -200},
            {name = "Cap switch base", behavior = id_bhvCapSwitchBase, model = E_MODEL_CAP_SWITCH_BASE},
        }
    },
    {
        name = "Boxes",
        items = {
            { behavior = id_bhvBreakableBox, model = E_MODEL_BREAKABLE_BOX, name = "Breakable Box"},
            { behavior = id_bhvTTCRotatingSolid, model = E_MODEL_TTC_ROTATING_CUBE, name = "Rotating Cube", spawnYOffset = -80 },
            { behavior = id_bhvPushableMetalBox, model = E_MODEL_METAL_BOX, name = "Metal Box", spawnOffset = 200, spawnYOffset = 0 },
            { behavior = id_bhvBreakableBox, model = E_MODEL_ERROR_MODEL, name = "ERROR" },
            {name = "Breakable box small", behavior = id_bhvBreakableBoxSmall, model = E_MODEL_BREAKABLE_BOX_SMALL},
            {name = "JRB floating box", model = E_MODEL_JRB_SLIDING_BOX, behavior = id_bhvJrbFloatingBox},
            {name = "Staircase step", model = E_MODEL_BBH_STAIRCASE_STEP, behavior = id_bhvHiddenStaircaseStep},
            {name = "JRB sliding box", model = E_MODEL_JRB_SLIDING_BOX, behavior = id_bhvJrbSlidingBox},
        }
    },
    {
        name = "Hazards",
        items = {
            -- { behavior = id_bhvMontyMoleRock, model = E_MODEL_PEBBLE, name = "Mole rock", spawnOffset = 150 },
            { behavior = id_bhvFlameBowser, model = E_MODEL_PEBBLE, name = "Mole rock", spawnOffset = 150 },
            { behavior = id_bhvBowserShockWave, model = E_MODEL_BOWSER_WAVE, name = "Shockwave", spawnOffset = 0 },
            {name = "Flame moving forward growing", model = E_MODEL_RED_FLAME, behavior = id_bhvFlameMovingForwardGrowing},
            { behavior = id_bhvFlame, model = E_MODEL_RED_FLAME, name = "Red Flame", spawnOffset = 200 },
            { behavior = id_bhvBowlingBall, model = E_MODEL_BOWLING_BALL, name = "Bowling Ball", spawnOffset = 300 },
            {name = "Explosion", behavior = id_bhvExplosion, model = E_MODEL_EXPLOSION, spawnOffset = 400},
            {name = "Bowser flame", model = E_MODEL_RED_FLAME, behavior = id_bhvFlameBowser},
            { behavior = id_bhvHeaveHo, model = E_MODEL_HEAVE_HO, name = "Heave-Ho", spawnOffset = 200 },
            {name = "Bouncing fireball spawn", behavior = id_bhvBouncingFireball, model = E_MODEL_ERROR_MODEL},
            {name = "Flame bouncing", model = E_MODEL_RED_FLAME, behavior = id_bhvFlameBouncing},
            {name = "Blue flames group", behavior = id_bhvBlueFlamesGroup, model = E_MODEL_BLUE_FLAME},
            { behavior = id_bhvToxBox, model = E_MODEL_SSL_TOX_BOX, name = "Tox-Box" },
            { behavior = id_bhvFlamethrower, model = E_MODEL_STAR, name = "Flamethrower", spawnOffset = 200 },
            { behavior = id_bhvFireSpitter, model = E_MODEL_BOWLING_BALL, name = "Fire Spitter", spawnOffset = 200 },
            {name = "Grindel", model = E_MODEL_SSL_GRINDEL, behavior = id_bhvGrindel},
            { behavior = id_bhvHorizontalGrindel, model = E_MODEL_SSL_GRINDEL, name = "Moving grindel", spawnOffset = 400 },
            -- { behavior = id_bhvBigBoulder, model = E_MODEL_HMC_ROLLING_ROCK, name = "Boulder", spawnOffset = 450 },
            { behavior = id_bhvClamShell, model = E_MODEL_CLAM_SHELL, name = "Clam Shell", spawnOffset = 400 },
            { behavior = id_bhvBulletBill, model = E_MODEL_BULLET_BILL, name = "Bullet Bill spawn", spawnOffset = 400 },
            { behavior = id_bhvLllVolcanoFallingTrap, model = E_MODEL_LLL_VOLCANO_FALLING_TRAP, name = "Wall Trap" },
            { behavior = id_bhvMadPiano, model = E_MODEL_MAD_PIANO, name = "Piano", spawnOffset = 300 },
            { model = E_MODEL_HAUNTED_CHAIR, behavior = id_bhvHauntedChair, name = "Haunted chair", spawnOffset = 300 },
            {name = "Rotating block with fire", model = E_MODEL_LLL_ROTATING_BLOCK_FIRE_BARS, behavior = id_bhvLllRotatingBlockWithFireBars, spawnOffset = 300},
            {name = "Bowser bomb", behavior = id_bhvBowserBomb, model = E_MODEL_BOWSER_BOMB, spawnYOffset = 200},
            {name = "Falling pillar", model = E_MODEL_JRB_FALLING_PILLAR, behavior = id_bhvFallingPillar, spawnOffset = 400},
        }
    },
    {
        name = "Enemies",
        items = {
            { behavior = id_bhvGoomba, model = E_MODEL_GOOMBA, name = "Goomba", spawnOffset = 200 },
            {name = "Goomba triplet spawner", model = E_MODEL_ERROR_MODEL, behavior = id_bhvGoombaTripletSpawner},
            { name = "Koopa", model = E_MODEL_KOOPA_WITH_SHELL, behavior = id_bhvKoopa, spawnOffset = 200 },
            { behavior = id_bhvBobomb, model = E_MODEL_BOBOMB_BUDDY, name = "Bobomb Not-Buddy", spawnOffset = 200 },
            {name = "Bobomb", behavior = id_bhvBobomb, model = E_MODEL_BLACK_BOBOMB, spawnOffset = 100 },
            { behavior = id_bhvThwomp, model = E_MODEL_THWOMP, name = "Thwomp", spawnOffset = 300 },
            { behavior = id_bhvChainChomp, model = E_MODEL_CHAIN_CHOMP, name = "Chain Chomp", spawnOffset = 400 },
            { behavior = id_bhvChuckya, model = E_MODEL_CHUCKYA, name = "Chuckya", spawnOffset = 200 },
            { behavior = id_bhvScuttlebug, model = E_MODEL_SCUTTLEBUG, name = "Scuttlebug", spawnOffset = 200 },
            { behavior = id_bhvFlyGuy, model = E_MODEL_FLYGUY, name = "Fly Guy", spawnOffset = 300 },
            { behavior = id_bhvSmallBully, model = E_MODEL_BULLY, name = "Bully", spawnOffset = 100 },
            { behavior = id_bhvEnemyLakitu, model = E_MODEL_LAKITU, name = "Lakitu", spawnOffset = 200 },
            { behavior = id_bhvBoo, model = E_MODEL_BOO, name = "Boo", spawnOffset = 300 },
            { behavior = id_bhvBalconyBigBoo, model = E_MODEL_BOO, name = "Balcony big boo", spawnOffset = 300 },
            { behavior = id_bhvSwoop, model = E_MODEL_SWOOP, name = "Bat", spawnOffset = 200 },
            { behavior = id_bhvSnufit, model = E_MODEL_SNUFIT, name = "Snufit", spawnOffset = 200 },
            { behavior = id_bhvCirclingAmp, model = E_MODEL_AMP, name = "Circling Amp", spawnOffset = 0 },
            { behavior = id_bhvHomingAmp, model = E_MODEL_AMP, name = "Homing Amp", spawnOffset = 300 },
            { behavior = id_bhvKlepto, model = E_MODEL_KLEPTO, name = "Vulture", spawnOffset = 300 },
            { behavior = id_bhvUnagi, model = E_MODEL_UNAGI, name = "Eel" },
            { behavior = id_bhvBubba, model = E_MODEL_BUBBA, name = "Bubba", spawnOffset = 200 },
            {name = "Book", model = E_MODEL_BOOKEND, behavior = id_bhvFlyingBookend},
            {name = "Moneybag hidden", model = E_MODEL_MONEYBAG, behavior = id_bhvMoneybagHidden},
            -- TODO: To make it work first spawn hole than mole. Can this be fixed?
            {name = "Mole hole (spawn first)", model = E_MODEL_DL_MONTY_MOLE_HOLE, behavior = id_bhvMontyMoleHole},
            {name = "Mole (spawn second)", model = E_MODEL_MONTY_MOLE, behavior = id_bhvMontyMole},
            {name = "Snowman", model = E_MODEL_MR_BLIZZARD, behavior = id_bhvMrBlizzard},
        }
    },
    {
        name = "Misc",
        items = {
            { behavior = id_bhvCannon, model = E_MODEL_CANNON_BASE, name = "Cannon", spawnYOffset = 0 },
            { behavior = id_bhvJumpingBox, model = E_MODEL_BREAKABLE_BOX_SMALL, name = "Jumping Box" },
            {name = "DDD moving pole", behavior = id_bhvDddMovingPole, model = E_MODEL_DDD_POLE},
            {name = "Castle flag", behavior = id_bhvCastleFlagWaving, model = E_MODEL_CASTLE_GROUNDS_FLAG},
            {name = "Chain chomp gate", behavior = id_bhvChainChompGate, model = E_MODEL_BOB_CHAIN_CHOMP_GATE},
        }
    },
}

local playerData = {}
local selectedCategory = 1
local selectedObjectInCat = {}   -- remembers position inside each submenu
local inSubmenu = false

local function get_player_data(playerIndex)
    if not playerData[playerIndex] then
        playerData[playerIndex] = { 
            cooldown = 0,
            deletionCooldown = 0 
        }
    end
    return playerData[playerIndex]
end

-- ====================== MENU NAVIGATION ======================
-- D-Pad Up/Down = navigate list
-- D-Pad Right   = enter submenu (from main) or next category (while in submenu)
-- D-Pad Left    = back to main menu (from submenu)
function move_selection(m)
    local buttons = m.controller.buttonPressed
    if buttons & U_JPAD ~= 0 then
        if inSubmenu then
            selectedObjectInCat[selectedCategory] = (selectedObjectInCat[selectedCategory] or 1) - 1
        else
            selectedCategory = selectedCategory - 1
        end
    elseif buttons & D_JPAD ~= 0 then
        if inSubmenu then
            selectedObjectInCat[selectedCategory] = (selectedObjectInCat[selectedCategory] or 1) + 1
        else
            selectedCategory = selectedCategory + 1
        end
    elseif buttons & L_JPAD ~= 0 then
        if inSubmenu then
            inSubmenu = false
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            return
        else
            selectedCategory = selectedCategory - 1
        end
    elseif buttons & R_JPAD ~= 0 then
        if not inSubmenu then
            inSubmenu = true
            if not selectedObjectInCat[selectedCategory] then
                selectedObjectInCat[selectedCategory] = 1
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            return
        else
            -- next category while in submenu
            selectedCategory = selectedCategory + 1
            if selectedCategory > #categories then selectedCategory = 1 end
            if not selectedObjectInCat[selectedCategory] then
                selectedObjectInCat[selectedCategory] = 1
            end
        end
    else
        return
    end

    -- clamp values
    if inSubmenu then
        local items = categories[selectedCategory].items
        selectedObjectInCat[selectedCategory] = math.max(1, math.min(selectedObjectInCat[selectedCategory] or 1, #items))
    else
        selectedCategory = math.max(1, math.min(selectedCategory, #categories))
    end

    play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
end

function spawn_selected(m)
    if m.controller.buttonPressed & X_BUTTON == 0 then return end
    if not inSubmenu then return end   -- only spawn when inside a submenu

    local data = get_player_data(m.playerIndex)
    if data.cooldown > 0 then return end

    local cat = categories[selectedCategory]
    local idx = selectedObjectInCat[selectedCategory] or 1
    local obj = cat.items[idx]
    local name = obj.name

    -- spawn relative to Mario's facing direction + speed bonus + height offset
    -- local baseOffset = obj.spawnOffset or 400
    local baseOffset = obj.spawnOffset or 200
    local forwardVel = m.forwardVel or 0
    local speedBonus = math.max(0, forwardVel) * SPEED_MULTIPLIER
    local effectiveOffset = baseOffset + speedBonus

    local spawnX = m.pos.x + effectiveOffset * sins(m.faceAngle.y)
    local spawnY = m.pos.y + (obj.spawnYOffset or 0)
    local spawnZ = m.pos.z + effectiveOffset * coss(m.faceAngle.y)

    spawn_sync_object(obj.behavior, obj.model, spawnX, spawnY, spawnZ, nil)

    data.cooldown = COOLDOWN_FRAMES

    djui_popup_create("Spawned \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
end

-- ====================== DELETE NEAREST OBJECT (Y button) ======================
local function find_nearest_object(m)
    local nearest = nil
    local minDistSq = 600 * 600

    -- List of object lists
    local lists = {
        OBJ_LIST_DESTRUCTIVE,
        OBJ_LIST_GENACTOR,
        OBJ_LIST_PUSHABLE,      -- Goombas, Koopas, etc.
        OBJ_LIST_LEVEL,
        OBJ_LIST_DEFAULT,
        OBJ_LIST_SURFACE,       -- Thwomp, Dorrie, Submarine, many platforms
        OBJ_LIST_POLELIKE,      -- Trees, Tweester, etc.
        OBJ_LIST_SPAWNER,
        -- OBJ_LIST_UNIMPORTANT, -- uncomment only if you also want to delete butterflies, fish, etc.
    }

    for _, list in ipairs(lists) do
        local obj = obj_get_first(list)
        while obj ~= nil do
            -- Skip any player's Mario object
            local isMarioObj = false
            for i = 0, MAX_PLAYERS - 1 do
                if gMarioStates[i] and gMarioStates[i].marioObj == obj then
                    isMarioObj = true
                    break
                end
            end

            -- Skip ALL doors (covers normal doors, warp doors, star doors, basement door, etc.)
            local isDoor = false
            if not isMarioObj then
                -- local bhv = obj.behavior
                if obj.oInteractType == INTERACT_DOOR or
                   obj.oInteractType == INTERACT_WARP_DOOR then
                     isDoor = true
                end
            end

            if not isMarioObj and not isDoor then
                local dx = obj.oPosX - m.pos.x
                local dy = obj.oPosY - m.pos.y
                local dz = obj.oPosZ - m.pos.z
                local distSq = dx*dx + dy*dy + dz*dz
                if distSq < minDistSq then
                    minDistSq = distSq
                    nearest = obj
                end
            end
            obj = obj_get_next(obj)
        end
    end

    return nearest
end

local function handle_object_deletion(m)
    if (m.controller.buttonPressed & Y_BUTTON) == 0 then return end

    -- Do not allow Arena mod to use the Y button
    m.controller.buttonPressed = m.controller.buttonPressed & ~Y_BUTTON

    local data = get_player_data(m.playerIndex)
    if data.deletionCooldown > 0 then return end   -- <-- NEW: cooldown check

    local canDelete = network_is_server() or gGlobalSyncTable.allowGuestDeletion

    if not canDelete then
        if m.playerIndex == 0 then
            djui_popup_create("\\#ff4444\\Guest object deletion is disabled by host!", 2)
        end
        return
    end

    local nearest = find_nearest_object(m)
    if nearest then
        -- Hide graphics immediately (fixes leftover coin shadows)
        if nearest.header and nearest.header.gfx and nearest.header.gfx.node then
            nearest.header.gfx.node.flags = nearest.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        end

        obj_mark_for_deletion(nearest)

        data.deletionCooldown = COOLDOWN_FRAMES_DEL   -- <-- NEW: set cooldown

        if m.playerIndex == 0 then
            djui_popup_create("\\#ffff00\\Deleted nearest object", 0.5)
        end
    else
        if m.playerIndex == 0 then
            djui_popup_create("No nearby object found", 0.5)
        end
    end
end

-- ====================== AUTO CLEANUP ALL SPAWNED OBJECTS ON LEVEL LOAD ======================
local function clear_all_spawned_objects()
    -- Use the EXACT same lists as find_nearest_object (plus UNIMPORTANT for Arena items)
    local lists = {
        OBJ_LIST_DESTRUCTIVE,
        OBJ_LIST_GENACTOR,
        OBJ_LIST_PUSHABLE,
        OBJ_LIST_LEVEL,
        OBJ_LIST_DEFAULT,
        OBJ_LIST_SURFACE,
        OBJ_LIST_POLELIKE,
        OBJ_LIST_SPAWNER,
        -- OBJ_LIST_UNIMPORTANT,   -- Arena hammers, bombs, throwable items, etc.
    }

    for _, listType in ipairs(lists) do
        local obj = obj_get_first(listType)
        while obj ~= nil do
            local nextObj = obj_get_next(obj)

            -- Safety: never delete Mario
            local isMario = false
            for i = 0, MAX_PLAYERS - 1 do
                if gMarioStates[i] and gMarioStates[i].marioObj == obj then
                    isMario = true
                    break
                end
            end

            -- Safety: never delete doors
            local isDoor = (obj.oInteractType == INTERACT_DOOR or
                            obj.oInteractType == INTERACT_WARP_DOOR)

            if not isMario and not isDoor then
                -- Hide graphics immediately (prevents leftover shadows)
                if obj.header and obj.header.gfx and obj.header.gfx.node then
                    obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
                end
                obj_mark_for_deletion(obj)
            end

            obj = nextObj
        end
    end
end

-- ====================== PERSONAL RESET ======================
hook_chat_command("die", "Use this to die", function(msg)
    local m = gMarioStates[0]
    -- local np = gNetworkPlayers[0]

    -- -- Respawn + delete all created objects
    -- if msg == "delobj" then
    --   warp_to_level(np.currLevelNum, np.currAreaIndex, 0x0A)

    --   djui_popup_create("Respawned at start, created objects deleted", 3)
    --   return true
    -- end

    -- Respawn  without deleting objects
    m.health = 0
    set_mario_action(m, ACT_DEATH, 0)

    djui_popup_create("Respawned at start", 3)
    return true
end)

-- ====================== RENDERING ======================
function render_menu()
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- background
    djui_hud_set_color(0, 0, 0, 200)
    djui_hud_render_rect(8, 68, 370, 495)

    -- title
    djui_hud_set_color(255, 100, 0, 255)
    if inSubmenu then
        djui_hud_print_text(categories[selectedCategory].name:upper(), 20, 78, 1.2)
    else
        djui_hud_print_text("OBJECT SPAWNER", 20, 78, 1.2)
    end

    local VISIBLE_ITEMS = 15
    local startY = 120

    if inSubmenu then
        -- show objects inside the selected category
        local items = categories[selectedCategory].items
        local sel = selectedObjectInCat[selectedCategory] or 1
        local startIdx = math.max(1, sel - 7)
        local endIdx = math.min(#items, startIdx + VISIBLE_ITEMS - 1)

        for i = startIdx, endIdx do
            local y = startY + (i - startIdx) * 24
            local text = items[i].name

            if i == sel then
                djui_hud_set_color(255, 255, 0, 255)
                djui_hud_render_rect(15, y, 355, 29)
                djui_hud_set_color(0, 0, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 230)
            end
            djui_hud_print_text(text, 22, y, 1.0)
        end
    else
        -- main menu: show categories
        local startIdx = math.max(1, selectedCategory - 7)
        local endIdx = math.min(#categories, startIdx + VISIBLE_ITEMS - 1)

        for i = startIdx, endIdx do
            local y = startY + (i - startIdx) * 24
            local text = categories[i].name

            if i == selectedCategory then
                djui_hud_set_color(255, 255, 0, 255)
                djui_hud_render_rect(15, y, 355, 29)
                djui_hud_set_color(0, 0, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 230)
            end
            djui_hud_print_text(text, 22, y, 1.0)
        end
    end

    -- instructions at bottom
    djui_hud_set_color(180, 180, 180, 200)
    djui_hud_print_text("D-PAD L/R = submenu    X = spawn", 25, 510, 0.85)
    djui_hud_print_text("Y = delete nearest object", 25, 510 + 20, 0.85)
end

function render_cooldown_timer()
    local m = gMarioStates[0]
    local data = get_player_data(m.playerIndex)

    if data.cooldown <= 0 and data.deletionCooldown <= 0 then
        return
    end

    djui_hud_set_resolution(RESOLUTION_N64)

    local scale = 0.32
    local screenWidth = djui_hud_get_screen_width()
    local y = 8

    -- Spawn cooldown
    if data.cooldown > 0 then
        local seconds = math.floor(data.cooldown * 10 / 30) / 10
        local text = "Spawn cooldown " .. tostring(seconds) .. "s"

        local width = djui_hud_measure_text(text) * scale
        local x = (screenWidth - width) / 2.0

        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_render_rect(x - 4, y, width + 8, 18)

        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(text, x, y, scale)

        -- y = y + 22   -- move down for the next line
        y = y + 16
    end

    -- Deletion cooldown
    if data.deletionCooldown > 0 then
        local seconds = math.floor(data.deletionCooldown * 10 / 30) / 10
        local text = "Delete cooldown " .. tostring(seconds) .. "s"

        local width = djui_hud_measure_text(text) * scale
        local x = (screenWidth - width) / 2.0

        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_render_rect(x - 4, y, width + 8, 18)

        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(text, x, y, scale)
    end
end

function on_hud_render()
    if gMarioStates[0].action == ACT_DEATH or gMarioStates[0].action == ACT_GAME_OVER then return end
    render_menu()
    render_cooldown_timer()
end

-- ====================== HOOKS ======================
hook_event(HOOK_MARIO_UPDATE, function(m)
    -- cooldown for every player
    local data = get_player_data(m.playerIndex)
    if data.cooldown > 0 then
        data.cooldown = data.cooldown - 1
    end
    if data.deletionCooldown > 0 then
        data.deletionCooldown = data.deletionCooldown - 1
    end

    -- Y-button deletion
    handle_object_deletion(m)

    -- only local player (index 0) controls the spawn menu
    if m.playerIndex ~= 0 then return end
    move_selection(m)
    spawn_selected(m)
end)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_LEVEL_INIT, clear_all_spawned_objects)

print("Use D-Pad L/R for submenu navigation")
