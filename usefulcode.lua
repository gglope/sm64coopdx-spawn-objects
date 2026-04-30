-- Removes all doors
hook_event(HOOK_ON_SYNC_VALID, function(type, levelNum, areaIdx, nodeId, arg)
    for _, list in ipairs(lists) do
        local obj = obj_get_first(list)
        while obj ~= nil do
            if
                obj.oInteractType == INTERACT_DOOR
                or obj.oInteractType == INTERACT_WARP
                or obj.oInteractType == INTERACT_WARP_DOOR
            then
                obj_mark_for_deletion(obj)
            end
            obj = obj_get_next(obj)
        end
    end
end)


-- Disables "exit level" and "exit to castle"
hook_event(HOOK_ON_PAUSE_EXIT, function(usedExitToCastle)
    return false
end)


-- warp
hook_event(HOOK_ON_PLAYER_CONNECTED, function(m)
  if m.playerIndex == 0 then
    warp_to_level(TARGET_LEVEL, TARGET_AREA, TARGET_WARP)
  end
end)
hook_event(HOOK_ON_LEVEL_INIT, function(type, levelNum, areaIdx, nodeId, arg)
  if levelNum ~= TARGET_LEVEL then
    warp_to_level(TARGET_LEVEL, TARGET_AREA, TARGET_WARP)
  end
end)

-- 99 lives only when connected, not always
hook_event(HOOK_ON_PLAYER_CONNECTED, function(m)
  if m and m.playerIndex ~= nil then
    m.numLives = 99
  end
end)

-- health always max, stop death 
hook_event(HOOK_MARIO_UPDATE, function(m)
    m.health = 0x880   -- or 0x8FF; both are common "full health" values in SM64 Lua mods
    m.health = 0xFFF

    Invincibility timer (extra safety)
    m.invincTimer = 60

    Optional: instantly cancel any death action and put Mario back into idle
    local deathActions = {
        ACT_DEATH_ON_BACK, ACT_DEATH_ON_STOMACH, ACT_DEATH_PLUNGE,
        ACT_QUICKSAND_DEATH, ACT_SUFFOCATION, ACT_WATER_DEATH,
        ACT_DROWNING, ACT_ELECTROCUTION, ACT_BURNING_JUMP,
        ACT_BURNING_FALL
    }
    for _, act in ipairs(deathActions) do
        if m.action == act then
            set_mario_action(m, ACT_IDLE, 0)
            break
        end
    end
end)

