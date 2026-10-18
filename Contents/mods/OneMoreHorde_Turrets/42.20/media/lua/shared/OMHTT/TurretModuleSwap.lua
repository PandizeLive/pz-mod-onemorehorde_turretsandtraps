require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTransferAction")
local T = require("OMHTT/Turret")
local Access = require("OMHTT/TurretAccess")
OMHTTTurretModuleSwap = ISBaseTimedAction:derive("OMHTTTurretModuleSwap")
local Swap = OMHTTTurretModuleSwap

---@param object IsoObject Turret
---@return table modules Ordered actual items
function Swap.modules(object)
    local items, found, result, used = object:getContainer():getItems(), {}, {}, {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if T.kind(item) == "module" then
            found[item:getID()] = item
        end
    end
    local state = T.state(object)
    for i = 1, 64 do
        local id = state["moduleSlot" .. i]
        if id and found[id] and not used[id] then
            result[#result + 1], used[id] = found[id], true
        end
    end
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if found[item:getID()] and not used[item:getID()] then
            result[#result + 1] = item
        end
    end
    return result
end

---@return boolean valid
function Swap:isValid()
    if self.done or not Access.near(self.character, self.object, self.id) then return false end
    local storage = self.object:getContainer()
    if not self.item or not self.replaced or self.item == self.replaced
        or T.kind(self.item) ~= "module" or T.kind(self.replaced) ~= "module"
        or self.replaced:getContainer() ~= storage or not storage:contains(self.replaced) then return false end
    local source = self.item:getContainer()
    if not source or not source:contains(self.item) then return false end
    if source == storage then return true end
    local controller = require("OMHTT/ControlAccess").stockpile(self.character, self.object, self.controller)
    if not source:isInCharacterInventory(self.character) and (not controller or source ~= controller:getContainer()) then return false end
    if self.item:isFavorite() or self.replaced:isFavorite() or not source:isRemoveItemAllowed(self.item)
        or not storage:isRemoveItemAllowed(self.replaced) then return false end
    if source:getType() == "OMHTTController" then
        if not require("OMHTT/ControlDefinitions").storable(self.replaced) then return false end
        if source:getCapacityWeight() - self.item:getUnequippedWeight() + self.replaced:getUnequippedWeight() > 500 then return false end
    else
        if not source:isItemAllowed(self.replaced) then return false end
        if self.replaced:getUnequippedWeight() > self.item:getUnequippedWeight()
            and not source:hasRoomFor(self.character, self.replaced) then return false end
    end
    local summary = T.contents(storage)
    local role = T.role(self.replaced:getFullType())
    summary.modules = summary.modules - 1
    summary.moduleCounts[role] = summary.moduleCounts[role] - 1
    if summary.moduleCounts[role] == 0 then
        summary.moduleCounts[role] = nil
    end
    return T.accepts(storage, self.item, summary)
end

---@return nil
function Swap:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function Swap:stop()
    self.done = true
    ISBaseTimedAction.stop(self)
end

---@return boolean completed
function Swap:complete()
    if isClient() or not self:isValid() then return false end
    local storage, source = self.object:getContainer(), self.item:getContainer()
    local order = Swap.modules(self.object)
    local same = source == storage
    if not same then
        source:Remove(self.item)
        storage:Remove(self.replaced)
        if storage:AddItem(self.item) ~= self.item then
            source:AddItem(self.item)
            storage:AddItem(self.replaced)
            return false
        end
        if source:AddItem(self.replaced) ~= self.replaced then
            storage:Remove(self.item)
            source:AddItem(self.item)
            storage:AddItem(self.replaced)
            return false
        end
        ISTransferAction:removeItemOnCharacter(self.character, self.item)
        local head = T.contents(storage).head
        if self.replaced:getFullType() == T.TYPES.Void then
            require("OMHTT/TurretFeed").cancel(head)
        end
        if require("OMHTT/Firearms").profile(head) then
            require("OMHTT/FirearmFeed").restore(head, T.cycleConfig(T.contents(storage)).magazine, self.character, false)
        end
        if isServer() then
            sendRemoveItemFromContainer(source, self.item)
            sendRemoveItemFromContainer(storage, self.replaced)
            sendAddItemToContainer(storage, self.item)
            sendAddItemToContainer(source, self.replaced)
            require("OMHTT/TurretItemState").publish(self.item, self.character)
            require("OMHTT/TurretItemState").publish(self.replaced, self.character)
            if head then
                require("OMHTT/TurretItemState").publish(head, self.character)
            end
        end
    end
    local state = T.state(self.object)
    for i = 1, 64 do
        local item = order[i]
        if item == self.replaced then
            item = self.item
        elseif same and item == self.item then
            item = self.replaced
        end
        state["moduleSlot" .. i] = item and item:getID() or nil
    end
    state.transferRevision = (state.transferRevision or 0) + 1
    self.done = true
    require("OMHTT/TurretWorld").refresh(self.object)
    if isServer() then
        require("OMHTT/TurretAuthority").publish(self.object)
    end
    return true
end

---@return nil
function Swap:perform()
    ISBaseTimedAction.perform(self)
end

---@param character IsoPlayer Authenticated operator
---@param object IsoObject Exact turret
---@param item InventoryItem Incoming module
---@param replaced InventoryItem Exact outgoing module
---@param id string Expected turret identity
---@param controller IsoObject? Authorized stockpile endpoint
---@return OMHTTTurretModuleSwap action
function Swap:new(character, object, item, replaced, id, controller)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.item, o.replaced, o.id, o.controller = object, item, replaced, id, controller
    o.stopOnWalk, o.stopOnRun, o.maxTime = true, true, 10
    return o
end

return Swap
