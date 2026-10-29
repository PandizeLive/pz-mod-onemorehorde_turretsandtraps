if isServer() then return end
local V = require("OMHTT/BarrierView")
local F = require("OMHTT/Foundation")
local C = {}
local actors = setmetatable({}, {__mode = "k"})

---@param zombie IsoZombie Native actor
---@return nil
function C.release(zombie)
    local old = actors[zombie]
    if not old then return end
    if zombie:getVariableString("ThumpType") == "OMHTTBarrierClaw" then
        zombie:setVariable("ThumpType", old.previous)
    end
    zombie:clearVariable("OMHTTBarrierStrike")
    actors[zombie] = nil
end

---@param zombie IsoZombie Locally simulated attacker
---@return nil
function C.update(zombie)
    if not isClient() then return end
    local target = zombie:getThumpTarget()
    if zombie:isRemoteZombie() or zombie:isDead() or zombie:getCurrentStateName() ~= "ThumpState"
        or not target or not F.barrierEnabled() then C.release(zombie); return end
    local record = V.exact(target)
    if not record then C.release(zombie); return end
    local old = actors[zombie]
    if not old or old.id ~= record.id then
        C.release(zombie)
        old = {id = record.id, previous = zombie:getVariableString("ThumpType"), token = "", sequence = 0}
        actors[zombie] = old
        zombie:clearVariable("OMHTTBarrierStrike")
        zombie:setVariable("ThumpType", "OMHTTBarrierClaw")
        return
    end
    local token = zombie:getVariableString("OMHTTBarrierStrike")
    if (token ~= "left" and token ~= "right") or token == old.token then return end
    old.token, old.sequence = token, old.sequence + 1
    local player = zombie:getOwnerPlayer()
    if not player or not player:isLocalPlayer() then return end
    local square = target:getSquare()
    sendClientCommand(player, "OMHTT_BarrierContact", "Strike", {id = zombie:getOnlineID(),
        outfit = require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()), barrier = record.id, x = square:getX(), y = square:getY(), z = square:getZ(),
        index = target:getObjectIndex(), token = token, sequence = old.sequence})
end

Events.OnZombieUpdate.Add(C.update)
Events.OnZombieCreate.Add(C.release)
Events.OnZombieDead.Add(C.release)
return C
