local T = require("OMHTT/Turret")
local A = {}

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@param id string? Expected identity
---@return boolean reachable
---@nodiscard
function A.near(player, object, id, read)
    if not player or player:isDead() or not T.enabled() or not object then return false end
    local state = T.state(object)
    if not state or (id and state.id ~= id) or object:getObjectIndex() < 0 or object:getHealth() <= 0 then return false end
    return require("OMHTT/ControlAccess").authorized(player, object, read)
end

return A
