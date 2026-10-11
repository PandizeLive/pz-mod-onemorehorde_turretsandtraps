if isClient() or isServer() then
    return
end
local B = require("OMHTT/BedSpikes")
local S = {}

---@param player IsoPlayer Acting player
---@param object IsoObject Selected part
---@param id string Expected identity
---@return table? record
---@nodiscard
function S.resolve(player, object, id)
    local record = B.record(object)
    if not B.enabled() or player:isDead() or not record or record.id ~= id or #B.parts(record) ~= 1 then return nil end
    local square = object:getSquare()
    if not square or player:getZ() ~= square:getZ() or object:getObjectIndex() < 0 then return nil end
    local dx, dy = player:getX() - square:getX() - 0.5, player:getY() - square:getY() - 0.5
    if dx * dx + dy * dy > 4 or player:getSquare():isSomethingTo(square) then return nil end
    return record
end

---@param player IsoPlayer Acting player
---@param record table Bed record
---@return table? materials
---@nodiscard
function S.materials(player, record)
    if not B.enabled() or record.tier == "reinforced" then return nil end
    return require("OMHTT/DefenseMaterials").reinforcement(player, 1)
end

---@param player IsoPlayer Acting player
---@param object IsoObject Selected part
---@param id string Expected identity
---@param operation string Pickup, Repair or Reinforce
---@return boolean applied
function S.apply(player, object, id, operation)
    local record = S.resolve(player, object, id)
    if not record then return false end
    if operation == "Pickup" then
        local name = record.tier == "reinforced" and "Base.OMHTTReinforcedBedSpikesItem" or "Base.OMHTTBedSpikesItem"
        local item = instanceItem(name)
        if not player:getInventory():hasRoomFor(player, item) then
            player:setHaloNote(getText("UI_OMHTT_PickupNoRoom"), 255, 170, 80, 180)
            return false
        end
        B.retire(record)
        player:getInventory():AddItem(item)
        return true
    elseif operation == "Reinforce" then
        local materials = S.materials(player, record)
        if not materials then return false end
        for i = 1, #materials.items do
            local item = materials.items[i]
            player:removeFromHands(item)
            item:getContainer():Remove(item)
        end
        record.tier = "reinforced"
        record.maxHealth = B.maxHealth(record)
        if not materials.cheat then
            addXp(player, Perks.Woodwork, 15)
        end
    elseif operation ~= "Repair" or record.health >= record.maxHealth then
        return false
    end
    record.health = record.maxHealth
    local parts = B.parts(record)
    for i = 1, #parts do B.configure(record, parts[i]) end
    return true
end

return S
