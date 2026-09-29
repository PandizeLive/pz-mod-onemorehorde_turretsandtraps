local C = {}

---@param state table Persisted head cycle
---@param ammo number Actual rounds, including loaded rounds
---@param config table Magazine, reload and cooldown tuning
---@param now number Real-time milliseconds
---@return string status
function C.update(state, ammo, config, now)
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
    C.update(state, remaining, config, now)
end

return C
