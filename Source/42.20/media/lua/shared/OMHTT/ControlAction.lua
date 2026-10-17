require("TimedActions/ISBaseTimedAction")
local A = require("OMHTT/ControlAccess")
OMHTTControlAction = ISBaseTimedAction:derive("OMHTTControlAction")
local Action = OMHTTControlAction

---@return boolean valid
function Action:isValid()
    local state = A.state(self.object)
    if self.done or not state or state.id ~= self.id or not A.authorized(self.character, self.object, self.command == "Pulse")
        or self.object:getHealth() <= 0 then return false end
    if self.command == "Pulse" then return state.kind == "Button" end
    if not A.write(self.character, state) then return false end
    if self.command == "Name" then
        return state.kind ~= "Controller" and type(self.value) == "string" and #self.value <= 48 and not string.find(self.value, "[%c<>]")
    elseif self.command == "Access" then
        return A.write(self.character, state, true)
            and (self.value == "Private" or self.value == "Faction" or self.value == "Public")
    elseif self.command == "Assign" or self.command == "Link" then
        local target = A.state(self.target)
        return target and target.id == self.targetId and A.write(self.character, target)
            and A.range(self.object, self.target) and type(self.value) == "boolean"
            and (self.command ~= "Assign" or state.kind == "Controller")
    elseif self.command == "ClearInputs" then
        return state.kind == "Turret"
    elseif self.command == "Trigger" then
        return state.kind == "Plate" and (self.value == "Both" or self.value == "Players" or self.value == "Zombies")
    elseif self.command == "Pickup" or self.command == "Repair" then
        return state.kind ~= "Turret"
    end
    return false
end

---@return boolean complete
function Action:complete()
    if isClient() or not self:isValid() then return false end
    self.done = true
    local W = require("OMHTT/ControlWorld")
    local state = W.state(self.object)
    if self.command == "Pulse" then
        state.pulseUntil = getTimestampMs() + 1
        for i = 1, #state.links do
            local target = W.objects[state.links[i]]
            if target and A.range(self.object, target) then
                W.pulse(target)
            end
        end
    elseif self.command == "Name" then
        state.name = self.value ~= "" and self.value or nil
    elseif self.command == "Access" then
        local faction = self.value == "Faction" and Faction.getPlayerFaction(self.character)
        if self.value == "Faction" and not faction then return false end
        state.access, state.faction = self.value, faction and faction:getName() or nil
    elseif self.command == "Assign" then
        local target = W.state(self.target)
        if not self.value and target.controller ~= state.id then return false end
        if self.value then
            local inputs, outputs = 0, 0
            for _, assigned in pairs(W.records().records) do
                if assigned.placed and assigned.controller == state.id and assigned.id ~= target.id then
                    if assigned.kind == "Turret" then
                        outputs = outputs + 1
                    else
                        inputs = inputs + 1
                    end
                end
            end
            if (target.kind == "Turret" and outputs >= 32) or (target.kind ~= "Turret" and inputs >= 32) then return false end
            if target.kind == "Controller" then return false end
        end
        target.controller = self.value and state.id or nil
        if self.value and target.kind == "Turret" then
            W.number(self.target, require("OMHTT/Turret").contents(self.target:getContainer()).head)
        end
        W.publish(self.target)
    elseif self.command == "Link" then
        return W.link(self.object, self.target, self.value)
    elseif self.command == "ClearInputs" then
        W.clearInputs(self.object)
    elseif self.command == "Trigger" then
        state.trigger = self.value
    elseif self.command == "Repair" then
        self.object:setHealth(100)
        if isServer() then
            self.object:sync()
        end
    elseif self.command == "Pickup" then
        return W.pickup(self.character, self.object)
    end
    W.publish(self.object)
    return true
end

---@return number duration
function Action:getDuration()
    if self.command == "Pickup" then return 250 end
    if self.command == "Repair" then return 500 end
    return 1
end

---@return nil
function Action:perform()
    ISBaseTimedAction.perform(self)
end

---@param character IsoPlayer Operator
---@param object IsoObject Device
---@param command string Operation
---@param value any Bounded operation value
---@param target IsoObject? Exact other endpoint
---@param id string? Expected source identity
---@param targetId string? Expected target identity
---@return OMHTTControlAction action
function Action:new(character, object, command, value, target, id, targetId)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.command, action.value, action.target = object, command, value, target
    action.id, action.targetId = id, targetId
    if not isServer() then
        action.id = id or (A.state(object) and A.state(object).id)
        action.targetId = targetId or (A.state(target) and A.state(target).id)
    end
    action.stopOnWalk, action.stopOnRun, action.done = true, true, false
    action.maxTime = action:getDuration()
    return action
end

return Action

