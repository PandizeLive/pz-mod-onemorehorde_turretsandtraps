local I = require("OMHTT/TurretInstall")
local T = require("OMHTT/Turret")
local oldCell, oldPlayer = getCell, getSpecificPlayer
local source = {carried = true, isInCharacterInventory = function(self) return self.carried end}
local data = {}
local item = {getFullType = function() return T.BASE end, getContainer = function() return source end,
    getModData = function() return data end, getID = function() return 123 end,
    getInventory = function() return {getItems = function() return {size = function() return 3 end} end} end}
local player = {containers = {}, getPlayerNum = function() return 0 end, isBuildCheat = function() return false end, isDead = function() return false end}
getSpecificPlayer = function() return player end
local drag
getCell = function() return {setDrag = function(self, cursor, index) drag = cursor; check(index == 0, "Preview assigned to operator") end} end
local option
local context = {addOption = function(self, label, selected, callback, actor) option = {selected, callback, actor} end}
I.menu(0, context, {{items = {item, item}}})
check(option and option[1] == item and option[3] == player, "Install menu preserves selected item identity")
local cursor = option[2](option[1], option[3])
check(cursor == drag and cursor.dragNilAfterPlace and cursor:isValid({}), "Install preview is single-use and cancellable")
check(data.OMHTTDeployed == nil, "Opening/cancelling preview never deploys or consumes item")
source.carried = false
check(not cursor:isValid({}) and not I.install(item, player), "Leaving inventory invalidates exact selected item")
source.carried, data.OMHTTDeployed = true, true
check(not I.install(item, player), "Already-deployed item cannot create second turret")
getCell, getSpecificPlayer = oldCell, oldPlayer
ISBuildIsoEntity, ISInventoryPaneContextMenu, SpriteConfigManager = testInstallOldCursor, testInstallOldMenu, testInstallOldInfo
