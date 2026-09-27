if isClient() or isServer() then return end
require("TimedActions/ISBaseTimedAction")
local Diagnostics = require("OMHTT/Diagnostics")
OMHTTBarrierServiceAction = ISBaseTimedAction:derive("OMHTTBarrierServiceAction")

---@return boolean valid
---@nodiscard
function OMHTTBarrierServiceAction:isValid()
    local Service = require("OMHTT/BarrierService")
    local record = Service.resolve(self.character, self.object, self.id)
    return record ~= nil and (self.operation == "Pickup" or (self.operation == "Repair" and record.condition < record.maxHealth))
end

---@return boolean turning
function OMHTTBarrierServiceAction:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function OMHTTBarrierServiceAction:start()
    self.elapsed = 0
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
    Diagnostics.emit("barrier-service-start", {id = self.id, action = self.operation, seconds = 10})
end

---@return nil
function OMHTTBarrierServiceAction:update()
    self.character:faceThisObject(self.object)
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), 0.25)
    self:setJobDelta(math.min(self.elapsed / 10, 0.999))
    if self.elapsed >= 10 then
        self:forceComplete()
    end
end

---@return nil
function OMHTTBarrierServiceAction:stop()
    self.done = true
    Diagnostics.emit("barrier-service-cancel", {id = self.id, action = self.operation, elapsed = self.elapsed})
    ISBaseTimedAction.stop(self)
end

---@return nil
function OMHTTBarrierServiceAction:perform()
    ISBaseTimedAction.perform(self)
end

---@return boolean applied
function OMHTTBarrierServiceAction:complete()
    if self.done or self.elapsed < 10 then return false end
    self.done = true
    local Service = require("OMHTT/BarrierService")
    return Service.apply(self.character, self.object, self.id, self.operation)
end

---@return number duration Native progress range; completion uses active real seconds
---@nodiscard
function OMHTTBarrierServiceAction:getDuration()
    return 480
end

---@param character IsoPlayer Acting player
---@param object IsoThumpable Selected barrier part
---@param id string Device identity
---@param operation string Pickup or Repair
---@return OMHTTBarrierServiceAction action
function OMHTTBarrierServiceAction:new(character, object, id, operation)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.operation = object, id, operation
    o.elapsed, o.done = 0, false
    o.maxTime = o:getDuration()
    return o
end

return OMHTTBarrierServiceAction
