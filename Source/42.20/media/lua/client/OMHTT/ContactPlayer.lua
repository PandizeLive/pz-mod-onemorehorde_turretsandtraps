if isServer() then
    return
end
local P = {}
local Movement = require("OMHTT/BarbMovement")
local crossings = {}

---@param player IsoPlayer Player landing on a bed
---@return nil
local function injureFall(player, source)
    if player:isGodMod() then return end
    require("OMHTT/DefenseInjury").contact(player, source, "fall")
end

---@param player IsoPlayer Updated local player
---@return nil
function P.update(player, id, barb, divisor, trip, scratch, poke)
    if isClient() and not player:isLocalPlayer() then return end
    local index = player:getPlayerNum()
    if player:isNoClip() or player:isGhostMode() or player:isDead() then
        player:setVariable("OMHTTBedBrush", false)
        crossings[index] = nil
        return
    end
    local touching = id ~= nil or barb ~= nil or poke ~= nil
    local traversing = Movement.traversing(player)
    if barb then Movement.apply(player, divisor) end
    local down = player:isOnFloor()
    local state = crossings[index]
    if not state then
        state = {down = down}
        crossings[index] = state
    end
    player:setVariable("OMHTTBedBrush", touching and player:isPlayerMoving() and not down and not traversing)
    if down and not state.down and touching and not poke then
        injureFall(player, id or (barb and (barb.source or barb.id)))
    end
    local sprinting = player:isSprinting()
    if touching and not state.touching and not down and not traversing and (sprinting or state.sprinting)
        and not player:isGodMod() and ZombRand(100) < trip then
        player:setVariable("BumpDone", false)
        player:clearVariable("BumpFallType")
        player:setBumpType("OMHTTBedTrip")
        player:setBumpFall(true)
        player:reportEvent("wasBumped")
    end
    if touching and not state.touching and not down and not traversing and (player:isRunning() or sprinting)
        and not poke and not player:isGodMod() and ZombRand(100) < scratch then
        require("OMHTT/DefenseInjury").contact(player, id or (barb and (barb.source or barb.id)), "scratch")
    end
    state.touching, state.down, state.sprinting = touching, down, sprinting
end

return P
