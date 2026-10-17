require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTransferAction")
local A = require("OMHTT/ControlAccess")
OMHTTControlTransferAction = ISBaseTimedAction:derive("OMHTTControlTransferAction")
local Action = OMHTTControlTransferAction

---@return ItemContainer? destination
function Action:destination()
    if self.incoming then return self.object:getContainer() end
    if self.destinationBag == nil then return self.character:getInventory() end
    if not self.destinationBag or not instanceof(self.destinationBag, "InventoryContainer") then return nil end
    local source = self.destinationBag:getContainer()
    if not source or not source:contains(self.destinationBag) or not source:isInCharacterInventory(self.character) then return nil end
    return self.destinationBag:getInventory()
end

---@param character IsoPlayer Operator
---@param object IsoObject Controller
---@param item InventoryItem Exact carried item
---@return boolean allowed
function Action.canStore(character, object, item)
    local state = A.state(object)
    local source = item and item:getContainer()
    return state ~= nil and state.kind == "Controller" and A.near(character, object) and A.write(character, state)
        and require("OMHTT/ControlDefinitions").storable(item)
        and source ~= nil and source:contains(item) and source:isRemoveItemAllowed(item)
        and source:isInCharacterInventory(character) and not item:isFavorite()
        and object:getContainer():getCapacityWeight() + item:getUnequippedWeight() <= 500
end

---@return boolean valid
function Action:isValid()
    local state = A.state(self.object)
    if self.done or self.cancelled or type(self.incoming) ~= "boolean" or not state or state.kind ~= "Controller" or state.id ~= self.id
        or not A.near(self.character, self.object) or not A.write(self.character, state) or not self.item then return false end
    local source, storage = self.item:getContainer(), self.object:getContainer()
    if not source or not source:contains(self.item) or not source:isRemoveItemAllowed(self.item) then return false end
    if self.incoming then
        return Action.canStore(self.character, self.object, self.item)
    end
    local destination = self:destination()
    return source == storage and destination ~= nil and destination ~= storage
        and destination:isItemAllowed(self.item) and destination:hasRoomFor(self.character, self.item)
end

---@return boolean complete
function Action:complete()
    if isClient() or not self:isValid() then return false end
    local source = self.item:getContainer()
    local destination = self:destination()
    source:Remove(self.item)
    if destination:AddItem(self.item) ~= self.item then
        source:AddItem(self.item)
        return false
    end
    self.done = true
    if self.incoming then
        ISTransferAction:removeItemOnCharacter(self.character, self.item)
    end
    if self.incoming and self.item:getFullType() == "Base.Battery" then
        local world = require("OMHTT/ControlWorld")
        world.batteries[self.object] = self.item
        world.state(self.object).batteryId = self.item:getID()
    end
    if isServer() then
        sendRemoveItemFromContainer(source, self.item)
        sendAddItemToContainer(destination, self.item)
    end
    return true
end

---@return nil
function Action:perform()
    if not isServer() and self.onCompleteFunc then
        require("OMHTT/ControlTransferCallbacks").complete(self)
    end
    ISBaseTimedAction.perform(self)
end

---@return nil
function Action:stop()
    self.cancelled = true
    ISBaseTimedAction.stop(self)
end

---@return number duration
function Action:getDuration()
    return 5
end

---@param character IsoPlayer Operator
---@param object IsoObject Controller
---@param item InventoryItem Exact item
---@param incoming boolean Into stockpile
---@param id string? Expected identity
---@param destinationBag InventoryItem|boolean? Exact carried destination; false rejects unsupported destinations
---@return OMHTTControlTransferAction action
function Action:new(character, object, item, incoming, id, destinationBag)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.item, action.incoming, action.id = object, item, incoming, id
    action.destinationBag = destinationBag
    if not isServer() then
        action.id = id or (A.state(object) and A.state(object).id)
    end
    action.stopOnWalk, action.stopOnRun = true, true
    action.maxTime = action:getDuration()
    return action
end

return Action
