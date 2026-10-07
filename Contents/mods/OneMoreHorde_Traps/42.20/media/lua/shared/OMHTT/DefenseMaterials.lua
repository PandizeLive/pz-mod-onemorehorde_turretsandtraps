local M = {}

---@param item InventoryItem Candidate hammer
---@return boolean usable
---@nodiscard
local function usableHammer(item)
    return item:getCondition() > 0
end

---@param player IsoPlayer Builder
---@return table? materials Exact materials and retained hammer
---@nodiscard
function M.reinforcement(player)
    if isClient() or isServer() or player:isDead() then return nil end
    if player:isBuildCheat() then return {items = {}, cheat = true} end
    if player:getPerkLevel(Perks.Woodwork) < 3 then return nil end
    local inventory = player:getInventory()
    local hammer = inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usableHammer)
    if not hammer then return nil end
    local planks = inventory:getSomeTypeRecurse("Base.Plank", 2)
    local nails = inventory:getSomeTypeRecurse("Base.Nails", 8)
    if planks:size() < 2 or nails:size() < 8 then return nil end
    local items = {planks:get(0), planks:get(1)}
    for i = 0, 7 do items[#items + 1] = nails:get(i) end
    return {items = items, hammer = hammer, cheat = false}
end

return M
