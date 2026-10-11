if isClient() or isServer() then
    return
end
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local Barbs = require("OMHTT/BarbSections")
local Movement = require("OMHTT/BarbMovement")
local crossings = {}

---@param player IsoPlayer Player landing on a bed
---@return nil
local function injureFall(player)
    if player:isGodMod() then return end
    local parts = {BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R, BodyPartType.ForeArm_L, BodyPartType.ForeArm_R}
    local part = player:getBodyDamage():getBodyPart(parts[ZombRand(#parts) + 1])
    part:setCut(true, true)
end

---@param player IsoPlayer Updated local player
---@return nil
function B.player(player)
    local square = player:getSquare()
    local id = nil
    local index = player:getPlayerNum()
    if player:isNoClip() or player:isGhostMode() or player:isDead() then
        player:setVariable("OMHTTBedBrush", false)
        crossings[index] = nil
        return
    end
    if B.enabled() and square then
        id = B.tiles[F.key(square:getX(), square:getY(), square:getZ())]
    end
    local barb = Barbs.contact(player)
    local touching = id ~= nil or barb ~= nil
    local traversing = Movement.traversing(player)
    if barb then Movement.apply(player, Barbs.option("MovementDivisor", 2, 1, 10)) end
    local down = player:isOnFloor()
    local state = crossings[index]
    if not state then
        state = {down = down}
        crossings[index] = state
    end
    player:setVariable("OMHTTBedBrush", touching and player:isPlayerMoving() and not down and not traversing)
    if down and not state.down and touching then injureFall(player) end
    local sprinting = player:isSprinting()
    if touching and not state.touching and not down and not traversing and (sprinting or state.sprinting)
        and not player:isGodMod() and ZombRand(100) < B.option("SprintTripChance", 20, 0, 100) then
        player:setVariable("BumpDone", false)
        player:clearVariable("BumpFallType")
        player:setBumpType("OMHTTBedTrip")
        player:setBumpFall(true)
        player:reportEvent("wasBumped")
    end
    if touching and not state.touching and not down and not traversing and (player:isRunning() or sprinting)
        and not player:isGodMod() and ZombRand(100) < B.option("ScratchChance", 20, 0, 100) then
        local leg = BodyPartType.LowerLeg_L
        if ZombRand(2) == 1 then
            leg = BodyPartType.LowerLeg_R
        end
        player:getBodyDamage():getBodyPart(leg):setScratched(true, true)
    end
    state.touching, state.down, state.sprinting = touching, down, sprinting
end

Events.OnPlayerUpdate.Add(B.player)
