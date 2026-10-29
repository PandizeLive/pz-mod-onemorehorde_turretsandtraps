local E = require("OMHTT/DefenseEffects")
local N = {}

---@param zombie IsoZombie Victim before native removal
---@param lost number Confirmed native health loss
---@param source string Device identity
---@param kind string Damage family
---@return table? facts Presentation only
function N.capture(zombie, lost, source, kind)
    if not isServer() or lost <= 0 or kind == "splash" then return nil end
    return {x = zombie:getX(), y = zombie:getY(), z = zombie:getZ(), lost = lost,
        id = zombie:getOnlineID(), outfit = zombie:getPersistentOutfitID(), source = source, kind = kind}
end

---@param facts table? Confirmed snapshot
---@return nil
function N.send(facts)
    if not isServer() or not facts then return end
    E.send("OMHTT_DamageView", "Hit", facts)
end

return N
