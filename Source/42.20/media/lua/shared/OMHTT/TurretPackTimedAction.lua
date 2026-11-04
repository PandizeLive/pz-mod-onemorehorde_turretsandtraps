require("TimedActions/ISBaseTimedAction")
local P = require("OMHTT/TurretModulePack")
local T = require("OMHTT/Turret")
OMHTTTurretPackAction = ISBaseTimedAction:derive("OMHTTTurretPackAction")
local A = OMHTTTurretPackAction

---@return boolean valid
---@nodiscard
function A:isValid()
    return not self.done and self.pack ~= nil and not self.character:isDead() and T.enabled()
        and self.pack:getFullType() == P.TYPE and self.pack:getContainer() == self.character:getInventory()
        and self.character:getInventory():contains(self.pack)
end

---@return nil
function A:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Mid")
    self:setOverrideHandModels(nil, nil)
end

---@return nil
function A:serverStart()
    require("OMHTT/TurretPackObservers").start(self)
end

---@return nil
function A:serverStop()
    require("OMHTT/TurretPackObservers").stop(self)
end

---@return number duration Native action time; enforced by NetTimedAction on the server
---@nodiscard
function A:getDuration()
    return 100
end

---@return nil
function A:stop()
    self.done = true
    ISBaseTimedAction.stop(self)
end

---@return nil
function A:perform()
    ISBaseTimedAction.perform(self)
end

---@return boolean completed
function A:complete()
    if isServer() then
        require("OMHTT/TurretPackObservers").stop(self)
    end
    if isClient() or not self:isValid() then return false end
    self.done = true
    local rewards = P.open(self.character, self.pack)
    if not rewards then return false end
    local types = {}
    for i = 1, #rewards do
        types[i] = rewards[i]:getFullType()
    end
    if isServer() then
        sendServerCommand(self.character, "OMHTT", "PackOpened", {
            packId = self.pack:getID(), playerId = self.character:getOnlineID(), rewards = types,
        })
    else
        require("OMHTT/TurretPackAction").present(self.character, types)
    end
    return true
end

---@param character IsoPlayer Operator
---@param pack InventoryItem Exact pack; top-level argument survives native serialization
---@return OMHTTTurretPackAction action
function A:new(character, pack)
    local o = ISBaseTimedAction.new(self, character)
    o.pack, o.done = pack, false
    o.stopOnWalk, o.stopOnRun = true, true
    o.maxTime = o:getDuration()
    return o
end

return A
