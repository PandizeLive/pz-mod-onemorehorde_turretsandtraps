local A = {clocks = {}}

---@return boolean paused Native pause or stopped multiplayer simulation clock
function A.paused()
    return GameTime.isGamePaused() or A.zeroRate == true or getGameTime():getTrueMultiplier() <= 0
end

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
    local wall, paused = getTimestampMs(), A.paused()
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
    A.zeroRate = getGameTime():getTrueMultiplier() <= 0
    local stopped = A.paused()
    if A.stopped ~= stopped then
        A.stopped = stopped
        require("OMHTT/Diagnostics").defer("simulation-pause", {paused=stopped,
            native=GameTime.isGamePaused(), multiplier=getGameTime():getTrueMultiplier()}, "traps")
    end
    if not stopped then return end
    local wall, hours = getTimestampMs(), getGameTime():getWorldAgeHours()
    for i = 1, #A.clocks do
        local clock = A.clocks[i]
        clock.wall, clock.hours, clock.paused = wall, hours, true
    end
end

---@return nil Observe after other mods apply their speed control for this tick
function A.install()
    A.zeroRate = false
    Events.OnTickEvenPaused.Remove(A.pause)
    Events.OnTickEvenPaused.Add(A.pause)
end

Events.OnTickEvenPaused.Add(A.pause)
Events.OnGameStart.Add(A.install)
Events.OnServerStarted.Add(A.install)
return A
