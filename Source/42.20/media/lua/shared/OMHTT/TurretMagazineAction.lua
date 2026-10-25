require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local G = require("OMHTT/Firearms")
local D = require("OMHTT/Diagnostics")
local Access = require("OMHTT/TurretAccess")
OMHTTTurretMagazineAction = ISBaseTimedAction:derive("OMHTTTurretMagazineAction")
local Action = OMHTTTurretMagazineAction

---@return string? reason
function Action:rejection()
    if self.done or type(self.id) ~= "string" or not Access.near(self.character, self.object, self.id) then return "TransferReach" end
    return G.magazineRejection(self.character, self.object:getContainer(), self.gun, self.magazine, self)
end

---@return boolean valid
function Action:isValid()
    return self:rejection() == nil
end

---@return boolean turning
function Action:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

---@return nil
function Action:start()
    self.started = true
    if not isClient() then
        G.servicing[self.gun] = self
        G.cancelLoading(self.gun)
    end
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function Action:update()
    self.character:faceThisObject(self.object)
end

---@return nil
function Action:release()
    if G.servicing[self.gun] == self then G.servicing[self.gun] = nil end
end

---@return nil
function Action:stop()
    self.done = true
    self:release()
    local state = T.state(self.object)
    state.transferRevision = (state.transferRevision or 0) + 1
    ISBaseTimedAction.stop(self)
end

---@return nil
function Action:perform()
    self:release()
    ISBaseTimedAction.perform(self)
end

---@return boolean completed
function Action:complete()
    if isClient() then return false end
    local reason = self:rejection()
    if (not isServer() and not self.started) or reason then
        self.done = true
        self:release()
        return false
    end
    local gun = self.gun
    local magazine = G.transferMagazine(self.character, self.object:getContainer(), gun, self.magazine, self)
    if not magazine then
        self:release()
        return false
    end
    self.done = true
    self:release()
    require("OMHTT/TurretWorld").refresh(self.object)
    if isServer() then
        require("OMHTT/TurretAuthority").publish(self.object)
    end
    D.emit("turret-magazine", {gun = gun:getID(), inserted = self.magazine ~= nil,
        rounds = magazine:getCurrentAmmoCount(), chamber = gun:isRoundChambered()}, nil, nil, "turrets")
    return true
end

---@return number duration
function Action:getDuration()
    return self.seconds * 50
end

---@param character IsoPlayer Operator
---@param object IsoObject Turret
---@param magazine InventoryItem? Insert, or eject when nil
---@param gun HandWeapon? Expected exact mounted firearm
---@param id string? Expected turret identity
---@param stockpile boolean? Withdraw to stockpile
---@param controller IsoObject? Exact stockpile
---@return table action
function Action:new(character, object, magazine, gun, id, stockpile, controller)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.magazine, action.stockpile, action.controller = object, magazine, stockpile, controller
    action.gun, action.id = gun, id
    if not isServer() then
        action.gun = gun or T.contents(object:getContainer()).head
        local state = T.state(object)
        action.id = id or (state and state.id)
    end
    action.done = false
    action.seconds = magazine and 1.5 or 1.2
    action.stopOnWalk, action.stopOnRun = true, true
    action.maxTime = action:getDuration()
    return action
end

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@param magazine InventoryItem? Insert, or eject when nil
---@param stockpile boolean? Withdraw to stockpile
---@param controller IsoObject? Exact stockpile
---@return number queued
---@return string? reason
function Action.queue(player, object, magazine, stockpile, controller)
    require("TimedActions/ISTimedActionQueue")
    local action = Action:new(player, object, magazine, nil, nil, stockpile, controller)
    local reason = action:rejection()
    if reason then return 0, reason end
    local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
    for i = 1, #queue do
        if queue[i].omhttMagazine and queue[i].gun == action.gun then return 0, "TransferPending" end
    end
    action.omhttMagazine = true
    ISTimedActionQueue.add(action)
    return 1
end

return Action
