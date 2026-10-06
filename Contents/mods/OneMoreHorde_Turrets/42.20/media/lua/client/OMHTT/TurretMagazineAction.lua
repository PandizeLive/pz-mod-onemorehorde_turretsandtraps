if isClient() or isServer() then return end
require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local G = require("OMHTT/Firearms")
local D = require("OMHTT/Diagnostics")
local Action = ISBaseTimedAction:derive("OMHTTTurretMagazineAction")

---@return string? reason
function Action:rejection()
    local W = require("OMHTT/TurretWorld")
    if self.done or not W.near(self.character, self.object) then return "TransferReach" end
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
    G.servicing[self.gun] = self
    G.cancelLoading(self.gun)
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
    ISBaseTimedAction.stop(self)
end

---@return nil
function Action:perform()
    self:release()
    ISBaseTimedAction.perform(self)
end

---@return boolean completed
function Action:complete()
    local reason = self:rejection()
    if not self.started or reason then
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
    D.emit("turret-magazine", {gun = gun:getID(), inserted = self.magazine ~= nil,
        rounds = magazine:getCurrentAmmoCount(), chamber = gun:isRoundChambered()})
    return true
end

---@return number duration
function Action:getDuration()
    return self.seconds * 50
end

---@param character IsoPlayer Operator
---@param object IsoObject Turret
---@param magazine InventoryItem? Insert, or eject when nil
---@return table action
function Action:new(character, object, magazine)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.magazine = object, magazine
    action.gun = T.contents(object:getContainer()).head
    action.done = false
    action.seconds = magazine and 1.5 or 1.2
    action.stopOnWalk, action.stopOnRun = true, true
    action.maxTime = action:getDuration()
    return action
end

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@param magazine InventoryItem? Insert, or eject when nil
---@return number queued
---@return string? reason
function Action.queue(player, object, magazine)
    local action = Action:new(player, object, magazine)
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
