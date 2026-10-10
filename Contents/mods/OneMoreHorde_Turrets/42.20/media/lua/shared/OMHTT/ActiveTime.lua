local A = {clocks = {}}

---@return table clock Session-local elapsed-time observer
function A.new()
    local clock = {}
    A.clocks[#A.clocks + 1] = clock
    return clock
end

---@param clock table Session-local observer
---@return number elapsed Active milliseconds since last sample
function A.step(clock)
    local wall, paused = getTimestampMs(), GameTime.isGamePaused()
    local elapsed = 0
    if clock.wall and not paused and not clock.paused then elapsed = math.max(0, wall - clock.wall) end
    clock.wall, clock.paused = wall, paused
    return elapsed
end

---@return nil
function A.pause()
    if not GameTime.isGamePaused() then return end
    local wall = getTimestampMs()
    for i = 1, #A.clocks do
        local clock = A.clocks[i]
        clock.wall, clock.paused = wall, true
    end
end

Events.OnTickEvenPaused.Add(A.pause)
return A
