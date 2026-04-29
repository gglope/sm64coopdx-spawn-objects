-- name: Random Objects (custom)
-- description: Modified versioin of random objects.\nEach player has 40s timer, no increment

local vowels = {
    ["A"] = true, ["E"] = true, ["I"] = true, ["O"] = true, ["U"] = true
}

local randomObjects = {
    { behavior = id_bhvGoomba,                    model = E_MODEL_GOOMBA,                      name = "Goomba" },
    { behavior = id_bhvBobomb,                    model = E_MODEL_BOBOMB_BUDDY,                name = "Bobomb Not-Buddy" },
    { behavior = id_bhvArrowLift,                 model = E_MODEL_WDW_ARROW_LIFT,              name = "Arrow Lift" },
    { behavior = id_bhvBoo,                       model = E_MODEL_BOO,                         name = "Boo" },
    { behavior = id_bhvBalconyBigBoo, model = E_MODEL_BOO, name = "BALCONY_BIG_BOO" },
    { behavior = id_bhvChuckya,                   model = E_MODEL_CHUCKYA,                     name = "Chuckya" },
    { behavior = id_bhvTree,                      model = E_MODEL_BUBBLY_TREE,                 name = "Tree" },
    { behavior = id_bhvChainChomp,                model = E_MODEL_CHAIN_CHOMP,                 name = "Chain Chomp" },
    { behavior = id_bhvKoopaShell,                model = E_MODEL_KOOPA_SHELL,                 name = "Shell" },
    { name = "Koopa", model = E_MODEL_KOOPA_WITH_SHELL, behavior = id_bhvKoopa },
    { behavior = id_bhvHoot,                      model = E_MODEL_HOOT,                        name = "Owl" },
    { behavior = id_bhvCannon,                    model = E_MODEL_CANNON_BASE,                 name = "Cannon" },
    { behavior = id_bhvSmallWhomp,                model = E_MODEL_WHOMP,                       name = "Whomp" },
    {name = "Whomp king", model = E_MODEL_WHOMP, behavior = id_bhvWhompKingBoss},
    {name = "Bitfs elevator", behavior = id_bhvActivatedBackAndForthPlatform, model = E_MODEL_BITFS_ELEVATOR},
    {name = "Bits staircase", behavior = id_bhvAnimatesOnFloorSwitchPress, model = E_MODEL_BITS_STAIRCASE},
    { behavior = id_bhvThwomp,                    model = E_MODEL_THWOMP,                      name = "Thwomp" },
    { behavior = id_bhvBulletBill,                model = E_MODEL_BULLET_BILL,                 name = "Bullet Bill" },
    { behavior = id_bhvRecoveryHeart,             model = E_MODEL_HEART,                       name = "Recovery Heart" },
    { model = E_MODEL_HAUNTED_CHAIR, behavior = id_bhvHauntedChair, name = "HAUNTED_CHAIR" },
    { behavior = id_bhvScuttlebug,                model = E_MODEL_SCUTTLEBUG,                  name = "Scuttlebug" },
    {name = "HMC elevator platform", model = E_MODEL_HMC_ELEVATOR_PLATFORM, behavior = id_bhvHmcElevatorPlatform},
    {name = "Koopa without shell", model = E_MODEL_KOOPA_WITHOUT_SHELL, behavior = id_bhvKoopa},
    {name = "Koopa flag", model = E_MODEL_KOOPA_FLAG, behavior = id_bhvKoopaFlag},
    {name = "Moving blue coin", model = E_MODEL_BLUE_COIN, behavior = id_bhvMovingBlueCoin},
    { behavior = id_bhvDorrie,                    model = E_MODEL_DORRIE,                      name = "Sea Dragon" },
    { behavior = id_bhvSwoop,                     model = E_MODEL_SWOOP,                       name = "Bat" },
    { behavior = id_bhvBigBoulder,                model = E_MODEL_HMC_ROLLING_ROCK,            name = "Boulder" },
    { behavior = id_bhvSnufit,                    model = E_MODEL_SNUFIT,                      name = "Snufit" },
    { behavior = id_bhvFlamethrower,              model = E_MODEL_STAR,                        name = "Flamethrower" },
    { behavior = id_bhvJumpingBox,                model = E_MODEL_BREAKABLE_BOX_SMALL,         name = "Jumping Box" },
    {name = "Butterfly", behavior = id_bhvButterfly, model = E_MODEL_BUTTERFLY},
    { behavior = id_bhvToxBox,                    model = E_MODEL_SSL_TOX_BOX,                 name = "Tox-Box" },
    { behavior = id_bhvSquishablePlatform,        model = E_MODEL_BITFS_STRETCHING_PLATFORMS,  name = "Stretching Platforms" },
    { behavior = id_bhvKlepto,                    model = E_MODEL_KLEPTO,                      name = "Vulture" },
    { behavior = id_bhvWingCap,                   model = E_MODEL_TOADS_WING_CAP,              name = "Wing Cap" },
    { behavior = id_bhvMetalCap,                  model = E_MODEL_TOADS_METAL_CAP,             name = "Metal Cap" },
    {name = "One coin", model = E_MODEL_YELLOW_COIN, behavior = id_bhvOneCoin},
    {name = "Red coin", model = E_MODEL_RED_COIN, behavior = id_bhvRedCoin},
    {name = "Ten coins spawn", model = E_MODEL_YELLOW_COIN, behavior = id_bhvTenCoinsSpawn},
    {name = "Three coins spawn", model = E_MODEL_YELLOW_COIN, behavior = id_bhvThreeCoinsSpawn},
    { behavior = id_bhvVanishCap,                 model = E_MODEL_TOADS_CAP,                   name = "Vanish Cap" },
    { behavior = id_bhvFlyGuy,                    model = E_MODEL_FLYGUY,                      name = "Fly Guy" },
    {name = "Haunted bookshelf", model = E_MODEL_BBH_MOVING_BOOKSHELF, behavior = id_bhvHauntedBookshelf},
    { behavior = id_bhvFireSpitter,               model = E_MODEL_BOWLING_BALL,                name = "Fire Spitter" },
    { behavior = id_bhvUkiki,                     model = E_MODEL_UKIKI,                       name = "Monkey" },
    { behavior = id_bhvUnagi,                     model = E_MODEL_UNAGI,                       name = "Eel" },
    { behavior = id_bhvMadPiano,                  model = E_MODEL_MAD_PIANO,                   name = "Piano" },
    { behavior = id_bhvCirclingAmp,               model = E_MODEL_AMP,                         name = "Circling Amp" },
    { behavior = id_bhvHomingAmp,                 model = E_MODEL_AMP,                         name = "Homing Amp" },
    { behavior = id_bhvSpindrift,                 model = E_MODEL_SPINDRIFT,                   name = "Spindrift" },
    { behavior = id_bhvSkeeter,                   model = E_MODEL_SKEETER,                     name = "Skeeter" },
    { behavior = id_bhvBowsersSub,                model = E_MODEL_DDD_BOWSER_SUB,              name = "Submarine" },
    { behavior = id_bhvDDDPole, model = E_MODEL_DDD_POLE, name = "DDD_POLE" },
    { behavior = id_bhvBowser,                    model = E_MODEL_BOWSER,                      name = "Bowser" },
    {name = "Bowser2", behavior = id_bhvBowser, model = E_MODEL_BOWSER2},
    { behavior = id_bhvCheckerboardElevatorGroup, model = E_MODEL_CHECKERBOARD_PLATFORM,       name = "Checkerboard Elevator" },
    { behavior = id_bhvSeesawPlatform,            model = E_MODEL_BITDW_SEESAW_PLATFORM,       name = "Seesaw" },
    { behavior = id_bhvPushableMetalBox,          model = E_MODEL_METAL_BOX,                   name = "Metal Box" },
    { behavior = id_bhvSmallBully,                model = E_MODEL_BULLY,                       name = "Bully" },
    { behavior = id_bhvBigBully,                  model = E_MODEL_BULLY_BOSS,                  name = "Big Bully" },
    { behavior = id_bhvBitfsSinkingPlatforms,     model = E_MODEL_BITFS_SINKING_PLATFORMS,     name = "Sinking Platform" },
    {name = "Big bully with minions", behavior = id_bhvBigBullyWithMinions, model = E_MODEL_BULLY_BOSS},
    {name = "Blue fish", behavior = id_bhvBlueFish, model = E_MODEL_FISH},
    {name = "Bobomb", behavior = id_bhvBobomb, model = E_MODEL_BLACK_BOBOMB},
    { behavior = id_bhvSquarishPathMoving,        model = E_MODEL_BITDW_SQUARE_PLATFORM,       name = "Moving Pyramid" },
    { behavior = id_bhvTTC2DRotator,              model = E_MODEL_TTC_CLOCK_HAND,              name = "Clock Hand" },
    { behavior = id_bhvTTCRotatingSolid,          model = E_MODEL_TTC_ROTATING_CUBE,           name = "Rotating Cube" },
    { behavior = id_bhvHorizontalGrindel,         model = E_MODEL_SSL_GRINDEL,                 name = "Grindel" },
    { behavior = id_bhvLllVolcanoFallingTrap,     model = E_MODEL_LLL_VOLCANO_FALLING_TRAP,    name = "Wall Trap" },
    { behavior = id_bhvLllRotatingHexagonalRing,  model = E_MODEL_LLL_ROTATING_HEXAGONAL_RING, name = "Spinning Hexagon" },
    { behavior = id_bhvHeaveHo,                   model = E_MODEL_HEAVE_HO,                    name = "Heave-Ho" },
    { behavior = id_bhvBowserShockWave,           model = E_MODEL_BOWSER_WAVE,                 name = "Shockwave" },
    { behavior = id_bhvCloud,                     model = E_MODEL_NONE,                        name = "Cloud" },
    { behavior = id_bhvBreakableBox,              model = E_MODEL_BREAKABLE_BOX,               name = "Breakable Box" },
    { behavior = id_bhvBreakableBox,              model = E_MODEL_ERROR_MODEL,                 name = "\\#FF0000\\ERROR\\#FFFFFF\\" },
    { behavior = id_bhvLllDrawbridge,             model = E_MODEL_LLL_DRAWBRIDGE_PART,         name = "Drawbridge" },
    { behavior = id_bhvUnusedFakeStar,            model = E_MODEL_STAR,                        name = "Fake Star " },
    { behavior = id_bhvWhirlpool,                 model = E_MODEL_DL_WHIRLPOOL,                name = "Whirlpool" },
    { behavior = id_bhvTweester,                  model = E_MODEL_TWEESTER,                    name = "Tweester" },
    { behavior = id_bhvTtmRollingLog,             model = E_MODEL_TTM_ROLLING_LOG,             name = "Log" },
    { behavior = id_bhvToadMessage,               model = E_MODEL_TOAD,                        name = "Toad" },
    { behavior = id_bhvTTCSpinner,                model = E_MODEL_TTC_SPINNER,                 name = "Spinner" },
    { behavior = id_bhvSwingPlatform,             model = E_MODEL_RR_SWINGING_PLATFORM,        name = "Swing" },
    { behavior = id_bhvSLWalkingPenguin,          model = E_MODEL_PENGUIN,                     name = "Walking Penguin" },
    { name = "KING_BOBOMB", model = E_MODEL_KING_BOBOMB, behavior = id_bhvKingBobomb },
    { behavior = id_bhvPiranhaPlant,              model = E_MODEL_PIRANHA_PLANT,               name = "Piranha Plant" },
    { behavior = id_bhvBubba,                     model = E_MODEL_BUBBA,                       name = "Bubba" },
    { behavior = id_bhvKickableBoard,             model = E_MODEL_WF_KICKABLE_BOARD,           name = "Kickable Board" },
    { behavior = id_bhvFlame,                     model = E_MODEL_BLUE_FLAME,                  name = "Flame" },
    { behavior = id_bhvBowlingBall,               model = E_MODEL_BOWLING_BALL,                name = "Bowling Ball" },
    {name = "METALLIC_BALL", model = E_MODEL_METALLIC_BALL, behavior = id_bhvStaticObject},
    { behavior = id_bhvClamShell,                 model = E_MODEL_CLAM_SHELL,                  name = "Clam Shell" },
    { behavior = id_bhvDonutPlatform,             model = E_MODEL_RR_DONUT_PLATFORM,           name = "Donut Platform" },
    { behavior = id_bhvEnemyLakitu,               model = E_MODEL_LAKITU,                      name = "Lakitu" },
}

