local oldTime = getGameTime
getGameTime = function() return {getRealworldSecondsSinceLastUpdate = function() return .25 end} end
local player = {faceThisObject = function() end}
local object = {hasModData = function() return true end,
    getModData = function() return {OMHTTTurret = {schema = 1, id = "timing"}} end}
local turret = require("OMHTT/TurretPickupAction")
local actions = {
    {turret:new(player, object, "Pickup"), 5}, {turret:new(player, object, "Repair"), 10},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Pickup"), 5},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Repair"), 10},
    {OMHTTBarrierServiceAction:new(player, object, "timing", "Reinforce"), 10},
    {OMHTTBedServiceAction:new(player, object, "timing", "Pickup"), 5},
    {OMHTTBedServiceAction:new(player, object, "timing", "Repair"), 10},
    {OMHTTBedServiceAction:new(player, object, "timing", "Reinforce"), 10},
    {OMHTTBarbServiceAction:new(player, object, "timing", "Remove"), 5},
    {OMHTTBarbServiceAction:new(player, object, "timing", "Repair"), 10},
}
for i = 1, #actions do
    local action, duration = actions[i][1], actions[i][2]
    action.action = {setJobDelta = function() end, forceComplete = function() action.forced = true end}
    for tick = 1, duration * 4 - 1 do action:update() end
    check(not action.forced and not action:complete(), "Service cannot commit early: " .. action.operation)
    action:update()
    check(action.forced, "Service finishes at approved active duration: " .. action.operation)
end
getGameTime = oldTime
