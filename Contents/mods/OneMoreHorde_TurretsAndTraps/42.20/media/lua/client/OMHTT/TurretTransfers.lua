if isClient() or isServer() then return end
require("TimedActions/ISInventoryTransferAction")
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local G = require("OMHTT/Firearms")
local X = {}
local nativeValid = ISInventoryTransferAction.isValid
local nativeTransfer = ISInventoryTransferAction.transferItem

---@param player IsoPlayer Operator
---@param container ItemContainer Storage
---@return boolean reachable
function X.reachable(player, container)
    if not T.isContainer(container) then return true end
    if container:getContainingItem() then return true end
    local parent = container:getParent()
    if not T.state(parent) then return container:isInCharacterInventory(player) end
    return require("OMHTT/TurretWorld").near(player, parent)
end

---@param player IsoPlayer Operator
---@param item InventoryItem Exact item
---@param source ItemContainer Source
---@param destination ItemContainer Destination
---@return string? reason
function X.rejection(player, item, source, destination)
    if not source or not destination or item:getContainer() ~= source then return "TransferMissing" end
    if not X.reachable(player, source) or not X.reachable(player, destination) then return "TransferReach" end
    if not T.canRemove(source, item) then
        if T.kind(item) == "capacity" then return "CapacityFull" end
        return "Servicing"
    end
    if T.isContainer(destination) then
        T.configure(destination)
        if item:isFavorite() and not destination:isInCharacterInventory(player) then return "TransferFavorite" end
        if not T.kind(item) then
            if instanceof(item, "HandWeapon") and item:isRanged() then return "UnsupportedFirearm" end
            return "TransferWrongItem"
        end
        local component = T.component(item:getFullType())
        if T.SINGLE[component] and T.contents(destination).moduleCounts[component] then return "ModuleDoesNotStack" end
        if T.kind(item) == "ammo" then
            local head = T.contents(destination).head
            local gun = require("OMHTT/Firearms")
            local ammoType = "Base.Potato"
            if gun.profile(head) then ammoType = gun.ammoType(head) end
            if head and item:getFullType() ~= ammoType then return "WrongAmmo" end
        end
        if T.kind(item) == "ammo" and not T.contents(destination).head then return "NoHead" end
        if not T.accept(destination, item) then return "TransferFull" end
    end
    if not source:isRemoveItemAllowed(item) or not destination:isItemAllowed(item) then return "TransferWrongItem" end
    if not destination:hasRoomFor(player, item) then return "TransferFull" end
    return nil
end

---@return boolean valid
function ISInventoryTransferAction:isValid()
    if self.item and (T.isContainer(self.srcContainer) or T.isContainer(self.destContainer)) then
        local reason = X.rejection(self.character, self.item, self.srcContainer, self.destContainer)
        if reason then
            if self.omhttRejection ~= reason then
                D.emit("turret-transfer-rejected", {itemId = self.item:getID(), reason = reason, stage = "validate"})
                self.omhttRejection = reason
            end
            return false
        end
    end
    return nativeValid(self)
end

---@param item InventoryItem Transferred item
---@return nil
function ISInventoryTransferAction:transferItem(item)
    local source, destination = self.srcContainer, self.destContainer
    if not T.isContainer(source) and not T.isContainer(destination) then nativeTransfer(self, item); return end
    local reason = X.rejection(self.character, item, source, destination)
    if reason then
        D.emit("turret-transfer-rejected", {itemId = item:getID(), reason = reason})
        return
    end
    if G.profile(item) then G.cancelLoading(item) end
    nativeTransfer(self, item)
    if T.kind(item) == "head" and destination:contains(item) and T.state(source:getParent()) then
        local object = source:getParent()
        require("OMHTT/TurretAim").entries[object] = nil
        local search = require("OMHTT/TurretSearch")
        if search.pending[object] then search.pending[object].cancelled = true end
    end
    local W = require("OMHTT/TurretWorld")
    for i = 1, 2 do
        local container = source
        if i == 2 then container = destination end
        if T.isContainer(container) then
            T.configure(container)
            T.cycle(T.contents(container), getTimestampMs())
        end
        if T.state(container:getParent()) then W.refresh(container:getParent()) end
    end
    D.emit("turret-transfer", {item = item:getFullType(), itemId = item:getID(),
        source = source:getType(), destination = destination:getType(), moved = destination:contains(item)})
end

---@return boolean merge
local function separateTransfer()
    return false
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Turret
---@param items table Exact items
---@param incoming boolean Into turret
---@param kind string Slot type
---@return number queued
---@return string? reason Last rejection
function X.queue(player, object, items, incoming, kind)
    if not require("OMHTT/TurretWorld").near(player, object) then return 0, "TransferReach" end
    local storage = object:getContainer()
    local destination = player:getInventory()
    if incoming then destination = storage end
    local contents = T.contents(storage)
    local counts = {head = contents.heads, battery = contents.batteries, ammo = contents.reserveAll + (G.profile(contents.head) and G.loaded(contents.head) or 0), module = contents.modules, capacity = contents.capacities}
    local stats = T.cycleConfig(contents)
    local limits = {head = 1, battery = 1, ammo = stats.ammo, module = stats.modules, capacity = 1}
    local pending = {}
    local components = contents.moduleCounts
    local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
    for i = 1, #queue do
        local action = queue[i]
        if action.omhttManaged and action.item and action.item:getContainer() == action.srcContainer then
            pending[action.item] = true
            if action.destContainer == storage then
                local itemKind = T.kind(action.item)
                if itemKind then counts[itemKind] = counts[itemKind] + 1 end
                local component = T.component(action.item:getFullType())
                if component then components[component] = (components[component] or 0) + 1 end
            end
        end
    end
    local queued, reason = 0, nil
    for i = 1, #items do
        local item = items[i]
        local source = item:getContainer()
        local failure = X.rejection(player, item, source, destination)
        if T.kind(item) ~= kind then failure = "TransferWrongItem" end
        if incoming and (not source or not source:isInCharacterInventory(player)) then failure = "TransferCarried" end
        if not incoming and source ~= storage then failure = "TransferMissing" end
        if incoming and counts[kind] >= limits[kind] then failure = "TransferFull" end
        local component = T.component(item:getFullType())
        if incoming and T.SINGLE[component] and components[component] then failure = "ModuleDoesNotStack" end
        if pending[item] then failure = "TransferPending" end
        if failure then
            reason = failure
        else
            local action = ISInventoryTransferAction:new(player, item, source, destination)
            action.omhttManaged = true
            action.canMergeAction = separateTransfer
            ISTimedActionQueue.add(action)
            pending[item] = true
            if incoming then
                counts[kind] = counts[kind] + 1
                if component then components[component] = (components[component] or 0) + 1 end
            end
            queued = queued + 1
        end
    end
    D.emit("turret-manage-transfer", {id = T.state(object).id, incoming = incoming, kind = kind,
        requested = #items, queued = queued, reason = reason or "OK"})
    return queued, reason
end

return X
