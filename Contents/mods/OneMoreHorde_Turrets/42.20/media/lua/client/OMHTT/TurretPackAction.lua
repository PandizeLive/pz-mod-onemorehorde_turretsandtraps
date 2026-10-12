if isClient() or isServer() then return end
require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISTimedActionQueue")
require("ISUI/ISInventoryPaneContextMenu")
local P = require("OMHTT/TurretModulePack")
local T = require("OMHTT/Turret")
local A = ISBaseTimedAction:derive("OMHTTTurretPackAction")

---@return boolean valid
function A:isValid()
    return not self.done and not self.character:isDead() and T.enabled()
        and self.pack:getContainer() == self.character:getInventory() and self.character:getInventory():contains(self.pack)
end

---@return nil
function A:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Mid")
    self:setOverrideHandModels(nil, nil)
end

---@return number duration Native action budget; completion uses elapsed real time
function A:getDuration()
    return 480
end

---@return nil
function A:update()
    self.elapsed = self.elapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), .25)
    self:setJobDelta(math.min(self.elapsed / 2, .999))
    if self.elapsed >= 2 then
        self:forceComplete()
    end
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

---@return boolean complete
function A:complete()
    if self.elapsed < 2 or not self:isValid() then return false end
    self.done = true
    local rewards = P.open(self.character, self.pack)
    if not rewards then
        self.character:setHaloNote(getText("UI_OMHTT_PackUnavailable"), 255, 255, 255, 120)
        return false
    end
    if require("OMHTT/ClientOptions").packAnimation() then
        require("OMHTT/TurretPackReveal").show(self.character, rewards)
    else
        self.character:setHaloNote(getText("UI_OMHTT_PackReceived", P.COUNT), 255, 255, 255, 120)
    end
    return true
end

---@param character IsoPlayer Operator
---@param pack InventoryItem Exact pack
---@return table action
function A:new(character, pack)
    local o = ISBaseTimedAction.new(self, character)
    o.pack, o.done, o.elapsed = pack, false, 0
    o.stopOnWalk, o.stopOnRun = true, true
    o.maxTime = o:getDuration()
    return o
end

---@param pack InventoryItem Exact selected pack
---@param player IsoPlayer Operator
---@return nil
local function open(pack, player)
    ISInventoryPaneContextMenu.transferIfNeeded(player, pack)
    ISTimedActionQueue.add(A:new(player, pack))
end

---@param index number Player index
---@param context ISContextMenu Inventory context menu
---@param items table Selected item stacks
---@return nil
local function menu(index, context, items)
    if not T.enabled() then return end
    local player = getSpecificPlayer(index)
    if not player or player:isDead() then return end
    for i = 1, #items do
        local item = items[i]
        if not instanceof(item, "InventoryItem") then
            item = item.items[1]
        end
        if item and item:getFullType() == P.TYPE then
            context:addOption(getText("UI_OMHTT_OpenModulePack"), item, open, player)
            return
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(menu)
return A
