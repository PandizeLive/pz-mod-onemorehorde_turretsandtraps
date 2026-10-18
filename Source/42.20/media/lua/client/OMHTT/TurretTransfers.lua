if isClient() or isServer() then return end
require("TimedActions/ISInventoryTransferAction")
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local G = require("OMHTT/Firearms")
local X = {}
local nativeValid = ISInventoryTransferAction.isValid
local nativeTransfer = ISInventoryTransferAction.transferItem
local nativePerform = ISInventoryTransferAction.perform
local nativeMerge = ISInventoryTransferAction.canMergeAction
local nativeCheckQueue = ISInventoryTransferAction.checkQueueList

---@param action ISInventoryTransferAction Candidate
---@return boolean allowed
function ISInventoryTransferAction:canMergeAction(action)
    if action and action.omhttManaged and action.queueList
        and (#action.queueList ~= 1 or #action.queueList[1].items ~= 1) then return false end
    if self.omhttMergeRemaining then
        if self.omhttMergeRemaining <= 0 then return false end
        self.omhttMergeRemaining = self.omhttMergeRemaining - 1
    end
    return nativeMerge(self, action)
end

---@return nil
function ISInventoryTransferAction:checkQueueList()
    local owned = T.isContainer(self.srcContainer) or T.isContainer(self.destContainer)
    if owned then
        local count = 0
        for i = 1, #self.queueList do count = count + #self.queueList[i].items end
        self.omhttMergeRemaining = math.max(0, 20 - count)
    end
    nativeCheckQueue(self)
    self.omhttMergeRemaining = nil
end

---@return nil
function ISInventoryTransferAction:perform()
    if not T.isContainer(self.srcContainer) and not T.isContainer(self.destContainer) then nativePerform(self); return end
    local started = getTimestampMs()
    T.transferSnapshots = {}
    nativePerform(self)
    T.transferSnapshots = nil
    D.measure("transfer-batch-ms", getTimestampMs() - started)
end

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
        if not T.transferSnapshots or not T.transferSnapshots[destination] then T.configure(destination) end
        local contents = T.transferContents(destination)
        if item:isFavorite() and not destination:isInCharacterInventory(player) then return "TransferFavorite" end
        if not T.kind(item) then
            if instanceof(item, "HandWeapon") and item:isRanged() then return "UnsupportedFirearm" end
            return "TransferWrongItem"
        end
        local component = T.role(item:getFullType())
        if T.SINGLE[component] and contents.moduleCounts[component] then return "ModuleDoesNotStack" end
        if T.kind(item) == "ammo" then
            local head = contents.head
            if head and not require("OMHTT/TurretAmmo").accepts(head, item:getFullType()) then return "WrongAmmo" end
        end
        if T.kind(item) == "ammo" and not contents.head then return "NoHead" end
        if not T.accept(destination, item) then return "TransferFull" end
    end
    if not source:isRemoveItemAllowed(item) or not destination:isItemAllowed(item) then return "TransferWrongItem" end
    if not T.isContainer(destination) and not destination:hasRoomFor(player, item) then return "TransferFull" end
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
    if self.item and T.isContainer(self.destContainer) and T.state(self.destContainer:getParent()) then
        return not self.item:getIsCraftingConsumed() and self.srcContainer:isExistYet()
            and not self.destContainer:isInside(self.item)
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
    if T.isContainer(source) and T.kind(item) ~= "ammo" then
        T.transferSnapshots = nil
        local current = T.contents(source)
        local head = current.head
        if head and (item == head or item == current.void) then
            require("OMHTT/TurretFeed").cancel(head)
        end
        if head and G.profile(head) then
            local capacity = T.cycleConfig(current).magazine
            if T.component(item:getFullType()) == "Magazine" and item:getCondition() > 0 then
                current.active.Magazine = math.max(0, (current.active.Magazine or 0) - 1)
                capacity = T.cycleConfig(current).magazine
            end
            if not require("OMHTT/FirearmFeed").restore(head, capacity, self.character, item == head) then return end
        end
    end
    if G.profile(item) then G.cancelLoading(item) end
    nativeTransfer(self, item)
    if item:getContainer() == destination then
        if T.isContainer(source) and T.kind(item) == "battery" then
            require("OMHTT/TurretBattery").detach(item)
        end
        for _, container in pairs({source, destination}) do
            local state = T.state(container:getParent())
            if state then
                state.transferRevision = (state.transferRevision or 0) + 1
            end
        end
    end
    if T.transferSnapshots then
        if T.kind(item) == "ammo" and item:getContainer() == destination then
            for container, summary in pairs(T.transferSnapshots) do
                local delta = container == destination and 1 or -1
                if container == source or container == destination then
                    summary.reserveAll = summary.reserveAll + delta
                    local firearm = G.profile(summary.head)
                    local definition = require("OMHTT/TurretHeads").get(summary.head)
                    local ammoType = firearm and G.ammoType(summary.head) or (definition and definition.ammo or "Base.Potato")
                    if require("OMHTT/TurretAmmo").accepts(summary.head, item:getFullType()) then
                        summary.reserve = summary.reserve + delta
                        summary.ammo = summary.ammo + delta
                        if firearm and summary.reserve < 0 then
                            local feed = require("OMHTT/FirearmFeed")
                            feed.set(summary.head, math.max(0, feed.count(summary.head) + summary.reserve))
                            summary.reserveAll = summary.reserveAll - summary.reserve
                            summary.reserve = 0
                        end
                    end
                end
            end
        else
            T.transferSnapshots[source], T.transferSnapshots[destination] = nil, nil
        end
    end
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
        if T.isContainer(container) and T.kind(item) ~= "ammo" then
            T.configure(container)
            T.cycle(T.contents(container), require("OMHTT/TurretClock").now())
        end
        if T.state(container:getParent()) then W.queueRefresh(container:getParent(), T.kind(item) ~= "ammo") end
    end
    D.count("turret-transfer", 1)
    D.trace("turret-transfer", {item = item:getFullType(), itemId = item:getID(),
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
    local started = getTimestampMs()
    T.transferSnapshots = {}
    local contents = T.transferContents(storage)
    local counts = {head = contents.heads, battery = contents.batteries, ammo = contents.reserveAll + (G.profile(contents.head) and G.loaded(contents.head) or 0), module = contents.modules, capacity = contents.capacities}
    local stats = T.cycleConfig(contents)
    local limits = {head = 1, battery = 1, ammo = stats.ammo, module = stats.modules, capacity = 1}
    local pending = {}
    local components = contents.moduleCounts
    local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
    for i = 1, #queue do
        local action = queue[i]
        if action.srcContainer == storage or action.destContainer == storage then
            local groups = action.queueList or {{items = {action.item}}}
            for g = 1, #groups do
                for j = 1, #groups[g].items do
                    local candidate = groups[g].items[j]
                    if candidate and not pending[candidate] and candidate:getContainer() == action.srcContainer then
                        pending[candidate] = true
                        if action.destContainer == storage then
                            local itemKind = T.kind(candidate)
                            if itemKind then counts[itemKind] = counts[itemKind] + 1 end
                            local component = T.role(candidate:getFullType())
                            if component then components[component] = (components[component] or 0) + 1 end
                        end
                    end
                end
            end
        end
    end
    local queued, reason = 0, nil
    local lastAction
    local validated = {}
    for i = 1, #items do
        local item = items[i]
        local source = item:getContainer()
        local lightAmmo = kind == "ammo" and T.kind(item) == "ammo" and item:getWeight() <= .1
        local typeKey = item:getFullType()
        local failure
        if lightAmmo and source and validated[source] == typeKey then
            if item:isFavorite() and not destination:isInCharacterInventory(player) then failure = "TransferFavorite" end
        else
            failure = X.rejection(player, item, source, destination)
            if lightAmmo and not failure then validated[source] = typeKey end
        end
        if T.kind(item) ~= kind then failure = "TransferWrongItem" end
        if incoming and (not source or not source:isInCharacterInventory(player)) then failure = "TransferCarried" end
        if not incoming and source ~= storage then failure = "TransferMissing" end
        if incoming and counts[kind] >= limits[kind] then failure = "TransferFull" end
        local component = T.role(item:getFullType())
        if incoming and T.SINGLE[component] and components[component] then failure = "ModuleDoesNotStack" end
        if pending[item] then failure = "TransferPending" end
        if failure then
            reason = failure
        else
            local group = lastAction and lastAction.queueList and lastAction.queueList[1]
            if lightAmmo and group and #group.items < 20 and lastAction.srcContainer == source and group.type == typeKey then
                group.items[#group.items + 1] = item
            else
                local action = ISInventoryTransferAction:new(player, item, source, destination)
                action.omhttManaged = true
                if kind ~= "ammo" then action.canMergeAction = separateTransfer end
                ISTimedActionQueue.add(action)
                lastAction = action
            end
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
    T.transferSnapshots = nil
    D.measure("transfer-prepare-ms", getTimestampMs() - started)
    return queued, reason
end

return X
