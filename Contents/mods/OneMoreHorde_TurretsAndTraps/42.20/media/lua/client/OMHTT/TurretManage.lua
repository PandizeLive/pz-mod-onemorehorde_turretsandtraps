if isClient() or isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local D = require("OMHTT/Diagnostics")
local Panel = ISPanel:derive("OMHTTTurretPanel")
local OpenAction = ISBaseTimedAction:derive("OMHTTTurretOpenAction")
local active = {}

---@return nil
function Panel:close()
    active[self.player:getPlayerNum()] = nil
    self:removeFromUIManager()
end

---@return nil
function Panel:fire()
    self.result = W.fire(self.player, self.object)
    self.nextRefresh = 0
end

---@return nil
function Panel:prerender()
    if not W.near(self.player, self.object) then self:close(); return end
    ISPanel.prerender(self)
    local now = getTimestampMs()
    if now >= self.nextRefresh then
        self.nextRefresh = now + 100
        local contents = T.contents(self.object:getContainer())
        local cycle, status = T.cycle(contents, now)
        if not W.power(self.object, contents) and contents.head then status = "NoPower" end
        self.status = status
        self.ammo = getText("UI_OMHTT_TurretCycle", contents.ammo, T.option("AmmoCapacity", 85, 1, 500),
            cycle and cycle.loaded or 0, T.option("MagazineCapacity", 1, 1, 500))
        self.fireButton:setEnable(status == "Ready")
    end
    self:drawText(getText("UI_OMHTT_Turret"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(self.ammo or "", 12, 36, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_" .. (self.status or "NoHead")), 12, 58, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_TurretLoadHint"), 12, 80, 0.8, 0.8, 0.8, 1, UIFont.Small)
    if self.result then self:drawText(getText("UI_OMHTT_" .. self.result), 140, 114, 1, 1, 1, 1, UIFont.Small) end
end

---@return nil
function OpenAction:perform()
    if W.near(self.character, self.object) then
        local index = self.character:getPlayerNum()
        local inventory, loot = getPlayerInventory(index), getPlayerLoot(index)
        inventory:setVisible(true)
        loot:setVisible(true)
        inventory:setPinned()
        loot:setPinned()
        loot:refreshBackpacks()
        loot:selectButtonForContainer(self.object:getContainer())
        loot:setForceSelectedContainer(self.object:getContainer(), 2000)
        if active[index] then active[index]:close() end
        local width = math.max(360, getTextManager():MeasureStringX(UIFont.Small, getText("UI_OMHTT_TurretLoadHint")) + 24)
        local panel = Panel:new(getPlayerScreenLeft(index) + 30, getPlayerScreenTop(index) + 300, width, 150)
        panel.player, panel.object, panel.nextRefresh = self.character, self.object, 0
        panel.moveWithMouse = true
        panel:initialise()
        panel:addToUIManager()
        panel.fireButton = ISButton:new(12, 110, 110, 28, getText("ContextMenu_OMHTT_TurretFire"), panel, Panel.fire)
        panel.fireButton:initialise()
        panel:addChild(panel.fireButton)
        local close = ISButton:new(width - 34, 6, 26, 24, "X", panel, Panel.close)
        close:initialise()
        panel:addChild(close)
        active[index] = panel
        D.emit("turret-manage-open", {id = T.state(self.object).id, containerSelected = loot.inventory == self.object:getContainer()})
    end
    ISBaseTimedAction.perform(self)
end

---@return boolean valid
function OpenAction:isValid()
    return W.near(self.character, self.object)
end

---@param player IsoPlayer Operator
---@param object IsoObject Exact turret
---@return table action
function OpenAction:new(player, object)
    local action = ISBaseTimedAction.new(self, player)
    action.object, action.maxTime = object, 1
    return action
end

---@param object IsoObject Exact turret
---@param player IsoPlayer Operator
---@return nil
local function open(object, player)
    if luautils.walkAdjObject(player, object, false) then ISTimedActionQueue.add(OpenAction:new(player, object)) end
end

return open
