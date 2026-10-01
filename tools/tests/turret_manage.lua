local open = require("OMHTT/TurretManage")
local W = require("OMHTT/TurretWorld")
local T = require("OMHTT/Turret")
local X = require("OMHTT/TurretTransfers")
local originalNear, originalPower, originalFire, originalRefresh = W.near, W.power, W.fire, W.refresh
local originalPerform = ISBaseTimedAction.perform
local originalWalk, originalQueue = luautils.walkAdjObject, ISTimedActionQueue.add
local originalManager = getTextManager
local reachable, queued, fired, completed = true, nil, 0, false
local actions = {}
W.near = function() return reachable end
W.power = function() return {kind = "battery"} end
W.fire = function() fired = fired + 1; return "NoTarget" end
W.refresh = function() end
ISBaseTimedAction.perform = function() completed = true end
luautils.walkAdjObject = function(player, object, diagonal) check(not diagonal, "Manage uses cardinal native adjacent path"); return reachable end
ISTimedActionQueue.add = function(action) queued = action; actions[#actions + 1] = action end
ISTimedActionQueue.getTimedActionQueue = function() return {queue = actions} end
getTextManager = function() return {MeasureStringX = function() return 300 end, getFontHeight = function() return 18 end} end
function getPlayerScreenLeft() return 0 end
function getPlayerScreenTop() return 0 end
function getPlayerScreenWidth() return 1280 end
function getPlayerScreenHeight() return 720 end
function isMouseButtonDown() return true end
local inventory = {setVisible = function() error("Manage must not change inventory visibility") end, setPinned = function() error("Manage must not pin inventory") end}
function getPlayerInventory() return inventory end
function getPlayerLoot() error("Dedicated Manage must never open or select the loot page") end
local nextId = 3000
local function item(fullType)
    nextId = nextId + 1
    local result = {kind = "InventoryItem", fullType = fullType, id = nextId, charge = 0.37, condition = 100, data = {}}
    function result:getFullType() return self.fullType end
    function result:getDisplayName() return self.fullType end
    function result:getID() return self.id end
    function result:getCondition() return self.condition end
    function result:getCurrentUsesFloat() return self.charge end
    function result:getModData() return self.data end
    function result:getActualWeight() return 1 end
    function result:getContainer() return self.container end
    function result:isFavorite() return self.favorite == true end
    return result
end
local function container(carried)
    local result = {items = {}, carried = carried, kind = carried and "inventory" or T.CONTAINER, room = true}
    function result:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
    function result:getType() return self.kind end
    function result:getContainingItem() return nil end
    function result:getParent() return self.parent end
    function result:isInCharacterInventory() return self.carried end
    function result:contains(item)
        for i = 1, #self.items do if self.items[i] == item then return true end end
        return false
    end
    function result:AddItem(item) self.items[#self.items + 1] = item; item.container = self end
    function result:Remove(item)
        for i = #self.items, 1, -1 do if self.items[i] == item then table.remove(self.items, i) end end
        item.container = nil
    end
    function result:isRemoveItemAllowed() return true end
    function result:isItemAllowed(item) return self.carried or T.accept(self, item) end
    function result:hasRoomFor() return self.room end
    function result:setType(value) self.kind = value end
    function result:setCapacity() end
    function result:setAcceptItemFunction() end
    function result:setExplored() end
    return result
end
local carried, storage = container(true), container(false)
local player = {getPlayerNum = function() return 0 end, getInventory = function() return carried end}
local controlState = {OMHTTTurret = {schema = 1, id = "manage-test"}}
local object = {getContainer = function() return storage end, hasModData = function() return true end,
    getHealth = function() return 100 end, getMaxHealth = function() return 100 end,
    getModData = function() return controlState end}
storage.parent = object
open(object, player)
check(queued and queued:isValid(), "Manage queues a reach-validated action")
queued:perform()
check(completed and not inventory.visible and not inventory.pinned, "Manage leaves both inventory windows untouched")
local panel = testTurretPanel
panel:prerender()
check(not panel.fireButton.enabled and panel.status == "NoHead", "Empty base cannot fire")
check(#panel.slots == 14 and panel.height <= 720 and panel.x >= 0, "Dedicated slots and controls fit 1280x720")
for i = 1, #panel.slots do panel.slots[i]:prerender() end
panel:fire()
check(fired == 1 and panel.result == getText("UI_OMHTT_ManageNoTarget"), "Manual fire uses existing validation")
actions = {}
local head, battery, potato = item(T.HEAD), item("Base.CarBattery1"), item("Base.Potato")
carried:AddItem(head); carried:AddItem(battery); carried:AddItem(potato)
local count, reason = X.queue(player, object, {potato}, true, "ammo")
check(count == 0 and reason == "NoHead", "Ammo requires installed head")
count, reason = X.queue(player, object, {head, head}, true, "head")
check(count == 1 and reason == "TransferPending" and carried:contains(head), "Queue does not move or duplicate actual head")
check(not actions[1]:canMergeAction(actions[1]), "UI batch retains per-item validation and reservation")
check(actions[1]:isValid(), "Queued head validates")
actions[1]:transferItem(head)
check(storage:contains(head) and not carried:contains(head), "Same exact head moves once")
local head2 = item(T.HEAD); carried:AddItem(head2)
count = X.queue(player, object, {head2}, true, "head")
check(count == 0, "Second head rejected")
actions = {}
count = X.queue(player, object, {battery}, true, "battery")
check(count == 1, "Battery transfer queues")
actions[1]:transferItem(battery)
check(storage:contains(battery) and battery.charge == 0.37, "Exact battery retains charge")
actions = {}
local oldCapacity = SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = 2
local potato2, potato3 = item("Base.Potato"), item("Base.Potato")
carried:AddItem(potato2); carried:AddItem(potato3)
count, reason = X.queue(player, object, {potato, potato2, potato3}, true, "ammo")
check(count == 2 and reason == "TransferFull", "Oversized batch queues only free ammo capacity")
count = X.queue(player, object, {potato3}, true, "ammo")
check(count == 0, "Pending batch reserves remaining capacity")
for i = 1, #actions do actions[i]:transferItem(actions[i].item) end
check(T.contents(storage).ammo == 2 and carried:contains(potato3), "Excess ammo stays carried")
count, reason = X.queue(player, object, {head}, false, "head")
check(count == 0 and reason == "UnloadFirst", "Loaded head cannot be removed")
local invalid = item("Base.Plank"); carried:AddItem(invalid)
count, reason = X.queue(player, object, {invalid}, true, "ammo")
check(count == 0, "Wrong items never enter turret")
potato3.favorite = true
check(X.rejection(player, potato3, carried, storage) == "TransferFavorite", "Favorite protection remains")
potato3.favorite = false
panel:refresh()
check(#panel.ammoSlot.items == 2 and panel.batterySlot.items[1] == battery, "Slots expose actual container items")
local flattened = ISInventoryPane.getActualItems({{items = {potato3, potato3, invalid}}, potato3})
check(#flattened == 2 and flattened[1] == potato3 and flattened[2] == invalid, "Native stack expansion excludes display duplicate and repeated selected child")
ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {invalid}, {onMouseUp = function() end}
panel.ammoSlot:onMouseUp(1, 1)
check(ISMouseDrag.dragging == nil and carried:contains(invalid), "Rejected drag clears without moving item")
panel.headSlot:onMouseDown(1, 1)
check(ISMouseDrag.dragging == nil, "Loaded head cannot start drag out")
actions = {}
panel:unload()
check(#actions == 2 and T.contents(storage).ammo == 2, "Unload uses timed actions, not direct removal")
for i = 1, #actions do actions[i]:transferItem(actions[i].item) end
check(T.contents(storage).ammo == 0 and carried:contains(potato), "Unload retains exact potatoes")
check(X.rejection(player, head, storage, carried) == nil, "Empty head can be removed")
carried.room = false
check(X.rejection(player, head, storage, carried) == "TransferFull", "Full player inventory blocks removal")
carried.room = true
panel:refresh()
panel.batterySlot:onMouseDown(1, 1)
check(ISMouseDrag.dragging[1] == battery and ISMouseDrag.draggingFocus == panel.batterySlot, "Drag out exposes exact battery to native inventory")
local oldSpecific, oldCore, oldShift, oldControl = getSpecificPlayer, getCore, isShiftKeyDown, isCtrlKeyDown
getSpecificPlayer = function() return player end
getCore = function() return {getGameMode = function() return "Sandbox" end} end
isShiftKeyDown = function() return true end
isCtrlKeyDown = function() return false end
luautils.walkToContainer = function() return true end
carried.isInside = function() return false end
local handedOff
local nativePane = {player = 0, inventory = carried, canPutIn = function() return true end,
    transferItemsByWeight = function(_, items, destination) handedOff = items; check(destination == carried, "Native drop targets player inventory") end}
inventory.inventoryPane = nativePane
getPlayerLoot = function() return {inventoryPane = {}} end
ISInventoryPane.onMouseUp(nativePane, 1, 1)
check(handedOff and #handedOff == 1 and handedOff[1] == battery and ISMouseDrag.dragging == nil,
    "Installed vanilla drop handler accepts exact battery and calls slot cleanup")
getSpecificPlayer, getCore, isShiftKeyDown, isCtrlKeyDown = oldSpecific, oldCore, oldShift, oldControl
panel:toggleAuto(); panel:refresh()
check(controlState.OMHTTTurret.automatic == false and panel.autoButton.title == getText("UI_OMHTT_AutoOff"), "Manage switch persists automatic off")
panel:toggleAuto(); panel:refresh()
check(controlState.OMHTTTurret.automatic == true, "Manage can reenable automation")
check(not panel.priorityButton.enabled, "Priority control requires Filter")
local filter = item("Base.OMHTTModuleFilter")
storage:AddItem(filter); panel:refresh()
check(panel.priorityButton.enabled, "Installing Filter enables priority control")
panel:changePriority()
check(controlState.OMHTTTurret.priority == "Furthest", "Filter cycles to Furthest")
panel:changePriority(); panel:changePriority()
check(controlState.OMHTTTurret.priority == "Toughest", "Filter exposes all four target priorities")
storage:Remove(filter); panel:refresh()
check(not panel.priorityButton.enabled and panel.priorityButton.title == getText("UI_OMHTT_Priority", getText("UI_OMHTT_PriorityClosest")), "Removing Filter uses Closest while retaining chosen preference")
local oldModules = SandboxVars.OMHTurretsTraps.PotatoModuleCapacity
SandboxVars.OMHTurretsTraps.PotatoModuleCapacity = 20
for i = 1, 20 do storage:AddItem(item("Base.OMHTTModuleRange")) end
panel:refresh()
check(panel.rows == 4, "High capacity uses additional scrollable rows")
panel:scrollModules(1); panel:scrollModules(1); panel:refresh()
check(#panel.moduleSlots[10].items == 1 and panel.moduleRow == 2, "Twentieth module stays accessible")
SandboxVars.OMHTurretsTraps.PotatoModuleCapacity = 4
panel:refresh()
check(panel.rows == 4, "Lowered capacity preserves access to stored modules")
check(panel.moduleSlots[4].disabled, "Over-capacity slots still allow recovery but not deposits")
ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {invalid}, {onMouseUp = function() end}
panel.moduleSlots[4]:onMouseUp(1, 1)
check(panel.reason == getText("UI_OMHTT_ManageTransferFull"), "Locked slot explains rejected deposit")
local expansion = item("Base.OMHTTExpansionKitMedium")
carried:AddItem(expansion)
actions = {}
count = X.queue(player, object, {expansion}, true, "capacity")
check(count == 1, "Dedicated capacity slot works when ordinary module slots are full")
actions[1]:transferItem(expansion)
panel:refresh()
check(panel.capacitySlot.items[1] == expansion and panel.stats.modules == 8 and panel.stats.ammo == 102,
    "Capacity slot displays exact component and expanded limits")
check(X.rejection(player, expansion, storage, carried) == "CapacityFull", "Expanded modules block capacity removal with useful reason")
local secondExpansion = item("Base.OMHTTExpansionKitMedium")
carried:AddItem(secondExpansion)
check(X.rejection(player, secondExpansion, carried, storage) == "TransferFull", "Second capacity cannot recursively expand storage")
for i = #storage.items, 1, -1 do
    if T.kind(storage.items[i]) == "module" then storage:Remove(storage.items[i]) end
end
check(X.rejection(player, expansion, storage, carried) == nil, "Capacity can be removed after excess modules are withdrawn")
for i = 1, 3 do storage:AddItem(item("Base.Potato")) end
check(not T.canRemove(storage, expansion), "Expanded ammunition blocks capacity removal")
expansion.condition = 0
check(T.canRemove(storage, expansion) and not T.accept(storage, potato3), "Broken capacity preserves excess contents and allows recovery, never further loading")
expansion.condition = 100
local removal = ISInventoryTransferAction:new(player, expansion, storage, carried)
removal:transferItem(expansion)
check(storage:contains(expansion), "Commit rechecks over-capacity removal")
reachable = false
local action = ISInventoryTransferAction:new(player, battery, storage, carried)
check(not action:isValid(), "Native outgoing drag revalidates turret reach")
action:transferItem(battery)
check(storage:contains(battery), "Commit guard blocks stale queued transfer")
panel:prerender()
check(panel.removed, "Manage closes when object becomes unreachable")
queued = nil
open(object, player)
check(queued == nil, "Failed approach cannot open distant inventory")
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = oldCapacity
SandboxVars.OMHTurretsTraps.PotatoModuleCapacity = oldModules
W.near, W.power, W.fire, W.refresh, ISBaseTimedAction.perform = originalNear, originalPower, originalFire, originalRefresh, originalPerform
luautils.walkAdjObject, ISTimedActionQueue.add, getTextManager, ISPanel = originalWalk, originalQueue, originalManager, testTurretOldPanel
