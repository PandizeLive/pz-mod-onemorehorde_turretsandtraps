require("TimedActions/ISBaseTimedAction")
local A = require("OMHTT/ControlAccess")
OMHTTControlAction = ISBaseTimedAction:derive("OMHTTControlAction")
local Action = OMHTTControlAction

---@return boolean turning
function Action:waitToStart()
    if self.command ~= "Pickup" then return false end
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function Action:start()
    local state = A.state(self.object)
    if self.command ~= "Pickup" or not state or state.kind ~= "Plate" then return end
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function Action:update()
    if self.command == "Pickup" then
        self.character:faceThisObject(self.object)
    end
    if isClient() or isServer() or self.seconds == 0 then return end
    self.elapsed = self.elapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
    self:setJobDelta(math.min(self.elapsed / self.seconds, .999))
    if self.elapsed >= self.seconds then self:forceComplete() end
end

---@return boolean valid
function Action:isValid()
    local state = A.state(self.object)
    if self.done or not state or state.id ~= self.id or not A.authorized(self.character, self.object, self.command == "Pulse")
        or (self.object:getHealth() <= 0 and state.kind ~= "Poke" and state.kind ~= "Tether") then return false end
    if self.command == "Pulse" then return state.kind == "Button" end
    if self.command == "GroupAdd" or self.command == "GroupName" or self.command == "GroupMove"
        or self.command == "GroupDelete" or self.command == "DeviceMove" then
        return require("OMHTT/ControlGroups").propose(self) ~= nil
    end
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
            and (self.command ~= "Assign" or (state.kind == "Controller" and state.powered == true))
    elseif self.command == "SetFacing" then
        local target = A.state(self.target)
        return target ~= nil and target.kind == "Turret" and target.id == self.targetId
            and type(self.value) == "number" and self.value >= 0 and self.value < 360
            and A.write(self.character, target)
            and ((self.object == self.target and A.near(self.character, self.target))
                or require("OMHTT/ControlRemote").valid(self.character, self.object, self.target))
    elseif self.command == "TetherEnabled" then
        return state.kind == "Tether" and type(self.value) == "boolean"
    elseif self.command == "ClearInputs" then
        return state.kind == "Turret" or state.kind == "Tether"
    elseif self.command == "Trigger" then
        return state.kind == "Plate" and (self.value == "Both" or self.value == "Players" or self.value == "Zombies")
    elseif self.command == "Pickup" or self.command == "Repair" then
        return state.kind ~= "Turret" and state.kind ~= "Poke"
            and (state.kind ~= "Tether" or (state.enabled == false and not state.active and A.near(self.character, self.object)))
            and (self.command ~= "Repair" or (self.object:getHealth() < self.object:getMaxHealth()
                and require("OMHTT/ControlRepair").ready(self.character, state.kind)))
    end
    return false
end

---@return boolean complete
function Action:complete()
    if not isServer() and self.elapsed < self.seconds then return false end
    if isClient() or not self:isValid() then return false end
    self.done = true
    local W = require("OMHTT/ControlWorld")
    local state = W.state(self.object)
    if self.command == "GroupAdd" or self.command == "GroupName" or self.command == "GroupMove"
        or self.command == "GroupDelete" or self.command == "DeviceMove" then
        state.organization = require("OMHTT/ControlGroups").propose(self)
    elseif self.command == "Pulse" then
        state.pulseUntil = getTimestampMs() + 1
        for i = 1, #state.links do
            local target = W.objects[state.links[i]]
            if target and A.range(self.object, target) then
                W.pulse(target)
            end
        end
    elseif self.command == "Name" then
        state.name = self.value ~= "" and self.value or nil
        W.name(state)
        for i = 1, #state.links do
            local target = W.objects[state.links[i]]
            if target then
                W.publish(target)
            end
        end
    elseif self.command == "Access" then
        local faction = self.value == "Faction" and Faction.getPlayerFaction(self.character)
        if self.value == "Faction" and not faction then return false end
        state.access, state.faction = self.value, faction and faction:getName() or nil
    elseif self.command == "Assign" then
        return W.assign(self.object, self.target, self.character, self.value)
    elseif self.command == "SetFacing" then
        return require("OMHTT/TurretWorld").setFacing(self.target, self.value)
    elseif self.command == "Link" then
        return W.link(self.object, self.target, self.value)
    elseif self.command == "TetherEnabled" then
        state.enabled = self.value
    elseif self.command == "ClearInputs" then
        W.clearInputs(self.object)
    elseif self.command == "Trigger" then
        state.trigger = self.value
    elseif self.command == "Repair" then
        if not require("OMHTT/ControlRepair").consume(self.character, state.kind) then return false end
        self.object:setHealth(self.object:getMaxHealth())
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
    if self.seconds == 0 then return 1 end
    if isClient() or isServer() then return self.seconds * 50 end
    return 480
end

---@return nil
function Action:perform()
    if self.command == "Pulse" and not isServer() then
        self.object:getSquare():playSound("LightSwitch")
    end
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
    local state = A.state(object)
    local profile = state and require("OMHTT/ControlRepair").profiles[state.kind]
    action.seconds = 0
    if profile then
        action.seconds = command == "Pickup" and profile.pickup or (command == "Repair" and profile.seconds or 0)
    end
    action.elapsed = 0
    action.maxTime = action:getDuration()
    return action
end

return Action

