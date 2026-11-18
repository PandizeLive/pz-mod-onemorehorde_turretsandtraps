local C = {}

---@param storage ItemContainer Turret container
---@param contents table Current contents
---@param stats table Effective tuning
---@return number limit Physical count limit for selected ammunition
---@return number free Available native weight
function C.limit(storage, contents, stats)
    local free = math.max(0, storage:getCapacity() - storage:getCapacityWeight())
    local loaded = 0
    if stats.firearm then loaded = require("OMHTT/Firearms").loaded(contents.head) end
    local limit = math.max(0, stats.ammo - loaded)
    return limit, free
end

return C
