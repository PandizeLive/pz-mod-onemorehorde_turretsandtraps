if isClient() or isServer() then
    return
end
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local crossings = {}

---@param player IsoPlayer Updated local player
---@return nil
function B.player(player)
    local square = player:getSquare()
    local id = nil
    if B.enabled() and square and not player:isDead() then
        id = B.tiles[F.key(square:getX(), square:getY(), square:getZ())]
    end
    local index = player:getPlayerNum()
    player:setVariable("OMHTTBedBrush", id ~= nil and player:isPlayerMoving())
    if id ~= crossings[index] and id and (player:isRunning() or player:isSprinting())
        and not player:isGodMod() and ZombRand(100) < B.option("ScratchChance", 20, 0, 100) then
        local leg = BodyPartType.LowerLeg_L
        if ZombRand(2) == 1 then
            leg = BodyPartType.LowerLeg_R
        end
        player:getBodyDamage():getBodyPart(leg):setScratched(true, true)
    end
    crossings[index] = id
end

Events.OnPlayerUpdate.Add(B.player)
