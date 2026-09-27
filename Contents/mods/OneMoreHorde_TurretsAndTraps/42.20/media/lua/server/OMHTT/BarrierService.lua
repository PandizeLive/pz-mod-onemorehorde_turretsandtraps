if isClient() then return end
local F = require("OMHTT/Foundation")
local Footprint = require("OMHTT/BarrierFootprint")
local Diagnostics = require("OMHTT/Diagnostics")
local Service = {}

---@param player IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Expected device identity
---@return table? record Complete nearby construction barrier
---@nodiscard
function Service.resolve(player, object, id)
    if isServer() or not F.barrierEnabled() or player:isDead() then return nil end
    local record = Footprint.exact(object)
    if not record or record.id ~= id or record.placementSource ~= "construction" or not Footprint.parts(record) then return nil end
    local square = object:getSquare()
    local dx, dy = player:getX() - square:getX() - 0.5, player:getY() - square:getY() - 0.5
    if math.floor(player:getZ()) ~= square:getZ() or dx * dx + dy * dy > 4 then return nil end
    Footprint.sync(Footprint.slot(square), "service-check")
    return Footprint.exact(object)
end

---@param player IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Expected device identity
---@param operation string Pickup or Repair
---@return boolean applied
function Service.apply(player, object, id, operation)
    local record = Service.resolve(player, object, id)
    if not record then
        Diagnostics.emit("barrier-service-rejected", {id = id, action = operation, reason = "Unavailable"})
        return false
    end
    local slot = Footprint.slot(object:getSquare())
    local before = record.condition
    if operation == "Pickup" then
        local item = instanceItem("Base.OMHTTSpikeBarrierItem")
        if not player:getInventory():hasRoomFor(player, item) then
            player:setHaloNote(getText("UI_OMHTT_PickupNoRoom"), 255, 170, 80, 180)
            Diagnostics.emit("barrier-service-rejected", {id = id, action = operation, reason = "InventoryFull"})
            return false
        end
        Footprint.retire(slot)
        player:getInventory():AddItem(item)
    elseif operation == "Repair" then
        if before >= record.maxHealth then return false end
        local parts = Footprint.parts(record)
        for i = 1, #parts do
            parts[i]:setHealth(record.maxHealth)
        end
        record.condition, record.observedLoss = record.maxHealth, 0
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Footprint.sync(slot, "repair")
    else
        return false
    end
    Diagnostics.emit("barrier-service", {id = id, action = operation, before = before, after = record.maxHealth,
        player = player:getUsername(), items = operation == "Pickup" and 1 or 0, xp = 0})
    return true
end

return Service
