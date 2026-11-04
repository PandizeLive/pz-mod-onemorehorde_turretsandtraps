require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTransferAction")
local T = require("OMHTT/Turret")
local G = require("OMHTT/Firearms")
local Access = require("OMHTT/TurretAccess")
OMHTTTurretExpansionAction = ISBaseTimedAction:derive("OMHTTTurretExpansionAction")
local A = OMHTTTurretExpansionAction

---@return table? contents Projected final inventory effects
---@return number excess Physical rounds exceeding the incoming kit's capacity
function A:projection()
    local contents = T.contents(self.object:getContainer(), self.item)
    local stats = T.cycleConfig(contents)
    local total = contents.reserveAll + (G.profile(contents.head) and G.loaded(contents.head) or 0)
    return contents, math.max(0, total - stats.ammo)
end

---@return string? reason Server-rechecked rejection
function A:rejection()
    if self.done or type(self.final) ~= "boolean" or not Access.near(self.character, self.object, self.id) then return "TransferReach" end
    local storage = self.object:getContainer()
    if not self.item or not self.replaced or T.kind(self.item) ~= "capacity" or T.kind(self.replaced) ~= "capacity"
        or self.replaced:getContainer() ~= storage or not storage:contains(self.replaced) then return "TransferMissing" end
    local source = self.item:getContainer()
    if not source or source == storage or not source:contains(self.item) then return "TransferMissing" end
    local controller = require("OMHTT/ControlAccess").stockpile(self.character, self.object, self.controller)
    if not source:isInCharacterInventory(self.character) and (not controller or source ~= controller:getContainer()) then return "TransferCarried" end
    if self.item:isFavorite() or self.replaced:isFavorite() then return "TransferFavorite" end
    if not source:isRemoveItemAllowed(self.item) or not storage:isRemoveItemAllowed(self.replaced) then return "TransferWrongItem" end
    local contents = T.contents(storage)
    if contents.capacities ~= 1 then return "SwapFailed" end
    if contents.head and G.servicing[contents.head] then return "Servicing" end
    local _, excess = self:projection()
    if excess == 0 and storage:getCapacityWeight() - self.replaced:getUnequippedWeight() + self.item:getUnequippedWeight() > storage:getCapacity() then return "TransferFull" end
    if not self.object:getSquare() then return "TransferReach" end
    return nil
end

---@return boolean valid
function A:isValid()
    return self:rejection() == nil
end

---@param item InventoryItem Exact returned item
---@return boolean delivered
---@return ItemContainer? destination Nil means a native world drop
function A:returnItem(item)
    local inventory = self.character:getInventory()
    if inventory:isItemAllowed(item) and inventory:hasRoomFor(self.character, item) then
        if inventory:AddItem(item) == item then return true, inventory end
        return false
    end
    local world = self.object:getSquare():AddWorldInventoryItem(item, .5, .5, 0)
    return world ~= nil, nil
end

---@return boolean completed
function A:complete()
    if isClient() or not self:isValid() then return false end
    local storage, source = self.object:getContainer(), self.item:getContainer()
    local prior = T.contents(storage)
    local projected, excess = self:projection()
    T.rememberModules(storage)
    local failed = false
    if not self.final then
        -- Native timed actions bound each transfer batch. The installed kit remains intact
        -- until the final exchange; interruption cannot strand a partially installed kit.
        local moved, goal = 0, math.min(20, excess)
        for i = #prior.rounds, 1, -1 do
            if moved >= goal then break end
            local item = prior.rounds[i]
            if not item:isFavorite() and storage:isRemoveItemAllowed(item) then
            storage:Remove(item)
            local delivered, destination = self:returnItem(item)
            if not delivered then storage:AddItem(item); failed = true; break end
            if isServer() then
                sendRemoveItemFromContainer(storage, item)
                if destination then sendAddItemToContainer(destination, item) end
            end
            moved = moved + 1
            end
        end
        local head = prior.head
        if not failed and moved < goal and G.profile(head) and not head:isFavorite() then
            -- Native magazine/chamber rounds are materialized only after delivery succeeds.
            while moved < goal and (head:getCurrentAmmoCount() > 0 or head:isRoundChambered()) do
                local round = instanceItem(G.ammoType(head))
                if not round then failed = true; break end
                local delivered, destination = self:returnItem(round)
                if not delivered then failed = true; break end
                if head:getCurrentAmmoCount() > 0 then head:setCurrentAmmoCount(head:getCurrentAmmoCount() - 1)
                else head:setRoundChambered(false) end
                if isServer() and destination then sendAddItemToContainer(destination, round) end
                moved = moved + 1
            end
        end
        failed = failed or moved < goal
        if moved > 0 then
            require("OMHTT/TurretFeed").cancel(head)
            if G.profile(head) then
                G.cancelLoading(head)
                local remaining = T.contents(storage)
                require("OMHTT/FirearmFeed").restore(head, T.cycleConfig(remaining).magazine, self.character, false)
            end
        end
    else
        if excess > 0 then return false end
        source:Remove(self.item)
        storage:Remove(self.replaced)
        if storage:AddItem(self.item) ~= self.item then
            source:AddItem(self.item); storage:AddItem(self.replaced)
            return false
        end
        local delivered, destination = self:returnItem(self.replaced)
        if not delivered then
            storage:Remove(self.item); source:AddItem(self.item); storage:AddItem(self.replaced)
            return false
        end
        ISTransferAction:removeItemOnCharacter(self.character, self.item)
        if prior.void ~= projected.void then require("OMHTT/TurretFeed").cancel(projected.head) end
        if G.profile(projected.head) then
            require("OMHTT/FirearmFeed").restore(projected.head, T.cycleConfig(projected).magazine, self.character, false)
        end
        if isServer() then
            sendRemoveItemFromContainer(source, self.item)
            sendRemoveItemFromContainer(storage, self.replaced)
            sendAddItemToContainer(storage, self.item)
            if destination then sendAddItemToContainer(destination, self.replaced) end
        end
    end
    local state = T.state(self.object)
    state.transferRevision = (state.transferRevision or 0) + 1
    self.done = true
    require("OMHTT/TurretWorld").refresh(self.object)
    if isServer() then
        if prior.head then require("OMHTT/TurretItemState").publish(prior.head, self.character) end
        require("OMHTT/TurretAuthority").publish(self.object)
    end
    if self.final and not failed then
        require("OMHTT/ControlMenuAudio").confirm(self.character)
    end
    return not failed
end

---@return nil
function A:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function A:stop()
    self.done = true
    ISBaseTimedAction.stop(self)
end

---@param character IsoPlayer Authenticated actor
---@param object IsoObject Exact turret
---@param item InventoryItem Incoming kit
---@param replaced InventoryItem Expected installed kit
---@param id string Expected turret identity
---@param controller IsoObject? Authorized source
---@param final boolean Final exchange, or one bounded overflow batch
---@return OMHTTTurretExpansionAction action
function A:new(character, object, item, replaced, id, controller, final)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.item, action.replaced, action.id, action.controller, action.final = object, item, replaced, id, controller, final
    action.stopOnWalk, action.stopOnRun, action.maxTime = true, true, 10
    return action
end

return A
