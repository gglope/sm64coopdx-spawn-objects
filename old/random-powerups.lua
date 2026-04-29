-- name: Random Powerups
-- description: When time goes to zero a random powerup spawns
-- TODO: Si può aggiungere codice da shrink mario come powerups. Togliere però che non si può dare calcio ecc.

local vowels = {
    ["A"] = true, ["E"] = true, ["I"] = true, ["O"] = true, ["U"] = true
}

local randomObjects = {
    { behavior = id_bhvKoopaShell,      model = E_MODEL_KOOPA_SHELL,                 name = "Shell" },
    { behavior = id_bhvRecoveryHeart,   model = E_MODEL_HEART,                       name = "Recovery Heart" },
    { behavior = id_bhvVanishCap,       model = E_MODEL_TOADS_CAP,                   name = "Vanish Cap" },
    { behavior = id_bhvWingCap,         model = E_MODEL_TOADS_WING_CAP,              name = "Wing Cap" },
    { behavior = id_bhvMetalCap,        model = E_MODEL_TOADS_METAL_CAP,             name = "Metal Cap" },
    {name = "One coin", model = E_MODEL_YELLOW_COIN, behavior = id_bhvOneCoin},
    {name = "Red coin", model = E_MODEL_RED_COIN, behavior = id_bhvRedCoin},
    {name = "Ten coins spawn", model = E_MODEL_YELLOW_COIN, behavior = id_bhvTenCoinsSpawn},
    {name = "Three coins spawn", model = E_MODEL_YELLOW_COIN, behavior = id_bhvThreeCoinsSpawn},
    {name = "Coin formation", behavior = id_bhvCoinFormation, model = E_MODEL_YELLOW_COIN},
    {name = "Moving yellow coin", model = E_MODEL_YELLOW_COIN, behavior = id_bhvMovingYellowCoin},
    {name = "Moving blue coin", model = E_MODEL_BLUE_COIN, behavior = id_bhvMovingBlueCoin},
    { behavior = id_bhvBowserShockWave,     model = E_MODEL_BOWSER_WAVE,         name = "Shockwave" },
    { behavior = id_bhvBobomb,              model = E_MODEL_BOBOMB,              name = "Bob-omb" },
    { behavior = id_bhvFlamethrowerFlame,   model = E_MODEL_RED_FLAME,           name = "Flamethrower Flame" },
    { behavior = id_bhvBouncingFireball,    model = E_MODEL_RED_FLAME,           name = "Bouncing Fireball" },
    { behavior = id_bhvSmallPiranhaFlame,   model = E_MODEL_RED_FLAME,           name = "Piranha Flame" },
    { behavior = id_bhvSnufitBalls,         model = E_MODEL_SNUFIT,              name = "Snufit Bullet" },
    -- { behavior = id_bhvMontyMoleRock,       model = E_MODEL_MONTY_MOLE,          name = "Monty Mole Rock" },
    { behavior = id_bhvBowserFlameSpawn,    model = E_MODEL_BOWSER_FLAMES,       name = "Bowser Flame Spawn" },
    { behavior = id_bhvFireSpitter,         model = E_MODEL_RED_FLAME,           name = "Fire Spitter" },
    { behavior = id_bhvFlame,               model = E_MODEL_RED_FLAME,           name = "Flame" }
}

-- Per-player data (local only)
local playerData = {}

function init_player_data(m)
    if not playerData[m.playerIndex] then
        playerData[m.playerIndex] = {
            timer = math.random(10 * 30, 40 * 30),   -- random between 20-60 seconds
            -- timer = 40 * 30,
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

        -- Spawn visible to EVERYONE
        spawn_sync_object(
            randomObjects[obj_index].behavior,
            randomObjects[obj_index].model,
            m.pos.x + 100 * sins(m.faceAngle.y),
            m.pos.y + 40,
            m.pos.z - 100 + coss(m.faceAngle.y),
            nil
        )

        if name:sub(#name) == "s" then
            djui_popup_create("Spawned \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        elseif vowels[name:sub(1,1)] then
            djui_popup_create("Spawned an \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        else
            djui_popup_create("Spawned a \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
        end

        -- Reset timer
        -- data.timer = 40 * 30
        data.timer = math.random(10 * 30, 40 * 30) -- random between 20-60 seconds
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
        playerData[m.playerIndex].timer = math.random(10 * 30, 40 * 30)
        -- playerData[m.playerIndex].timer = 40 * 30
        djui_chat_message_create("Your personal random objects \\#00FF00\\enabled\\#d5d5d5\\.")
        return true
    end
end

-- hook_chat_command("random_objects", "[on|off]", random_objects_command)
random_objects_command("on")

