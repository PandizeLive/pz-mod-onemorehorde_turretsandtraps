if isServer() then return end
require("TimedActions/ISInventoryTransferAction")
require("TimedActions/ISTimedActionQueue")
local Action = require("OMHTT/TurretTransferAction")
local Access = require("OMHTT/TurretAccess")
local T = require("OMHTT/Turret")
local X = {}
local nativeNew = ISInventoryTransferAction.new
Action.setOnComplete = ISInventoryTransferAction.setOnComplete

---@param character IsoPlayer Operator
---@param item InventoryItem Exact item
---@param srcContainer ItemContainer Source
---@param destContainer ItemContainer Destination
---@param time number? Native duration override
---@return table action
function ISInventoryTransferAction:new(character, item, srcContainer, destContainer, time)
    if isClient() and srcContainer and destContainer then
        local incoming = T.isContainer(destContainer)
        local storage = incoming and destContainer or srcContainer
        local object = storage:getParent()
        local state = T.state(object)
        if T.isContainer(storage) and state then
            local bag
            if not incoming and destContainer ~= character:getInventory() then
                bag = destContainer:getContainingItem() or false
            end
            local other = incoming and srcContainer or destContainer
            local controller = other:getType() == "OMHTTController" and other:getParent() or nil
            local action = Action:new(character, object, item, incoming, state.id, nil, bag, destContainer:getType() == "OMHTTController", controller)
            action.srcContainer, action.destContainer = srcContainer, destContainer
            return action
        end
    end
    return nativeNew(self, character, item, srcContainer, destContainer, time)
end

---@return nil
function Action:begin()
    if not self.onCompleteFunc and self.item and T.kind(self.item) == "ammo" and require("OMHTT/TurretAmmo").fastTransfer(self.item) then
        local queue = ISTimedActionQueue.getTimedActionQueue(self.character)
        local position = queue:indexOf(self)
        if position > 0 then
            self.ids = self.ids or {self.item:getID()}
            while #self.ids < 20 do
                local candidate = queue.queue[position + 1]
                if not candidate or candidate.Type ~= self.Type or candidate.object ~= self.object
                    or candidate.incoming ~= self.incoming or candidate.id ~= self.id or candidate.ids
                    or candidate.destinationBag ~= self.destinationBag or candidate.stockpile ~= self.stockpile or candidate.controller ~= self.controller
                    or candidate.onCompleteFunc or not candidate.item
                    or candidate.item:getContainer() ~= self.item:getContainer()
                    or candidate.item:getFullType() ~= self.item:getFullType() then break end
                self.ids[#self.ids + 1] = candidate.item:getID()
                table.remove(queue.queue, position + 1)
            end
        end
    end
    ISBaseTimedAction.begin(self)
end

---@param player IsoPlayer Operator
---@param object IsoObject Exact placed turret
---@param items table Exact selected items
---@param incoming boolean Into turret
---@param kind string Slot family
---@param stockpile boolean? Withdraw into controller
---@param controller IsoObject? Exact stockpile endpoint
---@return number queued
---@return string? reason
function X.queue(player, object, items, incoming, kind, stockpile, controller)
    if not Access.near(player, object) then return 0, "TransferReach" end
    local state, queued, reason = T.state(object), 0, nil
    local pending = {}
    local summary
    if incoming and kind == "ammo" then
        summary = T.contents(object:getContainer())
        summary.transferStats = T.cycleConfig(summary)
    end
    local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
    for i = 1, #queue do
        local action = queue[i]
        if action.Type == Action.Type and action.item then
            pending[action.item:getID()] = true
            if action.ids then
                for j = 1, #action.ids do
                    pending[action.ids[j]] = true
                end
            end
            if summary and action.object == object and action.incoming and T.kind(action.item) == "ammo" then
                summary.reserveAll = summary.reserveAll + (action.ids and #action.ids or 1)
            end
        end
    end
    local prepared, batch = {}, nil
    for i = 1, #items do
        local item = items[i]
        local action = Action:new(player, object, item, incoming, state.id, nil, nil, stockpile, controller)
        local rejection = action:rejection(item, summary)
        if pending[item:getID()] then
            rejection = "TransferPending"
        elseif T.kind(item) ~= kind then
            rejection = "TransferWrongItem"
        end
        if rejection then
            reason = rejection
        else
            pending[item:getID()] = true
            local lightAmmo = kind == "ammo" and require("OMHTT/TurretAmmo").fastTransfer(item)
            if lightAmmo and batch and #batch.ids < 20 and batch.item:getFullType() == item:getFullType()
                and batch.item:getContainer() == item:getContainer() then
                batch.ids[#batch.ids + 1] = item:getID()
            else
                batch = lightAmmo and action or nil
                if batch then
                    batch.ids = {item:getID()}
                end
                prepared[#prepared + 1] = action
            end
            queued = queued + 1
            if summary then
                summary.reserveAll = summary.reserveAll + 1
            end
        end
    end
    for i = 1, #prepared do
        ISTimedActionQueue.add(prepared[i])
    end
    return queued, reason
end

return X
