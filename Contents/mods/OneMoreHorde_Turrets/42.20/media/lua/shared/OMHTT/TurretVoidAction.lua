require("TimedActions/ISBaseTimedAction")
local Access = require("OMHTT/TurretAccess")
local V = require("OMHTT/TurretVoid")
local State = require("OMHTT/TurretItemState")
OMHTTTurretVoidAction = ISBaseTimedAction:derive("OMHTTTurretVoidAction")
local Action = OMHTTTurretVoidAction

---@return boolean valid
function Action:isValid()
    if self.done or type(self.id) ~= "string" or not Access.near(self.character, self.object, self.id)
        or not self.module or self.module:getFullType() ~= V.TYPE or self.module:getCondition() <= 0
        or type(self.ids) ~= "table" or #self.ids < 1 or #self.ids > 20 then return false end
    local storage = self.object:getContainer()
    return self.module:getContainer() == storage and storage:contains(self.module)
end

---@return boolean committed
function Action:complete()
    if isClient() or not self:isValid() then return false end
    local storage, items, seen = self.object:getContainer(), {}, {}
    local Ammo = require("OMHTT/TurretAmmo")
    for i = 1, #self.ids do
        local id = self.ids[i]
        if type(id) ~= "number" or id ~= math.floor(id) or seen[id] then return false end
        seen[id] = true
        local item = storage:getItemById(id)
        if not item or item:getContainer() ~= storage or item:isFavorite() or not Ammo.describe(item) then return false end
        items[#items + 1] = item
    end
    -- Ready extension rounds are physical items too. Do not convert reserved feed rounds.
    local contents = require("OMHTT/Turret").contents(storage)
    local G = require("OMHTT/Firearms")
    if G.profile(contents.head) then
        if require("OMHTT/FirearmFeed").count(contents.head) > 0 then return false end
    elseif contents.head then
        local cycle = State.get(contents.head, "cycle")
        if cycle and (cycle.loaded or 0) > 0 then return false end
    end
    self.done = true
    local count = 0
    for i = 1, #items do
        if not V.deposit(self.module, items[i], storage) then break end
        count = count + 1
    end
    if count == 0 then return false end
    State.publish(self.module, self.character)
    require("OMHTT/TurretWorld").refresh(self.object)
    return true
end

---@return nil
function Action:perform()
    ISBaseTimedAction.perform(self)
end

---@return number duration Native minimal server action
function Action:getDuration()
    return 1
end

---@param character IsoPlayer Operator
---@param object IsoObject Exact placed turret
---@param id string Expected turret identity
---@param module InventoryItem Exact installed Void module
---@param ids table At most twenty exact physical ammunition IDs
---@return OMHTTTurretVoidAction action
function Action:new(character, object, id, module, ids)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.module, o.ids = object, id, module, ids
    o.done, o.stopOnWalk, o.stopOnRun = false, true, true
    o.maxTime = o:getDuration()
    return o
end

return Action
