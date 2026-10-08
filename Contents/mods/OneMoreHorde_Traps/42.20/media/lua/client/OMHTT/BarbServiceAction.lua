if isClient() or isServer() then return end
require("TimedActions/ISBaseTimedAction")
local S = require("OMHTT/BarbService")
OMHTTBarbServiceAction = ISBaseTimedAction:derive("OMHTTBarbServiceAction")

---@return boolean valid
---@nodiscard
function OMHTTBarbServiceAction:isValid()
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
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), .25)
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
    if self.done or self.elapsed < self.seconds then return false end
    self.done = true
    return S.apply(self.character, self.object, self.id, self.operation)
end

---@return number duration
---@nodiscard
function OMHTTBarbServiceAction:getDuration()
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
    o.seconds = o.operation == "Remove" and 5 or 10
    o.elapsed, o.done, o.maxTime = 0, false, 480
    o.stopOnWalk, o.stopOnRun = true, true
    return o
end
