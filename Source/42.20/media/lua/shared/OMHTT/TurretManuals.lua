local M = {}
M.definitions = {
    {key = "ManualBallista", item = "Base.OMHTTManualBallista", recipes = {"OMHTTCraftBallista"}, tier = 3},
    {key = "ManualRotaryBlades", item = "Base.OMHTTManualRotaryBlades", recipes = {"OMHTTCraftRotaryBlades"}, tier = 3},
    {key = "ManualLobber", item = "Base.OMHTTManualLobber", recipes = {"OMHTTCraftLobber", "OMHTTCraftLobberImprovised"}, tier = 4},
    {key = "ManualArc", item = "Base.OMHTTManualArc", recipes = {"OMHTTCraftArc"}, tier = 5},
    {key = "ManualFirearms", item = "Base.OMHTTManualFirearms", recipes = {"OMHTTMountFirearm"}, tier = 4},
}
M.literature = {"LibraryBooks", "BookstoreBlueCollar", "BookstoreScience", "LivingRoomShelf", "MagazineRackMixed"}

---@param item InventoryItem Literature
---@return string? key Catalog identity
function M.key(item)
    local fullType = item:getFullType()
    for i = 1, #M.definitions do
        if fullType == M.definitions[i].item then return M.definitions[i].key end
    end
    return nil
end

---@param player IsoPlayer Operator
---@param item InventoryItem Incoming head
---@return boolean allowed
---@nodiscard
function M.canMount(player, item)
    if not require("OMHTT/Firearms").profile(item) then return true end
    return player:getKnownRecipes():contains("OMHTTMountFirearm")
end

return M
