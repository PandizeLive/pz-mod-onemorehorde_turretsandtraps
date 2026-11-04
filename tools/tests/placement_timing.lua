local Rules = require("OMHTT/PlacementRules")
local Action = require("OMHTT/PlacementAction")
local oldTime, oldClient, oldServer = getGameTime, isClient, isServer
local player = {faceLocation = function() end}
isClient = function() return false end
isServer = function() return false end
for route, profile in pairs(Rules.routes) do
    for _, speed in pairs({1, 5, 30}) do
        local delta = speed / 60
        getGameTime = function() return {getMultiplier = function() return delta * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end
        local action = Action:new(player, nil, nil, route, 1, 10, 10, 0)
        local finished, ticks = false, 0
        action.forceComplete = function() finished = true end
        action.setJobDelta = function() end
        while not finished and ticks < 400 do action:update(); ticks = ticks + 1 end
        check(math.abs(ticks * delta - profile[2]) <= delta + .001, "Placement duration follows simulation speed: " .. route .. " at " .. speed .. "x")
        isServer = function() return true end
        local server = Action:new(player, nil, nil, route, 1, 10, 10, 0)
        check(server:getDuration() == profile[2] * 50, "Server derives duration from allowlisted family")
        isServer = function() return false end
    end
end
local item = {getContainer = function() return nil end}
check(not Rules.carried(item, player, "Base.OMHTTTrapButton"), "Removed input rejected")
check(not Action:new(player, item, nil, "VanillaRecipe", 1, 10, 10, 0):inputsValid(), "Arbitrary construction route rejected")
local container = {isInCharacterInventory = function() return true end, contains = function() return true end}
item.getContainer = function() return container end
item.getFullType = function() return "Base.OMHTTTrapBedSpikes" end
item.getCondition = function() return 20 end
check(not Action:new(player, item, item, "OMHTTDeployBedSpikes", 1, 10, 10, 0):inputsValid(), "Same item cannot satisfy both Bed tiles")
check(not Action:new(player, item, nil, "OMHTTDeployBedSpikes", 1, 10, 10, 0):inputsValid(), "Paired Bed requires exact companion")
check(Action:new(player, item, nil, "OMHTTDeployBedSpikesSingle", 1, 10, 10, 0):inputsValid(), "Single worn Bed remains placeable")
item.getFullType = function() return "Base.OMHTTTrapBarbedPanel" end
player.isBuildCheat = function() return true end
check(Action:new(player, item, nil, "OMHTTBarbs", 1, 10, 10, 0):inputsValid(), "Native Build Cheat retains tool-free panel placement")
player.isBuildCheat = function() return false end
player.getInventory = function() return {getFirstTagEvalRecurse = function() return nil end} end
check(not Action:new(player, item, nil, "OMHTTBarbs", 1, 10, 10, 0):inputsValid(), "Ordinary panel placement requires tools")
isClient = function() return true end
check(not Action:new(player, item, nil, "OMHTTDeployBedSpikesSingle", 1, 10, 10, 0):complete(), "Client cannot mutate placement")
getGameTime, isClient, isServer = oldTime, oldClient, oldServer
