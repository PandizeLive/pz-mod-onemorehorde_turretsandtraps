local C = {}

---@param state table Persisted head cycle
---@param ammo number Actual rounds, including loaded rounds
---@param config table Magazine, reload and cooldown tuning
---@param now number Real-time milliseconds
---@return string status
function C.update(state, ammo, config, now)
    if state.nextShot and state.cooldownDuration and state.cooldownDuration ~= config.cooldown and state.nextShot > now then
        state.nextShot = now + math.min(1, (state.nextShot - now) / state.cooldownDuration) * config.cooldown
    end
    state.cooldownDuration = config.cooldown
    if state.reloadReady and state.reloadDuration and state.reloadDuration > 0
        and state.reloadDuration ~= config.reload and state.reloadReady > now then
        state.reloadReady = now + math.min(1, (state.reloadReady - now) / state.reloadDuration) * config.reload
    end
    state.reloadDuration = config.reload
    local capacity = math.max(1, math.floor(config.magazine))
    state.loaded = math.max(0, math.min(state.loaded or 0, math.min(capacity, ammo)))
    state.nextShot = state.nextShot or 0
    if ammo == 0 then
        state.pending, state.reloadReady = nil, nil
        return "Empty"
    end
    if state.loaded == 0 then
        if not state.reloadReady then
            state.pending = math.min(capacity, ammo)
            state.reloadReady = now + config.reload
        end
        if now < state.reloadReady then return "Reloading" end
        state.loaded = math.min(state.pending, math.min(capacity, ammo))
        state.pending, state.reloadReady = nil, nil
    end
    if now < state.nextShot then return "Cooling" end
    return "Ready"
end

---@param state table Persisted head cycle
---@param remaining number Actual ammo after consuming one item
---@param config table Effective tuning
---@param now number Real-time milliseconds
---@return nil
function C.consume(state, remaining, config, now)
    state.loaded = math.max(0, state.loaded - 1)
    state.nextShot = now + config.cooldown
    state.cooldownDuration = config.cooldown
    C.update(state, remaining, config, now)
end

return C
