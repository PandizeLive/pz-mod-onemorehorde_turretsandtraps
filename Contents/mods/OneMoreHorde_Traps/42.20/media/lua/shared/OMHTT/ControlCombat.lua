local Targeting = require("OMHTT/ControlTargeting")
local Horde = require("OMHTT/DefenseHorde")
local C = {}

---@param object IsoObject? Defense
---@return table? source Serializable ownership and launch position
function C.source(object)
    if isClient() or not object then return nil end
    local state = require("OMHTT/ControlWorld").state(object)
    local square = object:getSquare()
    if not state or not square then return nil end
    return {owner = state.owner, id = state.id, x = square:getX(), y = square:getY(), z = square:getZ()}
end

---@param source table? Authoritative source snapshot
---@param player IsoPlayer Victim, including physical collateral
---@return boolean allowed
function C.protected(source, player)
    if isClient() or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return false end
    if not isServer() then return true end
    if not source or type(source.owner) ~= "string" or type(source.x) ~= "number" or type(source.y) ~= "number" then return false end
    local options = getServerOptions()
    if not options:getBoolean("PVP") then return false end
    if NonPvpZone.getNonPvpZone(math.floor(player:getX()), math.floor(player:getY()))
        or NonPvpZone.getNonPvpZone(source.x, source.y) then return false end
    if options:getBoolean("SafetySystem") and player:getSafety():isEnabled() then
        local owner = getPlayerFromUsername(source.owner)
        if not owner or owner:getSafety():isEnabled() then return false end
    end
    return true
end

---@param object IsoObject? Defense
---@param actor IsoMovingObject? Candidate
---@return boolean eligible Deliberate targeting, separate from physical collateral
function C.eligible(object, actor)
    if not actor then return false end
    if instanceof(actor, "IsoZombie") then return Horde.allowed(actor) end
    if not instanceof(actor, "IsoPlayer") or isClient() or not object then return false end
    local W = require("OMHTT/ControlWorld")
    local state = W.state(object)
    local host = state and state.controller and W.records().records[state.controller]
    if Targeting.resolve(state, host) ~= "OtherFactions" or not Targeting.outsider(state, actor) then return false end
    return C.protected(state, actor)
end

return C
