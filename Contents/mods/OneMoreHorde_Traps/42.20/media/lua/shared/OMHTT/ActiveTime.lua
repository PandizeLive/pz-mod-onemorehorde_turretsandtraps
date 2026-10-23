local A = {clocks = {}}

---@param simulation boolean? Normalize world time instead of presentation time
---@return table clock Session-local observer
function A.new(simulation)
    local clock = {simulation = simulation == true}
    A.clocks[#A.clocks + 1] = clock
    return clock
end

---@param clock table Observer
---@return number elapsed Milliseconds at normal-speed duration units
function A.step(clock)
    local wall, paused = getTimestampMs(), GameTime.isGamePaused()
    local elapsed = 0
    local game = getGameTime()
    local hours = game:getWorldAgeHours()
    if clock.wall and not paused and not clock.paused then
        if clock.simulation then
            elapsed = math.max(0, hours - clock.hours) * game:getMinutesPerDay() * 2500
        else
            elapsed = math.max(0, wall - clock.wall)
        end
    end
    clock.wall, clock.hours, clock.paused = wall, hours, paused
    return elapsed
end

---@return nil
function A.pause()
    if not GameTime.isGamePaused() then return end
    local wall, hours = getTimestampMs(), getGameTime():getWorldAgeHours()
    for i = 1, #A.clocks do
        local clock = A.clocks[i]
        clock.wall, clock.hours, clock.paused = wall, hours, true
    end
end

Events.OnTickEvenPaused.Add(A.pause)
return A
