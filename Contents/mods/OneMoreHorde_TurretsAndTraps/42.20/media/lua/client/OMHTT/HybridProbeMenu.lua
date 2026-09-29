if isClient() or isServer() then return end
local F = require("OMHTT/Foundation")
local H = require("OMHTT/HybridProbe")

---@param square IsoGridSquare Saved test fixture
---@param player IsoPlayer Operator
---@return nil
local function remove(square, player)
    H.remove(player, square)
end

---@param playerIndex number Local player
---@param context ISContextMenu Context
---@param objects table Picked objects
---@param test boolean Probe call
---@return nil
local function menu(playerIndex, context, objects, test)
    local player = getSpecificPlayer(playerIndex)
    if test or not F.canUse(player) then return end
    local x = math.floor(IsoUtils.XToIso(getMouseXScaled(), getMouseYScaled(), math.floor(player:getZ())))
    local y = math.floor(IsoUtils.YToIso(getMouseXScaled(), getMouseYScaled(), math.floor(player:getZ())))
    local square = getCell():getGridSquare(x, y, math.floor(player:getZ()))
    for i = 1, #objects do
        if objects[i]:getModData().OMHTTHybridProbe then
            square = objects[i]:getSquare()
            break
        end
        if instanceof(objects[i], "IsoWorldInventoryObject") and objects[i]:getItem():getModData().OMHTTHybridProbe then
            square = objects[i]:getSquare()
            break
        end
    end
    if not H.allowed(player, square) then return end
    local base = H.find(square)
    if not base then return end
    context:addOption(getText("ContextMenu_OMHTT_HybridRemove"), square, remove, player)

end


Events.OnFillWorldObjectContextMenu.Add(menu)
