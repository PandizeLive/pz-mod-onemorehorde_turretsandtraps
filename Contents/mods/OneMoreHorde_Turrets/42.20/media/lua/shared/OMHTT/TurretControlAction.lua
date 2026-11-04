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
    if self.command == "LurePulse" or self.command == "LureRepeat" then
        return contents.active.Lure ~= nil and type(self.value) == "boolean"
    elseif self.command == "LureRange" then
        return contents.active.Lure ~= nil and type(self.value) == "number" and self.value >= 5 and self.value <= 20 and self.value % 1 == 0
    elseif self.command == "LandingRange" then
        local stats = T.cycleConfig(contents)
        return stats.headKind == "Lobber" and type(self.value) == "number" and self.value % 1 == 0
            and self.value >= stats.minimumRange and self.value <= stats.range
    elseif self.command == "AmmoOrder" then
        return require("OMHTT/TurretLoadOrder").valid(self.value, contents, T.state(self.object))
    elseif self.command == "AmmoPlatformOrder" then
        return require("OMHTT/TurretLoadOrder").validGroup(self.value, T.state(self.object))
    elseif self.command == "Reload" then
        return contents.head and self.value == contents.head:getID() and T.isOn(T.state(self.object))
            and require("OMHTT/TurretReload").allowed(contents, T.cycleConfig(contents))
    elseif self.command == "Priority" then
        if not contents.active.Filter then return false end
        for i = 1, #M.PRIORITIES do
            if self.value == M.PRIORITIES[i] then return true end
        end
    elseif self.command == "Power" then
        return type(self.value) == "boolean"
    elseif self.command == "Fire" then
        return self.value == true
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
    if self.command == "Power" then
        return require("OMHTT/TurretWorld").setPower(self.character, self.object, self.value)
    end
    if self.command == "Fire" then
        local result = require("OMHTT/TurretWorld").fire(self.character, self.object)
        if isServer() then
            sendServerCommand(self.character, "OMHTT_TurretControl", "Result", {id = self.id, status = result})
        end
        return true
    end
    local state = T.state(self.object)
    local contents = T.contents(self.object:getContainer())
    if self.command == "LurePulse" then
        require("OMHTT/TurretLure").pulse(self.object, contents, require("OMHTT/TurretClock").now())
    elseif self.command == "LureRepeat" then
        state.lureRepeat = self.value and T.isOn(state)
    elseif self.command == "LureRange" then
        state.lureRange = self.value
    elseif self.command == "LandingRange" then
        state.landingRange = self.value
    elseif self.command == "AmmoOrder" then
        state.ammoOrders = state.ammoOrders or {}
        state.ammoOrders[contents.head:getFullType()] = self.value.order
    elseif self.command == "AmmoPlatformOrder" then
        state.ammoOrders = state.ammoOrders or {}
        state.ammoOrders["@" .. self.value.platform] = self.value.order
    elseif self.command == "Reload" then
        local stats = T.cycleConfig(contents)
        local world = require("OMHTT/TurretWorld")
        if not world.power(self.object, contents, stats) then return false end
        if not require("OMHTT/TurretReload").start(contents, stats, require("OMHTT/TurretClock").now()) then return false end
    elseif self.command == "Priority" then
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
---@param value number|string|boolean|table Requested value
---@return OMHTTTurretControlAction action
function Action:new(character, object, id, command, value)
    local o = ISBaseTimedAction.new(self, character)
    o.object, o.id, o.command, o.value = object, id, command, value
    o.done, o.stopOnWalk, o.stopOnRun = false, true, true
    o.maxTime = o:getDuration()
    return o
end

return Action
