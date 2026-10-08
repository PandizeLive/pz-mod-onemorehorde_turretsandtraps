local P = require("OMHTT/PlacementTiming")
local oldTime = getGameTime
local delta, started, updated, completed = .1, 0, 0, false
getGameTime = function() return {getRealworldSecondsSinceLastUpdate = function() return delta end} end
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
cursor:onTimedActionStart(action)
delta = 60
action:update()
check(not completed and action.OMHTTElapsed <= .5, "Long frame cannot immediately finish placement")
local instant = {character = {isTimedActionInstant = function() return true end}}
cursor:onTimedActionStart(instant)
check(instant.update == nil, "Instant-action debug cheat retains native behavior")
getGameTime = oldTime
