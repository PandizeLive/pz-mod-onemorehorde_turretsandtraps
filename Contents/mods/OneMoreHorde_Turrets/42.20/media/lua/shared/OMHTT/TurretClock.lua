local C = {}
local session = tostring(getTimestampMs())
local now, previous = nil, nil

---@return number milliseconds Active real time
---@nodiscard
function C.now()
    if now == nil then return getTimestampMs() end
    return now
end

---@return nil
function C.tick()
    local wall = getTimestampMs()
    if now == nil then now = wall end
    if previous and not GameTime.isGamePaused() then
        now = now + math.min(100, math.max(0, wall - previous))
    end
    previous = wall
end

---@param state table Persisted cycle
---@param time number Active time
---@return nil
function C.restore(state, time)
    if state.clockSession ~= session then
        if state.clockAt then
            local shift = time - state.clockAt
            for _, key in pairs({"nextShot", "reloadReady", "rackReady"}) do
                if state[key] and state[key] > state.clockAt then state[key] = state[key] + shift end
            end
        end
        state.clockSession = session
    end
    state.clockAt = time
end

Events.OnTick.Add(C.tick)
return C
