if isClient() or isServer() then return end
require("BuildingObjects/ISBuildingObject")
require("BuildingObjects/ISBuildIsoEntity")
require("ISUI/ISInventoryPaneContextMenu")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local I = {}

---@param item InventoryItem Selected packed turret
---@param player IsoPlayer Builder
---@return boolean carried
---@nodiscard
function I.carried(item, player)
    return item and item:getFullType() == T.BASE and item:getContainer()
        and item:getContainer():isInCharacterInventory(player) and not item:getModData().OMHTTDeployed
end

---@param item InventoryItem Selected packed turret
---@param player IsoPlayer Builder
---@return ISBuildIsoEntity? cursor
function I.install(item, player)
    if not T.enabled() or not I.carried(item, player) then return nil end
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    local containers = ISInventoryPaneContextMenu.getContainers(player)
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    local logic = cursor.buildPanelLogic
    logic:setManualSelectInputs(true)
    if not logic:offerInputItem(item) then return nil end
    local input = info:getRecipe():getCraftRecipe():getInputs():get(0)
    if logic:getRecipeData():getFirstManualInputFor(input) ~= item then return nil end
    local valid = cursor.isValid
    ---@param self ISBuildIsoEntity Cursor
    ---@param square IsoGridSquare Destination
    ---@param north boolean Orientation
    ---@return boolean valid
    cursor.isValid = function(self, square, north)
        if not I.carried(item, player) then return false end
        return valid(self, square, north)
    end
    cursor.dragNilAfterPlace = true
    getCell():setDrag(cursor, player:getPlayerNum())
    D.emit("turret-install-preview", {itemId = item:getID(), cheat = player:isBuildCheat(), items = item:getInventory():getItems():size()})
    return cursor
end

---@param index number Player index
---@param context ISContextMenu Menu
---@param selection table Selected inventory entries
---@return nil
function I.menu(index, context, selection)
    if not T.enabled() then return end
    local player = getSpecificPlayer(index)
    if not player or player:isDead() then return end
    local seen = {}
    for i = 1, #selection do
        local entry = selection[i]
        local item = entry
        if type(entry) == "table" and entry.items then item = entry.items[1] end
        if item and not seen[item] and I.carried(item, player) then
            context:addOption(getText("UI_OMHTT_ManageInstall"), item, I.install, player)
            seen[item] = true
            return
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(I.menu)
return I
