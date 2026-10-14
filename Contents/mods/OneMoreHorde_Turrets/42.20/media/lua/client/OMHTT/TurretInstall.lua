if isServer() then return end
local T = require("OMHTT/Turret")
require("OMHTT/TurretPlacement")
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

---@param player IsoPlayer Builder
---@param reason string Failure category
---@return nil
function I.reject(player, reason)
    D.emit("turret-install-rejected", {reason = reason})
    player:setHaloNote(getText("UI_OMHTT_InstallFailed"), 255, 190, 90, 180)
    return nil
end

---@param item InventoryItem Selected packed turret
---@param player IsoPlayer Builder
---@return ISBuildIsoEntity? cursor
function I.install(item, player)
    D.emit("turret-install-request", {itemId = item:getID(), cheat = player:isBuildCheat()})
    if not T.enabled() or not I.carried(item, player) then return I.reject(player, "not-carried") end
    if not ISBuildIsoEntity then return I.reject(player, "construction-not-ready") end
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    if not info then return I.reject(player, "missing-recipe") end
    local containers = ArrayList.new()
    containers:add(item:getContainer())
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    require("OMHTT/PlacementTiming").apply(cursor)
    local logic = cursor.buildPanelLogic
    logic:setManualSelectInputs(true)
    local input = info:getRecipe():getCraftRecipe():getInputs():get(0)
    if logic:getRecipeData():getFirstManualInputFor(input) ~= item then
        logic:clearManualInputs()
        logic:offerInputItem(item)
    end
    if logic:getRecipeData():getFirstManualInputFor(input) ~= item then return I.reject(player, "input-rejected") end
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
