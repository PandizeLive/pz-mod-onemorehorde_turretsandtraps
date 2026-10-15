if isServer() then return end
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local Barbs = require("OMHTT/BarbSections")
local P = require("OMHTT/ContactPlayer")
P.trapsRegistered = true
P.barbs = Barbs
require("OMHTT/DefenseMotion").checks.traps = function(zombie, source)
    local barb = Barbs.contact(zombie)
    return barb ~= nil and barb.id == source
end

---@param player IsoPlayer Updated player
---@return nil
function B.player(player)
    if isClient() and not player:isLocalPlayer() then return end
    local square = player:getSquare()
    local id = B.enabled() and square and B.tiles[F.key(square:getX(), square:getY(), square:getZ())] or nil
    local barb = Barbs.contact(player)
    local divisor = Barbs.option("MovementDivisor", 2, 1, 10)
    if not barb and P.tackContact then barb, divisor = P.tackContact(player), 2 end
    P.update(player, id, barb, divisor,
        B.option("SprintTripChance", 20, 0, 100), B.option("ScratchChance", 20, 0, 100))
end

Events.OnPlayerUpdate.Add(B.player)
