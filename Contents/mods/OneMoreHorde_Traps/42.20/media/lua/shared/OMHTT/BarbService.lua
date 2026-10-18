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
---@param record table? Selected hazard
---@return boolean present
---@nodiscard
function Service.tools(player, record)
    if record and record.kind == "wire" then return true end
    if player:isBuildCheat() then return true end
    local inventory = player:getInventory()
    return inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usable) ~= nil
        and inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, usable) ~= nil
end

---@param record table Frame marker
---@param selected IsoObject? Selected wire half
---@return IsoGridSquare? square Safe exposed service tile
---@nodiscard
function Service.approach(record, selected)
    local _, host, _, status = B.resolve(record)
    if status ~= "active" then return nil end
    if record.kind == "wire" then
        if selected and B.record(selected) == record then return selected:getSquare() end
        return host:getSquare()
    end
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
    if not player then return nil end
    local record = B.record(object)
    if not record or record.id ~= id or not B.enabled(record.kind) or player:isDead() or not Service.tools(player, record) then return nil end
    local frame, _, attachment, status = B.resolve(record)
    if status ~= "active" then return nil end
    if frame ~= object and (not record.paired or B.wirePart(record, 1) ~= object) then return nil end
    local square = Service.approach(record, object)
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
    if isClient() then return false end
    local attachment, record = Service.resolve(player, object, id)
    if not attachment then return false end
    if operation == "Repair" then
        if not S.repair(attachment) then return false end
        B.publishWire(record)
        if isServer() and not record.paired then
            local _, host = B.resolve(record)
            if host then
                S.publish(host)
            end
        end
        return true
    end
    if operation ~= "Remove" then return false end
    local recovered = nil
    if record.kind == "wire" then
        recovered = instanceItem("Base.OMHTTTrapConcertinaWire")
        if not player:getInventory():hasRoomFor(player, recovered) then
            player:setHaloNote(getText("UI_OMHTT_PickupNoRoom"))
            return false
        end
    end
    if recovered and player:getInventory():AddItem(recovered) ~= recovered then return false end
    if recovered then
        require("OMHTT/DefenseNames").pack(record, recovered)
    end
    B.retire(record)
    if recovered and isServer() then
        sendAddItemToContainer(player:getInventory(), recovered)
    end
    return true
end

return Service
