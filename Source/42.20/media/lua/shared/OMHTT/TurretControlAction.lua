require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local Access = require("OMHTT/TurretAccess")
local M = require("OMHTT/TurretModules")
OMHTTTurretControlAction = ISBaseTimedAction:derive("OMHTTTurretControlAction")
local Action = OMHTTTurretControlAction

---@return boolean valid
function Action:isValid()
    if self.done or type(self.id) ~= "string" or not Access.near(self.character, self.object, self.id) then return false end
    local contents = T.contents(self.object:getContainer())
    if self.command == "Priority" then
        if not contents.active.Filter then return false end
        for i = 1, #M.PRIORITIES do
            if self.value == M.PRIORITIES[i] then return true end
        end
    elseif self.command == "Range" then
        return type(self.value) == "number" and self.value == self.value and self.value % 1 == 0
            and self.value >= 0 and self.value <= math.max(2, math.ceil(T.cycleConfig(contents).range))
    end
    return false
end

---@return boolean completed
function Action:complete()
    if isClient() or not self:isValid() then return false end
    self.done = true
    local state = T.state(self.object)
    if self.command == "Priority" then
        state.priority = self.value
    else
        state.engagementRange = self.value > 0 and self.value or nil
    end
    if isServer() then
        require("OMHTT/TurretWorld").refresh(self.object)
        require("OMHTT/TurretAuthority").publish(self.object)
    else
        require("OMHTT/TurretWorld").queueRefresh(self.object, true)
    end
    return true
end

---@return nil
function Action:perform()
    ISBaseTimedAction.perform(self)
end

---@return number duration
function Action:getDuration()
    return 1
end

---@param character IsoPlayer Operator
---@param object IsoObject Exact turret
---@param id string Expected identity
---@param command string Range or Priority
---@param value number|string Requested value
---@return OMHTTTurretControlAction action
function Action:new(character, object, id, command, value)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.command, o.value = object, id, command, value
    o.done, o.stopOnWalk, o.stopOnRun = false, true, true
    o.maxTime = o:getDuration()
    return o
end

return Action
