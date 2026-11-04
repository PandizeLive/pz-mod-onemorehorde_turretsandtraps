require('TimedActions/ISBaseTimedAction')
require('TimedActions/ISTransferAction')
local E = require('OMHTT/ControlExpansion')
local A = require('OMHTT/ControlAccess')
OMHTTControlExpansionAction = ISBaseTimedAction:derive('OMHTTControlExpansionAction')
local Action = OMHTTControlExpansionAction

---@return boolean valid
function Action:isValid()
    local state = A.state(self.object)
    if self.done or not state or state.id ~= self.id or state.kind ~= 'Controller'
        or not A.near(self.character, self.object) or not A.write(self.character, state) then return false end
    local storage, inventory = self.object:getContainer(), self.character:getInventory()
    local old = E.item(self.object)
    if old and (old:isFavorite() or not inventory:hasRoomFor(self.character, old)) then return false end
    if self.item then
        local source = self.item:getContainer()
        if E.tier(self.item) == 0 or self.item == old or self.item:isFavorite() or not source
            or not source:contains(self.item) or not source:isRemoveItemAllowed(self.item)
            or (source ~= storage and not source:isInCharacterInventory(self.character)) then return false end
    elseif not old then
        return false
    end
    local weight = storage:getCapacityWeight()
    if old then weight = weight - old:getUnequippedWeight() end
    if self.item and self.item:getContainer() ~= storage then weight = weight + self.item:getUnequippedWeight() end
    return weight <= E.capacity(self.object, E.tier(self.item))
end

---@return boolean complete
function Action:complete()
    if isClient() or not self:isValid() then return false end
    local storage, inventory = self.object:getContainer(), self.character:getInventory()
    local old, source = E.item(self.object), self.item and self.item:getContainer()
    if old then
        storage:Remove(old)
        if inventory:AddItem(old) ~= old then
            storage:AddItem(old)
            return false
        end
    end
    if self.item and source ~= storage then
        source:Remove(self.item)
        if storage:AddItem(self.item) ~= self.item then
            source:AddItem(self.item)
            if old then
                inventory:Remove(old)
                storage:AddItem(old)
            end
            return false
        end
        ISTransferAction:removeItemOnCharacter(self.character, self.item)
    end
    if isServer() then
        if old then
            sendRemoveItemFromContainer(storage, old)
            sendAddItemToContainer(inventory, old)
        end
        if self.item and source ~= storage then
            sendRemoveItemFromContainer(source, self.item)
            sendAddItemToContainer(storage, self.item)
        end
    end
    local W = require('OMHTT/ControlWorld')
    W.state(self.object).expansionId = self.item and self.item:getID() or nil
    E.refresh(self.object)
    W.publish(self.object)
    require("OMHTT/ControlMenuAudio").confirm(self.character)
    self.done = true
    return true
end

---@return number duration
function Action:getDuration()
    return 5
end

---@param character IsoPlayer Operator
---@param object IsoObject Controller
---@param item InventoryItem? Replacement; nil removes
---@param id string? Expected identity
---@return OMHTTControlExpansionAction action
function Action:new(character, object, item, id)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.item, action.id = object, item, id or A.state(object).id
    action.stopOnWalk, action.stopOnRun = true, true
    action.maxTime = action:getDuration()
    return action
end
return Action
