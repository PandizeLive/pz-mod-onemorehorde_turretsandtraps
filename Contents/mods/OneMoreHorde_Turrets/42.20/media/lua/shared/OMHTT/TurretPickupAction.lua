if isClient() or isServer() then return end
require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
OMHTTTurretPickupAction = ISBaseTimedAction:derive("OMHTTTurretPickupAction")

---@return boolean valid
---@nodiscard
function OMHTTTurretPickupAction:isValid()
    local W = require("OMHTT/TurretWorld")
    return not self.done and W.near(self.character, self.object) and T.state(self.object).id == self.id
        and (self.operation ~= "Repair" or self.object:getHealth() < self.object:getMaxHealth())
end

---@return boolean turning
function OMHTTTurretPickupAction:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function OMHTTTurretPickupAction:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
    D.emit("turret-pickup-start", {id = self.id, operation = self.operation, seconds = 10})
end

---@return nil
function OMHTTTurretPickupAction:update()
    self.character:faceThisObject(self.object)
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), 0.25)
    self:setJobDelta(math.min(self.elapsed / 10, 0.999))
    if self.elapsed >= 10 then self:forceComplete() end
end

---@return nil
function OMHTTTurretPickupAction:stop()
    self.done = true
    D.emit("turret-pickup-cancel", {id = self.id, elapsed = self.elapsed})
    ISBaseTimedAction.stop(self)
end

---@return nil
function OMHTTTurretPickupAction:perform()
    ISBaseTimedAction.perform(self)
end

---@return boolean completed
function OMHTTTurretPickupAction:complete()
    if self.elapsed < 10 or not self:isValid() then return false end
    self.done = true
    local W = require("OMHTT/TurretWorld")
    if self.operation == "Repair" then return W.repair(self.character, self.object, self.id) end
    return W.pickup(self.character, self.object, self.id)
end

---@return number duration
---@nodiscard
function OMHTTTurretPickupAction:getDuration()
    return 480
end

---@param character IsoPlayer Operator
---@param object IsoThumpable Device
---@param operation string? Pickup or Repair
---@return OMHTTTurretPickupAction action
function OMHTTTurretPickupAction:new(character, object, operation)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id = object, T.state(object).id
    o.elapsed, o.done = 0, false
    o.operation = operation or "Pickup"
    o.stopOnWalk, o.stopOnRun = true, true
    o.maxTime = o:getDuration()
    return o
end

return OMHTTTurretPickupAction
