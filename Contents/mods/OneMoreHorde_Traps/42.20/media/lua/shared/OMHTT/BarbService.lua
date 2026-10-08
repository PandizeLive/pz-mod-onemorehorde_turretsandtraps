local B = require("OMHTT/BarbSections")
local S = require("OMHTT/BarbSupport")
local Service = {}

---@param item InventoryItem Tool
---@return boolean usable
---@nodiscard
local function usable(item)
    return item:getCondition() > 0
end

---@param player IsoPlayer Acting player
---@return boolean present
---@nodiscard
function Service.tools(player)
    if player:isBuildCheat() then return true end
    local inventory = player:getInventory()
    return inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usable) ~= nil
        and inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, usable) ~= nil
end

---@param record table Frame marker
---@return IsoGridSquare? square Safe exposed service tile
---@nodiscard
function Service.approach(record)
    local _, host, _, status = B.resolve(record)
    if status ~= "active" then return nil end
    local edge = {}
    if not S.edge(host, record.north, record.side, edge) then return nil end
    if edge.side < 0 then
        if edge.north then
            edge.y = edge.y - 1
        else
            edge.x = edge.x - 1
        end
    end
    return getCell():getGridSquare(edge.x, edge.y, edge.z)
end

---@param player IsoPlayer Acting player
---@param object IsoObject Expected frame
---@param id string Expected identity
---@return table? attachment
---@return table? record
---@nodiscard
function Service.resolve(player, object, id)
    if not B.enabled() or player:isDead() or not Service.tools(player) then return nil end
    local record = B.record(object)
    if not record or record.id ~= id then return nil end
    local frame, _, attachment, status = B.resolve(record)
    if frame ~= object or status ~= "active" then return nil end
    local square = Service.approach(record)
    if not square or player:getZ() ~= record.z or not player:getSquare() then return nil end
    local dx, dy = player:getX() - square:getX() - .5, player:getY() - square:getY() - .5
    if dx * dx + dy * dy > 4 or player:getSquare():isSomethingTo(square) then return nil end
    return attachment, record
end

---@param player IsoPlayer Acting player
---@param object IsoObject Expected frame
---@param id string Expected identity
---@param operation string Repair or Remove
---@return boolean applied
function Service.apply(player, object, id, operation)
    local attachment, record = Service.resolve(player, object, id)
    if not attachment then return false end
    if operation == "Repair" then return S.repair(attachment) end
    if operation ~= "Remove" then return false end
    B.retire(record)
    return true
end

return Service
