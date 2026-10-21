require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
OMHTTTurretPickupAction = ISBaseTimedAction:derive("OMHTTTurretPickupAction")

---@return boolean valid
---@nodiscard
function OMHTTTurretPickupAction:isValid()
    if self.done or not self.character or self.character:isDead() or not T.enabled()
        or (self.operation ~= "Pickup" and self.operation ~= "Repair") then return false end
    local state = T.state(self.object)
    if not state or state.id ~= self.id or self.object:getObjectIndex() < 0
        or self.object:getHealth() <= 0 then return false end
    local square, origin = self.object:getSquare(), self.character:getSquare()
    if not square or not origin or origin:getZ() ~= square:getZ() then return false end
    local dx, dy = self.character:getX() - square:getX() - .5, self.character:getY() - square:getY() - .5
    if math.abs(origin:getX() - square:getX()) > 1 or math.abs(origin:getY() - square:getY()) > 1
        or dx * dx + dy * dy > 4 or (origin ~= square and not origin:canReachTo(square)) then return false end
    return self.operation ~= "Repair" or (self.object:getHealth() < self.object:getMaxHealth()
        and require("OMHTT/ControlRepair").ready(self.character, "Turret"))
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
    D.emit("turret-pickup-start", {id = self.id, operation = self.operation, seconds = self.seconds})
end

---@return nil
function OMHTTTurretPickupAction:update()
    self.character:faceThisObject(self.object)
    if isClient() or isServer() then return end
    self.elapsed = self.elapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
    self:setJobDelta(math.min(self.elapsed / self.seconds, 0.999))
    if self.elapsed >= self.seconds then self:forceComplete() end
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
    if not isServer() and self.elapsed < self.seconds then return false end
    if isClient() then return false end
    if not self:isValid() then return false end
    self.done = true
    local W = require("OMHTT/TurretWorld")
    if self.operation == "Repair" then return W.repair(self.character, self.object, self.id) end
    return W.pickup(self.character, self.object, self.id)
end

---@return number duration
---@nodiscard
function OMHTTTurretPickupAction:getDuration()
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

---@param character IsoPlayer Operator
---@param object IsoThumpable Device
---@param operation string? Pickup or Repair
---@param id string? Exact identity serialized with the action, never recalculated on the server
---@return OMHTTTurretPickupAction action
function OMHTTTurretPickupAction:new(character, object, operation, id)
    local o = ISBaseTimedAction.new(self, character)
    o.object = object
    o.id = id
    if not o.id and not isServer() then
        local state = T.state(object)
        o.id = state and state.id
    end
    o.elapsed, o.done = 0, false
    o.operation = operation or "Pickup"
    o.stopOnWalk, o.stopOnRun = true, true
    o.seconds = o.operation == "Pickup" and 5 or require("OMHTT/ControlRepair").profiles.Turret.seconds
    o.maxTime = o:getDuration()
    return o
end

return OMHTTTurretPickupAction
