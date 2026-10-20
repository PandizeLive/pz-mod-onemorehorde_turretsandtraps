local free = {seconds = 10, scrap = 0, tools = "UI_OMHTT_RepairNone"}
local R = {profiles = {
    Barrier = free, Bed = free, Wire = free, Turret = free,
    Controller = free, Button = free, Plate = free,
    Barb = {seconds = 10, scrap = 0, tools = "UI_OMHTT_RepairBarbTools"},
    Poke = {seconds = 10, scrap = 2, tools = "UI_OMHTT_RepairNone"},
}}

---@param player IsoPlayer Operator
---@param kind string Repair profile
---@return table items Eligible materials, capped at the required quantity
function R.materials(player, kind)
    local needed = R.profiles[kind].scrap
    local result = {}
    if needed == 0 then return result end
    local items = player:getInventory():getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == "Base.ScrapMetal" and not item:isFavorite() then
            result[#result + 1] = item
            if #result == needed then return result end
        end
    end
    return result
end

return R