-- Per-player data (local only)
local playerData = {}

function init_player_data(m)
    if not playerData[m.playerIndex] then
        playerData[m.playerIndex] = {
            -- timer = math.random(20 * 30, 60 * 30),   -- random between 20-60 seconds
            timer = 40 * 30,
            active = true
        }
    end
end

function update_random_objects()
    local m = gMarioStates[0]  -- only the local player

    init_player_data(m)

    local data = playerData[m.playerIndex]
    if not data.active then return end

    data.timer = data.timer - 1

    if data.timer <= 0 then
        local obj_index = math.random(1, #randomObjects)
        local name = randomObjects[obj_index].name

        -- Spawn visible to EVERYONE (as you wanted)
        spawn_sync_object(
            randomObjects[obj_index].behavior,
            randomObjects[obj_index].model,
            m.pos.x,
            m.pos.y,
            m.pos.z,
            nil
        )

        -- Popup (only you see it)
        if name:sub(#name) == "s" then
            djui_popup_create("Spawned \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        elseif vowels[name:sub(1,1)] then
            djui_popup_create("Spawned an \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        else
            djui_popup_create("Spawned a \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        end

        -- Reset timer
        data.timer = 40 * 30
    end
end

function hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)

    local m = gMarioStates[0]
    init_player_data(m)
    local data = playerData[m.playerIndex]

    local text = "Your next object in " .. tostring(math.floor(data.timer * 10 / 30) / 10) .. "s"

    local scale = 0.3
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale
    local x = (screenWidth - width) / 2.0
    local y = 0

    djui_hud_set_color(0, 0, 0, 200)
    djui_hud_render_rect(x - 3.75, y, width + 8, 10)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, x, y, scale)
end

-- Hooks
-- hook_event(HOOK_MARIO_UPDATE, update_player)
hook_event(HOOK_UPDATE, update_random_objects)
hook_event(HOOK_ON_HUD_RENDER, hud_render)

-- Optional: command to toggle for yourself
function random_objects_command(msg)
    msg = string.lower(msg or "")
    local m = gMarioStates[0]
    init_player_data(m)

    if msg == "off" then
        playerData[m.playerIndex].active = false
        djui_chat_message_create("Your personal random objects \\#FF0000\\disabled\\#d5d5d5\\.")
        return true
    elseif msg == "on" then
        playerData[m.playerIndex].active = true
        -- playerData[m.playerIndex].timer = math.random(20 * 30, 60 * 30)
        playerData[m.playerIndex].timer = 40 * 30
        djui_chat_message_create("Your personal random objects \\#00FF00\\enabled\\#d5d5d5\\.")
        return true
    end
end

-- hook_chat_command("random_objects", "[on|off]", random_objects_command)
random_objects_command("on")

