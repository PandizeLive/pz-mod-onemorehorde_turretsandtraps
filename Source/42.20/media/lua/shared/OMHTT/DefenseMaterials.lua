local M = {}

---@param item InventoryItem Candidate hammer
---@return boolean usable
---@nodiscard
local function usableHammer(item)
    return item:getCondition() > 0
end

---@param player IsoPlayer Builder
---@param planksNeeded number? One for a bed tile; two for a barrier
---@return table? materials Exact materials and retained hammer
---@nodiscard
function M.reinforcement(player, planksNeeded)
    planksNeeded = planksNeeded or 2
    local nailsNeeded = planksNeeded * 4
    if not player or player:isDead() then return nil end
    if player:isBuildCheat() then return {items = {}, cheat = true} end
    if player:getPerkLevel(Perks.Woodwork) < 3 then return nil end
    local inventory = player:getInventory()
    local hammer = inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usableHammer)
    if not hammer then return nil end
    local planks = inventory:getSomeTypeRecurse("Base.Plank", planksNeeded)
    local nails = inventory:getSomeTypeRecurse("Base.Nails", nailsNeeded)
    if planks:size() < planksNeeded or nails:size() < nailsNeeded then return nil end
    local items = {}
    for i = 0, planksNeeded - 1 do items[#items + 1] = planks:get(i) end
    for i = 0, nailsNeeded - 1 do items[#items + 1] = nails:get(i) end
    return {items = items, hammer = hammer, cheat = false}
end

return M
