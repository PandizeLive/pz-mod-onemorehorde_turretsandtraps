local oldTime = getGameTime
getGameTime = function() return {getTrueMultiplier=function() return 1 end,getMultiplier = function() return (.25) * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end
local player = {faceThisObject = function() end}
local object = {hasModData = function() return true end,
    getModData = function() return {OMHTTTurret = {schema = 1, id = "timing"}} end}
local turret = require("OMHTT/TurretPickupAction")
local control = require("OMHTT/ControlAction")
local oldState = require("OMHTT/ControlAccess").state
require("OMHTT/ControlAccess").state = function() return {kind = "Controller", id = "timing"} end
local actions = {
    {control:new(player, object, "Pickup", nil, nil, "timing"), 5},
    {control:new(player, object, "Repair", nil, nil, "timing"), 10},
    {turret:new(player, object, "Pickup"), 5}, {turret:new(player, object, "Repair"), 10},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Pickup"), 2},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Repair"), 4},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Reinforce"), 10},
    {OMHTTBedServiceAction:new(player, object, "timing", "Pickup"), 2},
    {OMHTTBedServiceAction:new(player, object, "timing", "Repair"), 4},
    {OMHTTBedServiceAction:new(player, object, "timing", "Reinforce"), 10},
    {OMHTTBarbServiceAction:new(player, object, "timing", "Remove"), 2},
    {OMHTTBarbServiceAction:new(player, object, "timing", "Repair"), 4},
}
require("OMHTT/ControlAccess").state = oldState
for i = 1, #actions do
    local action, duration = actions[i][1], actions[i][2]
    action.action = {setJobDelta = function() end, forceComplete = function() action.forced = true end}
    for tick = 1, duration * 4 - 1 do action:update() end
    check(not action.forced and not action:complete(), "Service cannot commit early: " .. (action.operation or action.command))
    action:update()
    check(action.forced, "Service finishes at approved active duration: " .. (action.operation or action.command))
end
getGameTime = oldTime
for _, speed in pairs({1, 5, 30}) do
    getGameTime = function() return {getTrueMultiplier=function() return 1 end,getMultiplier = function() return 48 * speed / 60 end,
        getMultiplierFromTimeDelta = function() return 48 end} end
    local action = turret:new(player, object, "Pickup")
    action.action = {setJobDelta = function() end, forceComplete = function() action.forced = true end}
    local ticks = 0
    while not action.forced and ticks < 400 do action:update(); ticks = ticks + 1 end
    check(math.abs(ticks / 60 * speed - 5) <= speed / 60 + .001,
        "Five-second pickup follows game speed at " .. speed .. "x")
end
getGameTime = oldTime
