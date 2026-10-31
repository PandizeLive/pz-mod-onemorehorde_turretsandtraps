require("TimedActions/ISBaseTimedAction")
local P = require("OMHTT/PlacementRules")
OMHTTPlacementAction = ISBaseTimedAction:derive("OMHTTPlacementAction")
local A = OMHTTPlacementAction

---@return boolean valid
function A:inputsValid()
    local profile = P.routes[self.route]
    if not profile or not P.carried(self.item, self.character, profile[1]) then return false end
    if profile[3] then
        if self.companion == self.item or not P.carried(self.companion, self.character, profile[1]) then return false end
    elseif self.companion then
        return false
    end
    if profile[4] and not self.character:isBuildCheat() then
        local inventory = self.character:getInventory()
        return inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, P.usable) ~= nil
            and inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, P.usable) ~= nil
    end
    return true
end

---@return ISBuildIsoEntity? cursor
function A:prepare()
    if self.cursor then return self.cursor end
    if not self:inputsValid() or type(self.rotation) ~= "number" or self.rotation % 1 ~= 0
        or self.rotation < 1 or self.rotation > 4 then return nil end
    local info = SpriteConfigManager.GetObjectInfo(self.route)
    if not info then return nil end
    require("BuildingObjects/ISBuildIsoEntity")
    local containers = ArrayList.new()
    containers:add(self.character:getInventory())
    if self.item:getContainer() ~= self.character:getInventory() then containers:add(self.item:getContainer()) end
    if self.companion and self.companion:getContainer() ~= self.item:getContainer()
        and self.companion:getContainer() ~= self.character:getInventory() then containers:add(self.companion:getContainer()) end
    local cursor = ISBuildIsoEntity:new(self.character, info, self.rotation, containers)
    cursor.player = self.character:getPlayerNum()
    local logic = cursor.buildPanelLogic
    logic:setManualSelectInputs(true)
    logic:clearManualInputs()
    local selected = ArrayList.new()
    selected:add(self.item)
    if self.companion then selected:add(self.companion) end
    local input = cursor.craftRecipe:getInputs():get(0)
    logic:setManualInputsFor(input, selected)
    if P.routes[self.route][4] and not self.character:isBuildCheat() then
        local inventory = self.character:getInventory()
        logic:offerInputItem(inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, P.usable))
        logic:offerInputItem(inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, P.usable))
    end
    cursor:getSprite()
    self.cursor = cursor
    return cursor
end

---@return boolean valid
function A:isValid()
    if self.done or self.character:isDead() or not self:inputsValid() then return false end
    if type(self.x) ~= "number" or type(self.y) ~= "number" or type(self.z) ~= "number"
        or self.x % 1 ~= 0 or self.y % 1 ~= 0 or self.z % 1 ~= 0 then return false end
    local square, origin = getCell():getGridSquare(self.x, self.y, self.z), self.character:getSquare()
    if not square or not origin or origin:getZ() ~= self.z
        or math.abs(self.character:getX() - self.x - .5) > 1.6
        or math.abs(self.character:getY() - self.y - .5) > 1.6
        or (origin ~= square and not origin:canReachTo(square)) then return false end
    local cursor = self:prepare()
    if not cursor then return false end
    if self.route == "OMHTTDeployPoke" and not require("OMHTT/ControlPokeFootprint").valid(square, nil, self.character) then return false end
    local face = cursor:getFace()
    if not face then return false end
    for dx = 0, face:getWidth() - 1 do
        for dy = 0, face:getHeight() - 1 do
            local target = getCell():getGridSquare(self.x + dx, self.y + dy, self.z)
            if not target or SafeHouse.isSafeHouse(target, self.character:getUsername(), true) then return false end
        end
    end
    local callback = cursor.objectInfo:getScript():getTimedActionOnIsValid()
    if callback and not BaseCraftingLogic.callLuaBool(callback, {square = square, facing = face:getFaceName()}) then return false end
    return cursor:isValid(square)
end

---@return boolean turning
function A:waitToStart()
    self.character:faceLocation(self.x, self.y)
    return self.character:shouldBeTurning()
end

---@return nil
function A:start()
    local cursor = self:prepare()
    if not cursor then self:forceStop(); return end
    if self.preview then
        self.preview:onTimedActionStart(self)
    else
        cursor:onTimedActionStart(self)
    end
end

---@return nil
function A:update()
    self.character:faceLocation(self.x, self.y)
    if isClient() or isServer() then return end
    self.elapsed = self.elapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
    self:setJobDelta(math.min(self.elapsed / self.seconds, .999))
    if self.elapsed >= self.seconds then self:forceComplete() end
end

---@return boolean completed
function A:complete()
    if isClient() or (not isServer() and self.elapsed < self.seconds) or not self:isValid() then return false end
    self.done = true
    local cursor = self.cursor
    require("OMHTT/PlacementBuild").create(cursor, self.item, self.companion, self.x, self.y, self.z)
    cursor.buildPanelLogic:stopCraftAction()
    local square = getCell():getGridSquare(self.x, self.y, self.z)
    square:RecalcAllWithNeighbours(true)
    buildUtil.setHaveConstruction(square, true)
    return not self.item:getContainer() or not self.item:getContainer():contains(self.item)
end

---@return nil
function A:stop()
    self.done = true
    if self.preview then self.preview:onActionComplete() end
    if self.cursor then self.cursor.buildPanelLogic:stopCraftAction() end
    ISBaseTimedAction.stop(self)
end

---@return nil
function A:perform()
    if self.preview then self.preview:onActionComplete() end
    ISBaseTimedAction.perform(self)
end

---@return number duration
function A:getDuration()
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

---@param character IsoPlayer Builder
---@param item InventoryItem Exact primary input
---@param companion InventoryItem? Second independent Bed tile
---@param route string Allowlisted native entity
---@param rotation number Cardinal rotation
---@param x number Tile X
---@param y number Tile Y
---@param z number Floor
---@return OMHTTPlacementAction action
function A:new(character, item, companion, route, rotation, x, y, z)
    local action = ISBaseTimedAction.new(self, character)
    action.item, action.companion, action.route, action.rotation = item, companion, route, rotation
    action.x, action.y, action.z = x, y, z
    action.seconds = P.routes[route] and P.routes[route][2] or 5
    action.stopOnWalk, action.stopOnRun, action.done, action.elapsed = true, true, false, 0
    action.maxTime = action:getDuration()
    return action
end

return A
