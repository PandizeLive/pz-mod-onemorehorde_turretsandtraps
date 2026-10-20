require("TimedActions/ISBaseTimedAction")
local S = require("OMHTT/BarbService")
OMHTTBarbServiceAction = ISBaseTimedAction:derive("OMHTTBarbServiceAction")

---@return boolean valid
---@nodiscard
function OMHTTBarbServiceAction:isValid()
    if self.done or type(self.id) ~= "string" then return false end
    local attachment = S.resolve(self.character, self.object, self.id)
    return attachment ~= nil and (self.operation == "Remove"
        or (self.operation == "Repair" and not attachment.shared and attachment.health < 50))
end

---@return boolean turning
function OMHTTBarbServiceAction:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function OMHTTBarbServiceAction:start()
    self.elapsed = 0
    self:setActionAnim("Build")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function OMHTTBarbServiceAction:update()
    self.character:faceThisObject(self.object)
    if isClient() or isServer() then return end
    self.elapsed = self.elapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
    self:setJobDelta(math.min(self.elapsed / self.seconds, .999))
    if self.elapsed >= self.seconds then
        self:forceComplete()
    end
end

---@return nil
function OMHTTBarbServiceAction:stop()
    self.done = true
    ISBaseTimedAction.stop(self)
end

---@return nil
function OMHTTBarbServiceAction:perform()
    ISBaseTimedAction.perform(self)
end

---@return boolean applied
function OMHTTBarbServiceAction:complete()
    if isClient() then return false end
    if not isServer() and self.elapsed < self.seconds then return false end
    if not self:isValid() then return false end
    self.done = true
    return S.apply(self.character, self.object, self.id, self.operation)
end

---@return number duration
---@nodiscard
function OMHTTBarbServiceAction:getDuration()
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

---@param character IsoPlayer Acting player
---@param object IsoObject Frame
---@param id string Expected identity
---@param operation string Repair or Remove
---@return OMHTTBarbServiceAction action
function OMHTTBarbServiceAction:new(character, object, id, operation)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.operation = object, id, operation
    o.seconds = o.operation == "Remove" and 5 or require("OMHTT/ControlRepair").profiles.Barb.seconds
    o.elapsed, o.done = 0, false
    o.stopOnWalk, o.stopOnRun = true, true
    o.maxTime = o:getDuration()
    return o
end
