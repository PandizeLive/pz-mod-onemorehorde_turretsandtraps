local open = require("OMHTT/TurretManage")
local W = require("OMHTT/TurretWorld")
local T = require("OMHTT/Turret")
local X = require("OMHTT/TurretTransfers")
local originalNear, originalPower, originalFire, originalRefresh = W.near, W.power, W.fire, W.refresh
local Access = require("OMHTT/TurretAccess")
local originalAccess = Access.near
local originalPerform = ISBaseTimedAction.perform
local originalWalk, originalQueue = luautils.walkAdjObject, ISTimedActionQueue.add
local originalManager = getTextManager
local reachable, queued, fired, completed = true, nil, 0, false
local actions = {}
W.near = function() return reachable end
Access.near = function() return reachable end
W.power = function() return {kind = "battery"} end
W.fire = function() fired = fired + 1; return "NoTarget" end
W.refresh = function() end
ISBaseTimedAction.perform = function() completed = true end
luautils.walkAdjObject = function(player, object, diagonal) check(not diagonal, "Manage uses cardinal native adjacent path"); return reachable end
ISTimedActionQueue.add = function(action) queued = action; actions[#actions + 1] = action end
ISTimedActionQueue.getTimedActionQueue = function() return {queue = actions} end
getTextManager = function() return {WrapText = function(self, font, text, width) return text end, MeasureStringX = function(_, font, text) return #text * 9 end, getFontHeight = function() return 18 end} end
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
    function result:getWeight() return self.weight or 1 end
    function result:getContainer() return self.container end
    function result:getIsCraftingConsumed() return false end
    function result:isFavorite() return self.favorite == true end
    return result
end
local function container(carried)
    local result = {items = {}, carried = carried, kind = carried and "inventory" or T.CONTAINER, room = true}
    function result:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
    function result:getType() return self.kind end
    function result:getContainingItem() return nil end
    function result:getParent() return self.parent end
    function result:isExistYet() return true end
    function result:isInside() return false end
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
    function result:getCapacity() return 100 end
    function result:getCapacityWeight() return T.contents(self).weight end
    function result:setAcceptItemFunction() end
    function result:setExplored() end
    return result
end
local carried, storage = container(true), container(false)
local player = {getPlayerNum = function() return 0 end, getInventory = function() return carried end}
local controlState = {OMHTTTurret = {schema = 1, id = "manage-test"}}
local object = {getObjectIndex = function() return 0 end, getSquare = function() return {} end, getContainer = function() return storage end, hasModData = function() return true end,
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
check(#panel.slots == 22 and panel.height <= 720 and panel.x >= 0, "Sixteen module slots, Void storage and controls fit 1280x720")
require("OMHTT/TurretManageExtras").refresh(panel, {active = {Lure = 1}}, {headKind = "Lobber", minimumRange = 6, range = 18})
check(panel.height + panel.y <= 720 and panel.lureSlider.visible and panel.landingSlider.visible,
    "Lure and Landing Distance remain inside a 720p viewport together")
panel:refresh()
check(panel.ammoSlot.width == panel.voidSlot.width and panel.magazineSlot.y > panel.ammoSlot.y
    and panel.capacitySlot.y == panel.headSlot.y, "Accepted layout keeps equal reserves, Magazine below and Expansion in Equipment")
local originalScreenHeight = getPlayerScreenHeight
getPlayerScreenHeight = function() return 600 end
require("OMHTT/TurretManageExtras").refresh(panel, {active = {Lure = 1}}, {headKind = "Lobber", minimumRange = 6, range = 18})
check(panel.height + panel.y <= 600 and panel.body.scrollHeight == panel.body.contentHeight, "Constrained viewport has no outer scrolling")
local Layout = require("OMHTT/TurretManageLayout")
local titleY, footerY = panel.nameEntry.y, panel.fireButton.y
check(panel.nameEntry.y >= panel.titleHeight and panel.body.y >= panel.nameEntry.y + panel.nameEntry.height + 4
    and not panel.equipmentTab and not panel.modulesTab, "Single-page content preserves the dedicated drag and name bands")
check(panel.headSlot.parent==panel.body and panel.moduleSlots[1].parent==panel.body
    and panel.moduleSlots[1].y>panel.magazineSlot.y+panel.magazineSlot.height, "Equipment, ammunition and modules share one sequential page")
check(panel.moduleGridBottom <= panel.body.height, "All sixteen module slots fit the non-scrolling 600p body: " .. panel.moduleGridBottom .. "/" .. panel.body.height)
local closedHeight=panel.body.contentHeight
panel.moduleLines="Line one\nLine two\nLine three\nLine four"
panel.detailsButton.callback(panel)
check(#panel.detailLines==4 and panel.detailsPage and panel.benefitList.visible,
    "Small viewport shows all Details in an in-menu page, including Module Stats")
local beforeChildY=panel.headSlot:getAbsoluteY()
panel.body:onMouseWheel(20)
check(panel.headSlot:getAbsoluteY()==beforeChildY+panel.body:getYScroll(), "Actual native setScrollChildren function moves slots with section headers")
check(panel.reloadButton.y==panel.loadOrderButton.y and panel.reloadButton.x+panel.reloadButton.width<panel.loadOrderButton.x,
    "Reload and Load Order are adjacent outside magazine contents")
check(panel.body:getYScroll() == 0 and panel.nameEntry.y == titleY and panel.height + panel.y <= 600,
    "Whole-menu wheel never scrolls and expanded Details stays on screen")
panel.body:prerender()
panel.body:render()
check(panel.equipmentBottom==panel.ammunitionBottom and panel.headSlot.x+panel.headSlot.width<panel.ammoSlot.x and panel.ammunitionBottom<panel.modulesY
    and panel.benefitList.y>=panel.headerHeight and panel.detailsButton.y==4,
    "Section backgrounds, slots, benefits and Details have distinct bounds")
panel.detailsButton.callback(panel)
panel.body:setYScroll(0)
local slot=panel.headSlot
local inside={x=slot:getAbsoluteX()+48,y=slot:getAbsoluteY()+panel.lineHeight+10,level=0}
local outside={x=panel.body:getAbsoluteX()+12,y=panel.body:getAbsoluteY()-2,level=0}
testStencil={level=0,points={inside,outside}}
panel.body:prerender()
slot:prerender()
check(inside.level==1 and outside.level==0 and testStencil.level==1,
    "Native-style stencil simulation restores the parent after a slot text clip without leaking above the viewport")
panel.body:render()
check(testStencil.level==0 and inside.level==0, "Body balances the native stencil after its children")
testStencil=nil
local originalMouse=isMouseButtonDown
panel:onMouseDown(20,8)
check(panel.moving and panel.capture, "Title dragging captures the pointer")
isMouseButtonDown=function() return false end
panel:update()
check(not panel.moving and not panel.capture, "Release consumed by a child still ends dragging on update")
panel:onMouseDown(20,8)
panel:onMouseUpOutside(2000,2000)
check(not panel.moving and not panel.capture, "Outside release ends dragging immediately")
isMouseButtonDown=originalMouse
for i = 1, #panel.slots do
    local slot = panel.slots[i]
    check(slot.x >= 8 and slot.x + slot.width <= panel.body.width - 20, "Content slots leave a clear scrollbar gutter")
end
panel.body:prerender()
panel.body:render()
getPlayerScreenHeight = originalScreenHeight
panel:refresh()
getPlayerScreenHeight = function() return 1200 end
Layout.refresh(panel)
local collapsedHeight = panel.height
panel.detailsButton.callback(panel)
check(panel.height > collapsedHeight and not panel.detailsPage and panel.benefitList.visible,
    "Details grows the window vertically on a sufficient viewport")
check(panel.benefitList.y + panel.benefitList.height <= panel.body.height,
    "Expanded Module Stats stays within the body")
panel.detailsButton.callback(panel)
check(not panel.benefitList.visible and panel.height == collapsedHeight, "Collapsing Details hides Module Stats and shrinks window")
getPlayerScreenHeight = originalScreenHeight
Layout.refresh(panel)
local moduleRows = {}
for i = 1, 16 do
    local slot = panel.moduleSlots[i]
    moduleRows[slot.y] = (moduleRows[slot.y] or 0) + 1
end
check(moduleRows[panel.moduleSlots[1].y] == 4 and moduleRows[panel.moduleSlots[5].y] == 6
    and moduleRows[panel.moduleSlots[11].y] == 6, "Module geometry is exactly four/six/six")
check(panel.moduleSlots[1].x > panel.moduleSlots[5].x and panel.moduleSlots[4].x < panel.moduleSlots[10].x,
    "Four-slot first row is centered above the six-slot rows")
check(panel.headSlot.missing and panel.magazineSlot.disabled and not panel.magazineSlot.missing, "Empty base highlights head without inventing a magazine requirement")
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
check(count == 1 and reason == nil, "Head can be recovered while reserve remains")
actions = {}
local invalid = item("Base.Plank"); carried:AddItem(invalid)
count, reason = X.queue(player, object, {invalid}, true, "ammo")
check(count == 0, "Wrong items never enter turret")
potato3.favorite = true
check(X.rejection(player, potato3, carried, storage) == "TransferFavorite", "Favorite protection remains")
potato3.favorite = false
panel:refresh()
check(#panel.ammoSlot.items == 2 and panel.batterySlot.items[1] == battery, "Slots expose actual container items")
check(not panel.headSlot.missing and not panel.batterySlot.missing and not panel.modulesMissing, "Manual turret without automation modules has no missing-module warning")
check(panel.magazineSlot.disabled and not panel.magazineSlot.missing, "Potato uses an internal magazine")
W.power = function() return nil end
panel:refresh()
check(panel.batterySlot.missing, "No usable power highlights the battery")
W.power = function() return {kind = "external"} end
panel:refresh()
check(not panel.batterySlot.missing, "External power clears the battery warning")
W.power = function() return {kind = "battery"} end
local flattened = ISInventoryPane.getActualItems({{items = {potato3, potato3, invalid}}, potato3})
check(#flattened == 2 and flattened[1] == potato3 and flattened[2] == invalid, "Native stack expansion excludes display duplicate and repeated selected child")
ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {invalid}, {onMouseUp = function() end}
panel.ammoSlot:onMouseUp(1, 1)
check(ISMouseDrag.dragging == nil and carried:contains(invalid), "Rejected drag clears without moving item")
panel.headSlot:onMouseDown(1, 1)
check(ISMouseDrag.dragging[1] == head, "Head drag keeps actual identity despite reserve")
panel.headSlot:clearDrag()
actions = {}
panel:transfer(panel.ammoSlot.items, false, "ammo")
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
panel:togglePower(); panel:refresh()
check(controlState.OMHTTTurret.powered == false and panel.powerButton.tooltip == getText("UI_OMHTT_PowerOff") and panel.powerButton.backgroundColor.r > panel.powerButton.backgroundColor.g, "Manage switch persists automatic off")
panel:togglePower(); panel:refresh()
check(controlState.OMHTTTurret.powered == true, "Manage can reenable automation")
check(not panel.priorityButton.enabled, "Priority control requires Filter")
actions = {}
local firstDetection, secondDetection = item(T.TYPES.MotionDetection), item(T.TYPES.MotionDetection)
carried:AddItem(firstDetection)
carried:AddItem(secondDetection)
local count, duplicateReason = X.queue(player, object, {firstDetection, secondDetection}, true, "module")
check(count == 1 and duplicateReason == "ModuleDoesNotStack", "Batch rejects duplicate single module before queuing")
actions = {}
carried:Remove(firstDetection)
storage:AddItem(firstDetection)
check(X.rejection(player, secondDetection, carried, storage) == "ModuleDoesNotStack", "Commit rejects duplicate installed module")
check(not T.accept(storage, secondDetection), "Native container filter rejects duplicate module")
secondDetection.fullType = T.TYPES.MotionDetectionImprovised
check(X.rejection(player, secondDetection, carried, storage) == "ModuleDoesNotStack",
    "Improvised Detection shares the standard Detection transfer role")
secondDetection.fullType = T.TYPES.MotionDetection
storage:Remove(firstDetection)
local filter = item("Base.OMHTTModuleFilter")
storage:AddItem(filter); panel:refresh()
check(panel.priorityButton.enabled, "Installing Filter enables priority control")
panel:changePriority()
check(controlState.OMHTTTurret.priority == "Furthest", "Filter cycles to Furthest")
panel:changePriority(); panel:changePriority()
check(controlState.OMHTTTurret.priority == "Toughest", "Filter exposes all four target priorities")
storage:Remove(filter); panel:refresh()
check(not panel.priorityButton.enabled and panel.priorityButton.title == getText("UI_OMHTT_Priority", getText("UI_OMHTT_PriorityRandom")), "Removing Filter uses Random while retaining chosen preference")
local oldModules = SandboxVars.OMHTurretsTraps.PotatoModuleCapacity
SandboxVars.OMHTurretsTraps.PotatoModuleCapacity = 20
for i = 1, 20 do storage:AddItem(item("Base.OMHTTModuleRange")) end
panel:refresh()
check(panel.rows == 4, "High capacity uses additional scrollable rows")
panel:scrollModules(1); panel:scrollModules(1); panel:refresh()
check(#panel.moduleSlots[14].items == 1 and panel.moduleRow == 1, "Twentieth module stays accessible")
SandboxVars.OMHTurretsTraps.PotatoModuleCapacity = 4
panel:refresh()
check(panel.rows == 4, "Lowered capacity preserves access to stored modules")
check(panel.moduleSlots[4].disabled, "Over-capacity slots still allow recovery but not deposits")
ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {invalid}, {onMouseUp = function() end}
panel.moduleSlots[4]:onMouseUp(1, 1)
check(panel.reason == getText("UI_OMHTT_ManageTransferFull"), "Locked slot explains rejected deposit")
local expansion = item("Base.OMHTTModuleExpansionMedium")
carried:AddItem(expansion)
actions = {}
count = X.queue(player, object, {expansion}, true, "capacity")
check(count == 1, "Dedicated capacity slot works when ordinary module slots are full")
actions[1]:transferItem(expansion)
panel:refresh()
check(panel.capacitySlot.items[1] == expansion and panel.stats.modules == 8 and panel.stats.ammo == 652,
    "Capacity slot displays exact component and expanded limits")
check(panel.capacitySlot.disabled, "Expansion is dim only when its excess contents block removal")
check(X.rejection(player, expansion, storage, carried) == "CapacityFull", "Expanded modules block capacity removal with useful reason")
local secondExpansion = item("Base.OMHTTModuleExpansionMedium")
carried:AddItem(secondExpansion)
check(X.rejection(player, secondExpansion, carried, storage) == "TransferFull", "Second capacity cannot recursively expand storage")
for i = #storage.items, 1, -1 do
    if T.kind(storage.items[i]) == "module" then storage:Remove(storage.items[i]) end
end
panel:refresh()
check(not panel.capacitySlot.disabled, "Removable Expansion is visibly enabled")
check(X.rejection(player, expansion, storage, carried) == nil, "Capacity can be removed after excess modules are withdrawn")
for i = 1, 3 do storage:AddItem(item("Base.Potato")) end
check(not T.canRemove(storage, expansion), "Expanded ammunition blocks capacity removal")
expansion.condition = 0
check(T.canRemove(storage, expansion) and not T.accept(storage, potato3), "Broken capacity preserves excess contents and allows recovery, never further loading")
expansion.condition = 100
local removal = ISInventoryTransferAction:new(player, expansion, storage, carried)
removal:transferItem(expansion)
check(storage:contains(expansion), "Commit rechecks over-capacity removal")
-- Real slot interaction with a detachable-magazine head.
local pistol = item("Base.Pistol")
pistol.clip, pistol.ammo = false, 0
function pistol:getMagazineType() return "Base.9mmClip" end
function pistol:getAmmoType() return {getItemKey = function() return "Base.Bullets9mm" end} end
function pistol:getCurrentAmmoCount() return self.ammo end
function pistol:setCurrentAmmoCount(value) self.ammo = value end
function pistol:isContainsClip() return self.clip end
function pistol:setContainsClip(value) self.clip = value end
function pistol:isRoundChambered() return false end
function pistol:isJammed() return false end
function pistol:haveChamber() return true end
function pistol:isRackAfterShoot() return false end
function pistol:getMaxAmmo() return 15 end
function pistol:getMinDamage() return .6 end
function pistol:getMaxDamage() return 1 end
function pistol:isTwoHandWeapon() return false end
function pistol:getProjectileCount() return 1 end
function pistol:getMaxRange() return 15 end
function pistol:getFireMode() return "Single" end
function pistol:getRecoilDelay() return 12 end
    function pistol:getCriticalChance() return 20 end
    function pistol:getCriticalDamageMultiplier() return 4 end
function pistol:getHitChance() return 50 end
function pistol:getAimingPerkHitChanceModifier() return 4 end
storage:Remove(head); storage:AddItem(pistol)
panel:refresh()
check(panel.magazineSlot.missing and not panel.magazineSlot.disabled and panel.status == "NoMagazine", "Pistol exposes missing detachable magazine")
local magazine = item("Base.9mmClip")
function magazine:getCurrentAmmoCount() return 7 end
function magazine:setCurrentAmmoCount(value) self.rounds = value end
carried:AddItem(magazine)
actions = {}
ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {magazine}, {onMouseUp = function() end}
panel.magazineSlot:onMouseUp(1, 1)
check(#actions == 1 and actions[1].magazine == magazine and carried:contains(magazine), "Magazine drop queues service without immediate consumption")
local count, reason = require("OMHTT/TurretMagazineAction").queue(player, object, magazine)
check(count == 0 and reason == "TransferPending", "Duplicate queued magazine service is rejected")
local oldInstance = instanceItem
instanceItem = function(fullType) check(fullType == "Base.9mmClip", "Only matching magazine icon is requested"); return magazine end
pistol.clip, pistol.ammo = true, 7
panel:refresh()
check(not panel.magazineSlot.missing and panel.magazineSlot.items[1] == magazine, "Installed magazine clears warning and shows native ammo state")
ISMouseDrag.dragging = nil
panel.magazineSlot:onMouseDown(1, 1)
check(ISMouseDrag.dragging == nil, "Presentation-only magazine cannot be dragged as a duplicate")
actions = {}
panel.magazineSlot:onRightMouseUp(1, 1)
check(#actions == 1 and actions[1].magazine == nil, "Right-click queues native magazine ejection")
instanceItem = oldInstance
local aim, search = require("OMHTT/TurretAim"), require("OMHTT/TurretSearch")
aim.entries[object], search.pending[object] = {}, {}
local reserveBefore = T.contents(storage).reserveAll
ISInventoryTransferAction:new(player, pistol, storage, carried):transferItem(pistol)
check(carried:contains(pistol) and pistol.ammo == 7 and T.contents(storage).reserveAll == reserveBefore,
    "Removing loaded gun preserves both gun ammunition and stored reserve")
check(aim.entries[object] == nil and search.pending[object].cancelled, "Head removal cancels old aiming and pending manual search")
search.pending[object] = nil
panel.rangeSlider.currentValue = 3
panel:changeRange(3)
check(T.state(object).engagementRange == 3, "Manage selects explicit three-tile engagement cap")
panel:changeRange(panel.rangeMaximum)
check(T.state(object).engagementRange == nil, "Manage Max restores adaptive weapon range")
actions = {}
local bulkStorage, bulkCarried = container(false), container(true)
local bulkObject = {getContainer = function() return bulkStorage end, hasModData = function() return true end,
    getModData = function() return {OMHTTTurret = {schema = 1, id = "bulk-600"}} end}
bulkStorage.parent = bulkObject
local bulkPlayer = {getPlayerNum = function() return 0 end, getInventory = function() return bulkCarried end}
bulkStorage:AddItem(item(T.HEAD))
bulkStorage:AddItem(item(T.TYPES.CapacityLarge))
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = 100
local bulk = {}
for i = 1, 600 do bulk[i] = item("Base.Potato"); bulk[i].weight = .01; bulkCarried:AddItem(bulk[i]) end
local queuedBulk = X.queue(bulkPlayer, bulkObject, bulk, true, "ammo")
check(queuedBulk == 600 and #actions == 30, "All 600 requested rounds are scheduled without direct mutation")
check(#actions[1].queueList[1].items == 20 and not actions[1]:canMergeAction(actions[2]), "Prepared native groups cannot be collapsed and lose their members")
check(X.queue(bulkPlayer, bulkObject, bulk, true, "ammo") == 0, "Duplicate bulk request cannot reserve the same rounds twice")
for first = 1, 600, 20 do
    T.transferSnapshots = {}
    for i = first, first + 19 do
        local batch = actions[math.floor((i - 1) / 20) + 1]
        batch.item = bulk[i]
        check(batch:isValid(), "Each batched item retains validation")
        batch:transferItem(bulk[i])
        check(T.transferContents(bulkStorage).ammo == i, "Snapshot tracks every committed round")
    end
    T.transferSnapshots = nil
    check(T.contents(bulkStorage).ammo == first + 19, "Fresh scan agrees after each batch")
end
check(T.contents(bulkStorage).ammo == 600 and #bulkCarried.items == 0, "600 exact items arrive once")
check(T.transferSnapshots == nil, "No transfer cache survives between callbacks")
local Clock = require("OMHTT/TurretClock")
local oldClock, oldCycle = Clock.now, T.cycle
local observedTime
Clock.now = function() return 12345 end
T.cycle = function(_, time) observedTime = time end
ISInventoryTransferAction:new(player, battery, storage, carried):transferItem(battery)
check(observedTime == 12345, "Component transfer uses pause-aware time, never wall clock")
ISInventoryTransferAction:new(player, battery, carried, storage):transferItem(battery)
Clock.now, T.cycle = oldClock, oldCycle
local OrderPanel = require("OMHTT/TurretLoadOrderPanel")
storage:AddItem(item("Base.OMHTTTurretLobber"))
storage:AddItem(item("Base.PipeBomb"))
storage:AddItem(item("Base.OMHTTAmmoMakeshiftBomb"))
local currentHead = T.contents(storage).head
if currentHead and currentHead:getFullType() ~= "Base.OMHTTTurretLobber" then storage:Remove(currentHead) end
OrderPanel.open(panel)
local orderPanel = panel.orderPanel
check(orderPanel and orderPanel.parent == panel and not panel.body.visible and not panel.nameEntry.visible,
    "Load Order occupies Manage rather than adding a floating window")
local bombGroup
for i = 1, #orderPanel.groups do
    if orderPanel.groups[i].platform == "bomb" then bombGroup = orderPanel.groups[i] end
end
check(bombGroup and #bombGroup.rows == 2, "Explosives share one platform")
for i = 1, #orderPanel.rows do
    if orderPanel.rows[i].type == "Base.PipeBomb" then orderPanel.list.selected = i end
end
orderPanel:move({step = -1})
check(bombGroup.rows[1].type == "Base.PipeBomb", "Load Order moves selected ammo within its own platform")
orderPanel:move({step = -1})
check(bombGroup.rows[1].type == "Base.PipeBomb", "Ammunition cannot cross its platform header")
orderPanel:apply()
check(queued and queued.command == "AmmoPlatformOrder" and queued.value.order == "Base.PipeBomb|Base.OMHTTAmmoMakeshiftBomb",
    "Shared editor queues exact ordered types through the authoritative action")
check(queued:complete() and T.state(object).ammoOrders["@bomb"] == queued.value.order,
    "Load Order Apply persists the platform request")
check(panel.body.visible and panel.nameEntry.visible and not panel.orderPanel, "Apply returns to the intact Manage page")
local LoadOrder = require("OMHTT/TurretLoadOrder")
check(not LoadOrder.validGroup({platform="bomb", previous=queued.value.order, order="Base.Potato"}, T.state(object)),
    "Server rejects cross-platform priority injection")
check(not LoadOrder.validGroup({platform="bomb", previous="", order=queued.value.order}, T.state(object)),
    "Server rejects a stale platform edit")
check(LoadOrder.saved(T.state(object), T.contents(storage).head) == queued.value.order,
    "Live reload selection consumes the platform preference")
OrderPanel.open(panel)
local savedBomb
for i = 1, #panel.orderPanel.groups do
    if panel.orderPanel.groups[i].platform == "bomb" then savedBomb = panel.orderPanel.groups[i] end
end
check(savedBomb.rows[1].type == "Base.PipeBomb", "Reopening Load Order retains saved priority")
panel.orderPanel:close()
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
Access.near = originalAccess
luautils.walkAdjObject, ISTimedActionQueue.add, getTextManager, ISPanel = originalWalk, originalQueue, originalManager, testTurretOldPanel
