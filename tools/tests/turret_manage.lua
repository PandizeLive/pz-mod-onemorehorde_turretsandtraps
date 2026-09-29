local open = require("OMHTT/TurretManage")
local W = require("OMHTT/TurretWorld")
local T = require("OMHTT/Turret")
local originalNear, originalPower, originalFire = W.near, W.power, W.fire
local originalPerform = ISBaseTimedAction.perform
local originalWalk, originalQueue = luautils.walkAdjObject, ISTimedActionQueue.add
local originalManager = getTextManager
local reachable, queued, fired, completed = true, nil, 0, false
W.near = function() return reachable end
W.power = function() return {kind = "battery"} end
W.fire = function() fired = fired + 1; return "NoTarget" end
ISBaseTimedAction.perform = function() completed = true end
luautils.walkAdjObject = function(player, object, diagonal) check(not diagonal, "Manage uses cardinal native adjacent path"); return reachable end
ISTimedActionQueue.add = function(action) queued = action end
getTextManager = function() return {MeasureStringX = function() return 300 end} end
function getPlayerScreenLeft() return 0 end
function getPlayerScreenTop() return 0 end
local function page()
    return {setVisible = function(self, value) self.visible = value end, setPinned = function(self) self.pinned = true end,
        refreshBackpacks = function() end, selectButtonForContainer = function(self, value) self.inventory = value end,
        setForceSelectedContainer = function(self, value) self.forced = value end}
end
local inventory, loot = page(), page()
function getPlayerInventory() return inventory end
function getPlayerLoot() return loot end
local player = {getPlayerNum = function() return 0 end}
local storage = {getItems = function() return ArrayList.new() end}
local object = {getContainer = function() return storage end, hasModData = function() return true end,
    getModData = function() return {OMHTTTurret = {schema = 1, id = "manage-test"}} end}
open(object, player)
check(queued and queued:isValid(), "Manage queues a reach-validated action")
queued:perform()
check(completed and loot.inventory == storage and loot.forced == storage and inventory.visible and loot.pinned,
    "Manage opens and selects actual native inventory, then completes action")
testTurretPanel:prerender()
check(not testTurretPanel.fireButton.enabled and testTurretPanel.status == "NoHead", "Empty base cannot fire from panel")
testTurretPanel:fire()
check(fired == 1 and testTurretPanel.result == "NoTarget", "Manage sends manual fire through authoritative world validation")
reachable = false
testTurretPanel:prerender()
check(testTurretPanel.removed, "Manage closes when object becomes unreachable")
queued = nil
open(object, player)
check(queued == nil, "Failed adjacent path cannot open distant inventory")
W.near, W.power, W.fire, ISBaseTimedAction.perform = originalNear, originalPower, originalFire, originalPerform
luautils.walkAdjObject, ISTimedActionQueue.add, getTextManager, ISPanel = originalWalk, originalQueue, originalManager, testTurretOldPanel
