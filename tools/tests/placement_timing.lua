local P = require("OMHTT/PlacementTiming")
local oldTime = getGameTime
local delta, started, updated, completed = .1, 0, 0, false
getGameTime = function() return {getMultiplier = function() return (delta) * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end
local cursor = {onTimedActionStart = function() started = started + 1 end}
P.apply(cursor)
local action = {character = {isTimedActionInstant = function() return false end},
    action = {setTime = function(_, value) check(value == 480, "Placement resets trait-scaled native duration") end,
        setWaitForFinished = function(_, value) check(value, "Native progress cannot complete placement before the active timer") end,
        forceComplete = function() completed = true end},
    update = function() updated = updated + 1 end,
    setJobDelta = function() end, forceComplete = function() error("BuildLogic must not stop before native perform consumes the selected input") end}
cursor:onTimedActionStart(action)
for i = 1, 49 do action:update() end
check(not completed and started == 1 and updated == 49, "Native placement animation/update survives and cannot finish before five seconds")
action:update(); action:update()
check(completed, "Placement completes after five active seconds")
completed = false
action.update = function() updated = updated + 1 end
cursor:onTimedActionStart(action)
delta = 60
action:update()
check(completed, "Native game-time progress completes after an elapsed fast-forward interval")
local instant = {character = {isTimedActionInstant = function() return true end}}
completed = false
action.update = function() updated = updated + 1 end
cursor:onTimedActionStart(action)
delta = .5
for i = 1, 9 do action:update() end
check(not completed, "Fast-forward placement still requires five game-speed-adjusted seconds")
action:update()
check(completed, "Fast-forward placement completes in ten half-second simulation steps")
cursor:onTimedActionStart(instant)
check(instant.update == nil, "Instant-action debug cheat retains native behavior")
getGameTime = oldTime

for _, seconds in pairs({1, 2, 5}) do
    for _, speed in pairs({1, 5, 30}) do
        completed = false
        delta = speed / 60
        getGameTime = function() return {getMultiplier = function() return delta * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end
        local category = {onTimedActionStart = function() end}
        P.apply(category, seconds)
        action.update = function() end
        category:onTimedActionStart(action)
        local ticks = 0
        while not completed and ticks < 400 do action:update(); ticks = ticks + 1 end
        check(math.abs(ticks * delta - seconds) <= delta + .001,
            "Category placement duration follows simulation speed: " .. seconds .. "s at " .. speed .. "x")
    end
end
getGameTime = oldTime
