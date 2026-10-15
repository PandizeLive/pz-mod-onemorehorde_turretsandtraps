local T = require("OMHTT/Turret")
local A = {}

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@param id string? Expected identity
---@return boolean reachable
---@nodiscard
function A.near(player, object, id)
    if not player or player:isDead() or not T.enabled() or not object then return false end
    local state = T.state(object)
    if not state or (id and state.id ~= id) or object:getObjectIndex() < 0 or object:getHealth() <= 0 then return false end
    local square, origin = object:getSquare(), player:getSquare()
    if not square or not origin or origin:getZ() ~= square:getZ() then return false end
    if origin == square then return true end
    if math.abs(origin:getX() - square:getX()) > 1 or math.abs(origin:getY() - square:getY()) > 1 then return false end
    local dx, dy = player:getX() - square:getX() - .5, player:getY() - square:getY() - .5
    return dx * dx + dy * dy <= 4 and origin:canReachTo(square)
end

return A
