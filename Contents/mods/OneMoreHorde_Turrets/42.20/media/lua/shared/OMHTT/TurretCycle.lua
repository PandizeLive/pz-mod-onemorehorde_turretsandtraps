local Clock = require("OMHTT/TurretClock")
local Impact = require("OMHTT/TurretImpactCycle")
local C = {}

---@param state table Persisted head cycle
---@param ammo number Actual rounds, including loaded rounds
---@param config table Magazine, reload and cooldown tuning
---@param now number Real-time milliseconds
---@return string status
function C.update(state, ammo, config, now)
    Clock.restore(state, now)
    if state.nextShot and state.cooldownDuration and state.cooldownDuration ~= config.cooldown and state.nextShot > now then
        state.nextShot = now + math.min(1, (state.nextShot - now) / state.cooldownDuration) * config.cooldown
    end
    state.cooldownDuration = config.cooldown
    if state.reloadReady and state.reloadDuration and state.reloadDuration > 0
        and state.reloadDuration ~= config.reload and state.reloadReady > now then
        state.reloadReady = now + math.min(1, (state.reloadReady - now) / state.reloadDuration) * config.reload
    end
    state.reloadDuration = config.reload
    -- Repair pre-0.2.51 transfer deadlines written with wall time after a pause.
    -- A pending operation can never legitimately exceed its full duration.
    if state.reloadReady then state.reloadReady = math.min(state.reloadReady, now + config.reload) end
    if state.nextShot then state.nextShot = math.min(state.nextShot, now + config.cooldown) end
    local capacity = math.max(1, math.floor(config.magazine))
    state.loaded = math.max(0, math.min(state.loaded or 0, math.min(capacity, ammo)))
    Impact.observe(state, state.loaded)
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
        Impact.observe(state, state.loaded)
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
---@param spent number? Actual whole rounds charged
function C.consume(state, remaining, config, now, spent)
    Impact.consume(state)
    state.loaded = math.max(0, state.loaded - (spent or math.min(state.loaded, 1 + (config.splitter or 0))))
    state.nextShot = now + config.cooldown
    state.cooldownDuration = config.cooldown
    C.update(state, remaining, config, now)
end

return C
