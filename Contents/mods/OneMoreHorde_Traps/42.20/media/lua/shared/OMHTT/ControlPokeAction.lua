require("TimedActions/ISBaseTimedAction")
local Access = require("OMHTT/ControlAccess")
local Battery = require("OMHTT/TurretBattery")
OMHTTControlPokeAction = ISBaseTimedAction:derive("OMHTTControlPokeAction")
local Action = OMHTTControlPokeAction

function Action:destination()
    if self.targetObject then
        if Access.stockpile(self.character, self.object, self.targetObject) ~= self.targetObject then return nil end
        return self.targetObject:getContainer()
    end
    if self.bag then
        local container = self.bag:getContainer()
        if not container or not container:isInCharacterInventory(self.character) or not instanceof(self.bag, "InventoryContainer") then return nil end
        return self.bag:getInventory()
    end
    return self.character:getInventory()
end

function Action:materials()
    local items = self.character:getInventory():getItems()
    local result = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getFullType() == "Base.ScrapMetal" and not item:isFavorite() then
            result[#result + 1] = item
            if #result == 2 then return result end
        end
    end
end

function Action:isValid()
    local state = Access.state(self.object)
    if self.done or not state or state.id ~= self.id or state.kind ~= "Poke"
        or not Access.authorized(self.character, self.object) then return false end
    if self.operation == "Power" then return type(self.value) == "boolean" end
    if state.enabled ~= false or state.active then return false end
    local storage = self.object:getContainer()
    if not storage then return false end
    if self.operation == "Pickup" then return Access.near(self.character, self.object) end
    if self.operation == "Repair" then
        return Access.near(self.character, self.object) and self.object:getHealth() < (state.maxHealth or 200) and self:materials() ~= nil
    end
    if self.operation == "Battery" then
        local source = self.item and self.item:getContainer()
        if not source or not source:contains(self.item) or not source:isRemoveItemAllowed(self.item)
            or not Battery.car(self.item) or self.item:isFavorite() then return false end
        if self.value == true then
            local controller = Access.stockpile(self.character, self.object)
            return storage:getItems():size() == 0 and (source:isInCharacterInventory(self.character)
                or (controller and source == controller:getContainer()))
        end
        local target = self:destination()
        return self.value == false and source == storage and target ~= nil and target:hasRoomFor(self.character, self.item)
    end
    return false
end

function Action:complete()
    if isClient() or not self:isValid() then return false end
    if not isServer() and self.elapsed < self.seconds then return false end
    local W = require("OMHTT/ControlWorld")
    local state = W.state(self.object)
    if self.operation == "Power" then
        state.enabled = self.value
    elseif self.operation == "Pickup" then
        self.done = true
        return W.pickup(self.character, self.object)
    elseif self.operation == "Repair" then
        local items = self:materials()
        for i = 1, #items do
            local source = items[i]:getContainer()
            source:Remove(items[i])
            if isServer() then sendRemoveItemFromContainer(source, items[i]) end
        end
        self.object:setHealth(state.maxHealth or 200)
        if isServer() then self.object:sync() end
    elseif self.operation == "Battery" then
        local source = self.item:getContainer()
        local target = self.value and self.object:getContainer() or self:destination()
        source:Remove(self.item)
        if target:AddItem(self.item) ~= self.item then source:AddItem(self.item); return false end
        self.character:removeFromHands(self.item)
        Battery.detach(self.item)
        if isServer() then
            sendRemoveItemFromContainer(source, self.item)
            sendAddItemToContainer(target, self.item)
            require("OMHTT/TurretItemState").publish(self.item)
        end
    end
    self.done = true
    W.publish(self.object)
    return true
end

function Action:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

function Action:waitToStart()
    if not Access.near(self.character, self.object) then return false end
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

function Action:update()
    if isClient() or isServer() or self.seconds == 0 then return end
    self.elapsed = self.elapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
    self:setJobDelta(math.min(self.elapsed / self.seconds, .999))
    if self.elapsed >= self.seconds then self:forceComplete() end
end

function Action:perform()
    ISBaseTimedAction.perform(self)
end

function Action:getDuration()
    if self.seconds == 0 then return 1 end
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

function Action:new(character, object, operation, value, item, id, targetObject, bag)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.operation, o.value, o.item, o.id = object, operation, value, item, id
    o.targetObject, o.bag = targetObject, bag
    if not isServer() then o.id = id or (Access.state(object) and Access.state(object).id) end
    o.seconds = operation == "Pickup" and 5 or (operation == "Repair" and 10 or 0)
    o.elapsed, o.done, o.stopOnWalk, o.stopOnRun = 0, false, true, true
    o.maxTime = o:getDuration()
    return o
end

return Action
