require("TimedActions/ISBaseTimedAction")
local Diagnostics = require("OMHTT/Diagnostics")
local F = require("OMHTT/Foundation")
local Approach = require("OMHTT/BarrierApproach")
OMHTTBarrierServiceAction = ISBaseTimedAction:derive("OMHTTBarrierServiceAction")

---@return boolean valid
---@nodiscard
function OMHTTBarrierServiceAction:isValid()
    if self.done or type(self.id) ~= "string" then return false end
    if isClient() then
        if not F.barrierEnabled() or self.character:isDead() or not self.object or self.object:getObjectIndex() < 0 then return false end
        local marker = self.object:hasModData() and self.object:getModData().OMHTT
        if not marker or marker.id ~= self.id or marker.placementSource ~= "construction" then return false end
        local view = {x = marker.anchorX, y = marker.anchorY, z = marker.anchorZ,
            facing = marker.facing, collisionModel = marker.collisionModel}
        if not view.x or not view.y or not view.z or not view.facing or not Approach.ready(self.character, view) then return false end
        return self.operation == "Pickup" or (self.operation == "Repair" and marker.condition < marker.maxHealth)
            or (self.operation == "Reinforce" and marker.tier ~= "reinforced"
                and require("OMHTT/DefenseMaterials").reinforcement(self.character) ~= nil)
    end
    local Service = require("OMHTT/BarrierService")
    local record = Service.resolve(self.character, self.object, self.id)
    return record ~= nil and (self.operation == "Pickup"
        or (self.operation == "Repair" and record.condition < record.maxHealth)
        or (self.operation == "Reinforce" and Service.reinforcementMaterials(self.character, record) ~= nil))
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
    if self.operation == "Reinforce" then
        local materials = require("OMHTT/DefenseMaterials").reinforcement(self.character)
        if not materials then
            self:forceStop()
            return
        end
        self:setActionAnim("Build")
        if materials.hammer then
            self:setOverrideHandModels(materials.hammer:getStaticModel(), getItemStaticModel("Base.Plank"))
        end
        addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 20, 1)
    end
    Diagnostics.emit("barrier-service-start", {id = self.id, action = self.operation, seconds = self.seconds})
end

---@return nil
function OMHTTBarrierServiceAction:update()
    self.character:faceThisObject(self.object)
    if isClient() or isServer() then return end
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), 0.25)
    self:setJobDelta(math.min(self.elapsed / self.seconds, 0.999))
    if self.elapsed >= self.seconds then
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
    if isClient() then return false end
    if not isServer() and self.elapsed < self.seconds then return false end
    if not self:isValid() then return false end
    self.done = true
    local Service = require("OMHTT/BarrierService")
    return Service.apply(self.character, self.object, self.id, self.operation)
end

---@return number duration Native progress range; completion uses active real seconds
---@nodiscard
function OMHTTBarrierServiceAction:getDuration()
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

---@param character IsoPlayer Acting player
---@param object IsoThumpable Selected barrier part
---@param id string Device identity
---@param operation string Pickup, Repair or Reinforce
---@return OMHTTBarrierServiceAction action
function OMHTTBarrierServiceAction:new(character, object, id, operation)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.operation = object, id, operation
    o.elapsed, o.done = 0, false
    o.seconds = o.operation == "Pickup" and 5 or 10
    o.stopOnWalk, o.stopOnRun = true, true
    o.maxTime = o:getDuration()
    return o
end

return OMHTTBarrierServiceAction
