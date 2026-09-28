if isClient() then return end
local F = require("OMHTT/Foundation")
local Footprint = require("OMHTT/BarrierFootprint")
local Diagnostics = require("OMHTT/Diagnostics")
local Approach = require("OMHTT/BarrierApproach")
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
    if not Approach.ready(player, record) then return nil end
    Footprint.sync(Footprint.slot(square, id), "service-check")
    return Footprint.exact(object)
end

---@param item InventoryItem Candidate hammer
---@return boolean usable
---@nodiscard
local function usableHammer(item)
    return item:getCondition() > 0
end

---@param player IsoPlayer Builder
---@param record table Existing barrier
---@return table? materials Exact materials, retained hammer and cheat flag
---@nodiscard
function Service.reinforcementMaterials(player, record)
    if isClient() or isServer() or not F.barrierEnabled() or player:isDead() or record.tier == "reinforced" then return nil end
    if player:isBuildCheat() then return {items = {}, cheat = true} end
    if player:getPerkLevel(Perks.Woodwork) < 3 then return nil end
    local inventory = player:getInventory()
    local hammer = inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usableHammer)
    if not hammer then return nil end
    local planks = inventory:getSomeTypeRecurse("Base.Plank", 2)
    local nails = inventory:getSomeTypeRecurse("Base.Nails", 8)
    if planks:size() < 2 or nails:size() < 8 then return nil end
    local items = {planks:get(0), planks:get(1)}
    for i = 0, 7 do
        items[#items + 1] = nails:get(i)
    end
    return {items = items, hammer = hammer, cheat = false}
end

---@param player IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Expected device identity
---@param operation string Pickup, Repair or Reinforce
---@return boolean applied
function Service.apply(player, object, id, operation)
    local record = Service.resolve(player, object, id)
    if not record then
        Diagnostics.emit("barrier-service-rejected", {id = id, action = operation, reason = "Unavailable"})
        return false
    end
    local slot = Footprint.slot(object:getSquare(), id)
    local before = record.condition
    if operation == "Pickup" then
        local kind = "Base.OMHTTSpikeBarrierItem"
        if record.tier == "reinforced" then
            kind = "Base.OMHTTReinforcedBarrierItem"
        end
        local item = instanceItem(kind)
        if not player:getInventory():hasRoomFor(player, item) then
            player:setHaloNote(getText("UI_OMHTT_PickupNoRoom"), 255, 170, 80, 180)
            Diagnostics.emit("barrier-service-rejected", {id = id, action = operation, reason = "InventoryFull"})
            return false
        end
        Footprint.retire(slot)
        player:getInventory():AddItem(item)
    elseif operation == "Repair" then
        if before >= record.maxHealth then return false end
        local parts = Footprint.healthObjects(record)
        for i = 1, #parts do
            parts[i]:setHealth(record.maxHealth)
        end
        record.condition, record.observedLoss = record.maxHealth, 0
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Footprint.sync(slot, "repair")
    elseif operation == "Reinforce" then
        local materials = Service.reinforcementMaterials(player, record)
        if not materials then
            Diagnostics.emit("barrier-service-rejected", {id = id, action = operation, reason = "Requirements"})
            return false
        end
        local missing = record.maxHealth - record.condition
        for i = 1, #materials.items do
            local item = materials.items[i]
            player:removeFromHands(item)
            item:getContainer():Remove(item)
        end
        record.tier = "reinforced"
        record.maxHealth = F.barrierHealth(record)
        record.condition = math.max(1, record.maxHealth - missing)
        record.revision, slot.epoch = record.revision + 1, slot.epoch + 1
        local objects = Footprint.healthObjects(record)
        for i = 1, #objects do
            objects[i]:setMaxHealth(record.maxHealth)
            objects[i]:setHealth(record.condition)
        end
        Footprint.sync(slot, "reinforce")
        if not materials.cheat then
            addXp(player, Perks.Woodwork, 30)
        end
        Diagnostics.emit("barrier-reinforced", {id = id, before = before, after = record.condition,
            max = record.maxHealth, damage = F.barrierDamage(record), consumed = #materials.items,
            xp = materials.cheat and 0 or 30, cheat = materials.cheat})
        return true
    else
        return false
    end
    Diagnostics.emit("barrier-service", {id = id, action = operation, before = before, after = record.maxHealth,
        player = player:getUsername(), items = operation == "Pickup" and 1 or 0, xp = 0})
    return true
end

return Service
