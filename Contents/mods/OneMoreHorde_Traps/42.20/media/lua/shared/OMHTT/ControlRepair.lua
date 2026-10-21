local R = {profiles = {
    Barrier = {seconds = 4, pickup = 2, material = "Base.Plank", tag = "HAMMER", tools = "UI_OMHTT_RepairHammer"},
    Bed = {seconds = 4, pickup = 2, material = "Base.Plank", tag = "HAMMER", tools = "UI_OMHTT_RepairHammer"},
    Wire = {seconds = 4, pickup = 2, material = "Base.ScrapMetal", tag = "PLIERS", tools = "UI_OMHTT_RepairPliers"},
    Barb = {seconds = 4, pickup = 2, material = "Base.ScrapMetal", tag = "PLIERS", tools = "UI_OMHTT_RepairPliers"},
    Poke = {seconds = 4, pickup = 2, material = "Base.ScrapMetal", tag = "WRENCH", tools = "UI_OMHTT_RepairWrench"},
    Tether = {seconds = 4, pickup = 2, material = "Base.ScrapMetal", tag = "PLIERS", tools = "UI_OMHTT_RepairPliers"},
    Turret = {seconds = 10, pickup = 5, material = "Base.ScrapMetal", tag = "WRENCH", tools = "UI_OMHTT_RepairWrench"},
    Controller = {seconds = 10, pickup = 5, material = "Base.ScrapMetal", tag = "SCREWDRIVER", tools = "UI_OMHTT_RepairScrewdriver"},
    Button = {seconds = 2, pickup = 1, tag = "SCREWDRIVER", tools = "UI_OMHTT_RepairScrewdriver"},
    Plate = {seconds = 2, pickup = 1, tag = "SCREWDRIVER", tools = "UI_OMHTT_RepairScrewdriver"},
    Lever = {seconds = 2, pickup = 1, tag = "WRENCH", tools = "UI_OMHTT_RepairWrench"},
}}

---@param item InventoryItem Retained tool
---@return boolean usable
local function usable(item)
    return item:getCondition() > 0
end

---@param player IsoPlayer Operator
---@param kind string Repair profile
---@return boolean present
function R.tools(player, kind)
    local profile = R.profiles[kind]
    return profile ~= nil and player:getInventory():getFirstTagEvalRecurse(ItemTag[profile.tag], usable) ~= nil
end

---@param player IsoPlayer Operator
---@param kind string Repair profile
---@return table items Eligible materials, capped at one
function R.materials(player, kind)
    local result = {}
    local profile = R.profiles[kind]
    if not profile or not profile.material then return result end
    local items = player:getInventory():getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == profile.material and not item:isFavorite() then
            result[1] = item
            return result
        end
    end
    return result
end

---@param player IsoPlayer Operator
---@param kind string Repair profile
---@return boolean ready
function R.ready(player, kind)
    return R.tools(player, kind) and (not R.profiles[kind].material or #R.materials(player, kind) == 1)
end

---@param player IsoPlayer Authoritative operator
---@param kind string Repair profile
---@return boolean consumed Requirements checked again at commit; tools remain
function R.consume(player, kind)
    if isClient() or not R.ready(player, kind) then return false end
    local items = R.materials(player, kind)
    if #items == 0 then return true end
    local item = items[1]
    local source = player:getInventory()
    player:removeFromHands(item)
    source:Remove(item)
    if isServer() then
        sendRemoveItemFromContainer(source, item)
    end
    return true
end

return R
