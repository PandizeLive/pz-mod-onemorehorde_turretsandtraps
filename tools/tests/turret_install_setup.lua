testInstallOldCursor, testInstallOldMenu, testInstallOldInfo = ISBuildIsoEntity, ISInventoryPaneContextMenu, SpriteConfigManager
local input = {}
local data = {getFirstManualInputFor = function(self) return self.selected end}
local logic = {setManualSelectInputs = function() end, clearManualInputs = function() data.selected = nil end,
    offerInputItem = function(self, item) if data.selected == item then return false end; data.selected = item; return true end,
    getRecipeData = function() return data end}
ISBuildIsoEntity = {new = function(self, player, info, facing, containers)
    check(facing == 1 and containers:size() == 1, "Install enters native rotating construction cursor with selected container")
    return {buildPanelLogic = logic, isValid = function() return true end}
end}
ISInventoryPaneContextMenu = {getContainers = function(player) return player.containers end}
SpriteConfigManager = {GetObjectInfo = function(name)
    check(name == "OMHTTDeployTurret", "Install uses existing deployment recipe")
    return {getRecipe = function() return {getCraftRecipe = function() return {getInputs = function() return {get = function() return input end} end} end} end}
end}
LuaEventManager.AddEvent("OnFillInventoryObjectContextMenu")
