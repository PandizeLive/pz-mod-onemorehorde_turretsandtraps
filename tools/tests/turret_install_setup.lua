testInstallOldCursor, testInstallOldMenu, testInstallOldInfo = ISBuildIsoEntity, ISInventoryPaneContextMenu, SpriteConfigManager
local input = {}
local data = {getFirstManualInputFor = function(self) return self.selected end}
local logic = {setManualSelectInputs = function() end, offerInputItem = function(self, item) data.selected = item; return true end,
    getRecipeData = function() return data end}
ISBuildIsoEntity = {new = function(self, player, info, facing, containers)
    check(facing == 1 and containers == player.containers, "Install enters native rotating construction cursor")
    return {buildPanelLogic = logic, isValid = function() return true end}
end}
ISInventoryPaneContextMenu = {getContainers = function(player) return player.containers end}
SpriteConfigManager = {GetObjectInfo = function(name)
    check(name == "OMHTTDeployTurret", "Install uses existing deployment recipe")
    return {getRecipe = function() return {getCraftRecipe = function() return {getInputs = function() return {get = function() return input end} end} end} end}
end}
LuaEventManager.AddEvent("OnFillInventoryObjectContextMenu")
