require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTransferAction")
local T = require("OMHTT/Turret")
local Access = require("OMHTT/TurretAccess")
local G = require("OMHTT/Firearms")
local Feed = require("OMHTT/FirearmFeed")
OMHTTTurretTransferAction = ISBaseTimedAction:derive("OMHTTTurretTransferAction")
local Action = OMHTTTurretTransferAction

---@return ItemContainer? destination
---@nodiscard
function Action:destination()
    if self.incoming then return self.object:getContainer() end
    if self.stockpile then
        local controller = require("OMHTT/ControlAccess").stockpile(self.character, self.object, self.controller)
        return controller and controller:getContainer()
    end
    if self.destinationBag == nil then return self.character:getInventory() end
    if self.destinationBag == false then return nil end
    if not instanceof(self.destinationBag, "InventoryContainer") then return nil end
    local source = self.destinationBag:getContainer()
    if not source or not source:isInCharacterInventory(self.character) or not source:contains(self.destinationBag) then return nil end
    return self.destinationBag:getInventory()
end

---@param candidate InventoryItem Exact item
---@param summary table? Transaction-local incoming-ammo counts
---@return string? reason
function Action:rejection(candidate, summary)
    if self.done or self.cancelled or type(self.incoming) ~= "boolean" or type(self.id) ~= "string"
        or not Access.near(self.character, self.object, self.id) then return "TransferReach" end
    if not candidate then return "TransferMissing" end
    local source, storage = candidate:getContainer(), self.object:getContainer()
    if not source or not source:contains(candidate) then return "TransferMissing" end
    local destination = self:destination()
    if not destination then return "TransferCarried" end
    if self.incoming then
        local controller = require("OMHTT/ControlAccess").stockpile(self.character, self.object, self.controller)
        local stockpile = controller and controller:getContainer()
        if source == storage or (not source:isInCharacterInventory(self.character) and source ~= stockpile) then return "TransferCarried" end
        if candidate:isFavorite() then return "TransferFavorite" end
        if not T.accepts(storage, candidate, summary) then return "TransferFull" end
        destination = storage
    elseif source ~= storage then
        return "TransferMissing"
    elseif self.stockpile and candidate:isFavorite() then
        return "TransferFavorite"
    end
    if not T.canRemove(source, candidate) then return "CapacityFull" end
    if not source:isRemoveItemAllowed(candidate) then return "TransferWrongItem" end
    if not self.incoming and not self.stockpile and not destination:isItemAllowed(candidate) then return "TransferWrongItem" end
    local room
    if self.incoming then
        room = true
    elseif self.stockpile then
        if not require("OMHTT/ControlDefinitions").storable(candidate) then return "TransferWrongItem" end
        room = destination:getCapacityWeight() + candidate:getUnequippedWeight() <= 500
    else
        room = destination:hasRoomFor(self.character, candidate)
    end
    if not room then return "TransferFull" end
    return nil
end

---@return boolean valid
function Action:isValid()
    return self:rejection(self.item) == nil
end

---@return boolean turning
function Action:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function Action:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function Action:update()
    self.character:faceThisObject(self.object)
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

---@return boolean completed
function Action:complete()
    if isClient() or not self:isValid() then return false end
    local source, storage = self.item:getContainer(), self.object:getContainer()
    local destination = self:destination()
    local items = {self.item}
    if self.ids ~= nil then
        if type(self.ids) ~= "table" or #self.ids > 20 or #self.ids < 1
            or self.ids[1] ~= self.item:getID() or T.kind(self.item) ~= "ammo"
            or self.item:getActualWeight() > .1 then return false end
        local seen = {[self.item:getID()] = true}
        for i = 2, #self.ids do
            local id = self.ids[i]
            if type(id) ~= "number" or seen[id] then return false end
            seen[id] = true
            local candidate = source:getItemById(id)
            if not candidate or candidate:getContainer() ~= source
                or candidate:getFullType() ~= self.item:getFullType() or candidate:getActualWeight() > .1 then return false end
            items[#items + 1] = candidate
        end
    end
    self.done = true
    local moved = 0
    local summary
    if self.incoming and #items > 1 then
        summary = T.contents(storage)
        summary.transferStats = T.cycleConfig(summary)
    end
    for i = 1, #items do
        local candidate = items[i]
        self.done = false
        local rejected = self:rejection(candidate, summary)
        self.done = true
        if rejected then break end
        if not self.incoming and (candidate == T.contents(storage).head or candidate:getFullType() == "Base.OMHTTModuleVoid") then
            require("OMHTT/TurretFeed").cancel(T.contents(storage).head)
        end
        source:Remove(candidate)
        if destination:AddItem(candidate) ~= candidate then
            source:AddItem(candidate)
            break
        end
        if self.incoming then
            ISTransferAction:removeItemOnCharacter(self.character, candidate)
        end
        if G.profile(candidate) then
            G.cancelLoading(candidate)
            if not self.incoming then
                Feed.restore(candidate, candidate:getMaxAmmo(), self.character, true)
            end
        end
        if isServer() then
            sendRemoveItemFromContainer(source, candidate)
            sendAddItemToContainer(destination, candidate)
            if G.profile(candidate) or T.kind(candidate) == "battery" then
                require("OMHTT/TurretItemState").publish(candidate, self.character)
            end
        end
        moved = moved + 1
        if summary then
            summary.reserveAll, summary.reserve, summary.ammo = summary.reserveAll + 1, summary.reserve + 1, summary.ammo + 1
        end
    end
    if moved == 0 then return false end
    local contents = T.contents(storage)
    if G.profile(contents.head) then
        Feed.restore(contents.head, T.cycleConfig(contents).magazine, self.character, false)
        if isServer() then
            require("OMHTT/TurretItemState").publish(contents.head, self.character)
        end
    end
    local W = require("OMHTT/TurretWorld")
    W.refresh(self.object)
    if isServer() then
        self.object:transmitUpdatedSpriteToClients()
        require("OMHTT/TurretAuthority").publish(self.object)
    end
    return true
end

---@return number duration
function Action:getDuration()
    if not self.item then return 1 end
    local duration = 50 * math.min(3, math.max(.02, self.item:getActualWeight()))
    if self.character:hasTrait(CharacterTrait.DEXTROUS) then
        duration = duration * .5
    end
    if self.character:hasTrait(CharacterTrait.ALL_THUMBS) or self.character:isWearingAwkwardGloves() then
        duration = duration * 2
    end
    return math.max(1, duration)
end

---@param character IsoPlayer Operator
---@param object IsoObject Exact placed turret
---@param item InventoryItem First exact item
---@param incoming boolean Direction
---@param id string Expected turret identity
---@param ids table? At most twenty exact same-type light-ammo IDs
---@param destinationBag InventoryItem? Exact carried destination bag; nil means main inventory
---@param stockpile boolean? Withdraw into stockpile
---@param controller IsoObject? Exact stockpile endpoint
---@return OMHTTTurretTransferAction action
function Action:new(character, object, item, incoming, id, ids, destinationBag, stockpile, controller)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.item, o.incoming, o.id, o.ids = object, item, incoming, id, ids
    o.destinationBag = destinationBag
    o.stockpile = stockpile == true
    o.controller = controller
    o.done, o.stopOnWalk, o.stopOnRun = false, true, true
    o.maxTime = o:getDuration()
    return o
end

return Action
