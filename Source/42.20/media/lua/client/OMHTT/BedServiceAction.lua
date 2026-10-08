if isClient() or isServer() then
    return
end
require("TimedActions/ISBaseTimedAction")
OMHTTBedServiceAction = ISBaseTimedAction:derive("OMHTTBedServiceAction")

---@return boolean valid
---@nodiscard
function OMHTTBedServiceAction:isValid()
    local S = require("OMHTT/BedService")
    local record = S.resolve(self.character, self.object, self.id)
    return record ~= nil and (self.operation == "Pickup" or (self.operation == "Repair" and record.health < record.maxHealth)
        or (self.operation == "Reinforce" and S.materials(self.character, record) ~= nil))
end

---@return boolean turning
function OMHTTBedServiceAction:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function OMHTTBedServiceAction:start()
    self.elapsed = 0
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
    if self.operation == "Reinforce" then
        local S = require("OMHTT/BedService")
        local record = S.resolve(self.character, self.object, self.id)
        local materials = record and S.materials(self.character, record)
        if not materials then
            self:forceStop()
            return
        end
        self:setActionAnim("Build")
        if materials.hammer then
            self:setOverrideHandModels(materials.hammer:getStaticModel(), getItemStaticModel("Base.Plank"))
        end
    end
end

---@return nil
function OMHTTBedServiceAction:update()
    self.character:faceThisObject(self.object)
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), 0.25)
    self:setJobDelta(math.min(self.elapsed / self.seconds, 0.999))
    if self.elapsed >= self.seconds then
        self:forceComplete()
    end
end

---@return nil
function OMHTTBedServiceAction:stop()
    self.done = true
    ISBaseTimedAction.stop(self)
end

---@return nil
function OMHTTBedServiceAction:perform()
    ISBaseTimedAction.perform(self)
end

---@return boolean applied
function OMHTTBedServiceAction:complete()
    if self.done or self.elapsed < self.seconds then return false end
    self.done = true
    return require("OMHTT/BedService").apply(self.character, self.object, self.id, self.operation)
end

---@return number seconds
---@nodiscard
function OMHTTBedServiceAction:getDuration()
    return 480
end

---@param character IsoPlayer Acting player
---@param object IsoObject Selected part
---@param id string Expected identity
---@param operation string Service operation
---@return OMHTTBedServiceAction action
function OMHTTBedServiceAction:new(character, object, id, operation)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.operation = object, id, operation
    o.seconds = o.operation == "Pickup" and 5 or 10
    o.elapsed, o.done, o.maxTime = 0, false, 480
    o.stopOnWalk, o.stopOnRun = true, true
    return o
end
