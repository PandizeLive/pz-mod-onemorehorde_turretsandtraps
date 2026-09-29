if isClient() or isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local X = require("OMHTT/TurretTransfers")
local Slot = require("OMHTT/TurretSlot")
local Range = require("OMHTT/TurretRange")
local Panel = ISPanel:derive("OMHTTTurretPanel")
local OpenAction = ISBaseTimedAction:derive("OMHTTTurretOpenAction")
local active = {}

---@return nil
function Panel:close()
    for i = 1, #self.slots do self.slots[i]:hideTooltip(); self.slots[i]:clearDrag() end
    Range.focus(self.player:getPlayerNum(), "manage", self.object, false)
    active[self.player:getPlayerNum()] = nil
    self:removeFromUIManager()
    D.emit("turret-manage-close", {id = self.deviceId})
end

---@param count number Queued items
---@param reason string? Rejection
---@return nil
function Panel:feedback(count, reason)
    self.result = getText("UI_OMHTT_ManageQueued", count)
    self.reason = reason and getText("UI_OMHTT_Manage" .. reason) or ""
    self.nextRefresh = 0
end

---@param items table Exact items
---@param incoming boolean Into turret
---@param kind string Slot type
---@return nil
function Panel:transfer(items, incoming, kind)
    local count, reason = X.queue(self.player, self.object, items, incoming, kind)
    self:feedback(count, reason)
end

---@return nil
function Panel:unload()
    self:transfer(self.ammoSlot.items, false, "ammo")
end

---@return nil
function Panel:fire()
    local result = require("OMHTT/TurretWorld").fire(self.player, self.object)
    self.result, self.reason = getText("UI_OMHTT_Manage" .. result), ""
    self.nextRefresh = 0
end

---@param button ISButton Page control
---@return nil
function Panel:page(button)
    self.modulePage = math.max(0, math.min(self.pages - 1, self.modulePage + button.delta))
    self.nextRefresh = 0
end

---@param kind string Item kind
---@param label string Slot label
---@param x number Local X
---@param y number Local Y
---@param width number Width
---@return table slot
function Panel:addSlot(kind, label, x, y, width)
    local slot = Slot:new(self, kind, label, x, y, width, self.slotHeight)
    slot:initialise()
    self:addChild(slot)
    self.slots[#self.slots + 1] = slot
    return slot
end

---@return nil
function Panel:refresh()
    local W = require("OMHTT/TurretWorld")
    local storage = self.object:getContainer()
    local contents = T.contents(storage)
    local cycle, status = T.cycle(contents, getTimestampMs())
    local power = W.power(self.object, contents)
    if not power and contents.head then status = "NoPower" end
    if contents.head and contents.head:getCondition() <= 0 then status = "NoHead" end
    self.status = status
    self.fireButton:setEnable(status == "Ready")
    self.unloadButton:setEnable(contents.ammo > 0)
    local capacity = T.option("ModuleCapacity", 4, 0, 20)
    self.pages = math.max(1, math.ceil(math.max(contents.modules, capacity) / 4))
    self.modulePage = math.min(self.modulePage, self.pages - 1)
    self.previousButton:setEnable(self.modulePage > 0)
    self.nextButton:setEnable(self.modulePage < self.pages - 1)
    for i = 1, #self.slots do self.slots[i].items = {} end
    for i = 1, 4 do
        local number = self.modulePage * 4 + i
        local slot = self.moduleSlots[i]
        slot.disabled = number > capacity
        slot.label = getText("UI_OMHTT_ManageModule", number)
        if number > capacity then slot.label = getText("UI_OMHTT_ManageLocked") end
    end
    local items, modules = storage:getItems(), 0
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local kind = T.kind(item)
        local slot = self.headSlot
        if kind == "battery" then slot = self.batterySlot end
        if kind == "ammo" then slot = self.ammoSlot end
        if kind == "module" then
            modules = modules + 1
            slot = self.moduleSlots[modules - self.modulePage * 4]
        end
        if kind and slot then slot.items[#slot.items + 1] = item end
    end
    self.ammoSlot.label = getText("UI_OMHTT_ManageAmmo", contents.ammo, T.option("AmmoCapacity", 85, 1, 500),
        cycle and cycle.loaded or 0, T.option("MagazineCapacity", 1, 1, 500))
    local charge = getText("UI_OMHTT_None")
    if contents.battery then charge = tostring(math.floor(contents.battery:getCurrentUsesFloat() * 100)) .. "%" end
    self.batterySlot.label = getText("UI_OMHTT_ManageBattery", charge)
    self.moduleLabel = getText("UI_OMHTT_ManageModules", contents.modules, capacity)
    self.powerLabel = getText("UI_OMHTT_ManagePowerNone")
    if power then
        self.powerLabel = getText("UI_OMHTT_ManagePowerExternal")
        if power.kind == "battery" then self.powerLabel = getText("UI_OMHTT_ManagePowerBattery") end
        if power.kind == "disabled" then self.powerLabel = getText("UI_OMHTT_ManagePowerDisabled") end
    end
    if self.lastStatus ~= status then
        D.emit("turret-manage-status", {id = self.deviceId, status = status, ammo = contents.ammo,
            loaded = cycle and cycle.loaded or 0, modules = contents.modules, power = power and power.kind or "none"})
        self.lastStatus = status
    end
end

---@return nil
function Panel:prerender()
    if not require("OMHTT/TurretWorld").near(self.player, self.object) then self:close(); return end
    ISPanel.prerender(self)
    local now = getTimestampMs()
    if now >= self.nextRefresh then
        self.nextRefresh = now + 200
        self:refresh()
    end
    local h, y = self.lineHeight, self.detailsY
    self:drawText(getText("UI_OMHTT_Turret"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(getText("UI_OMHTT_ManageHint"), 12, self.titleHeight, 0.8, 0.8, 0.8, 1, UIFont.Small)
    self:drawText(self.moduleLabel, 12, self.modulesY, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_ManageModulesHint"), 12, y, 0.8, 0.8, 0.8, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_Manage" .. self.status) .. " | " .. self.powerLabel, 12, y + h, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_ManageStats", T.option("Damage", 35, 0, 1000), T.option("Range", 6, 1, 20),
        self.object:getHealth(), self.object:getMaxHealth()), 12, y + h * 2, 1, 1, 1, 1, UIFont.Small)
    local config = T.cycleConfig()
    self:drawText(getText("UI_OMHTT_ManageTiming", config.reload / 1000, config.cooldown / 1000),
        12, y + h * 3, 1, 1, 1, 1, UIFont.Small)
    self:drawText(self.result, 12, y + h * 4, 0.9, 0.85, 0.65, 1, UIFont.Small)
    self:drawText(self.reason, 12, y + h * 5, 0.9, 0.85, 0.65, 1, UIFont.Small)
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Panel:onMouseDown(x, y)
    if y < self.titleHeight then ISPanel.onMouseDown(self, x, y) end
    return true
end

---@return nil
function OpenAction:perform()
    if require("OMHTT/TurretWorld").near(self.character, self.object) then
        local index = self.character:getPlayerNum()
        local inventory = getPlayerInventory(index)
        inventory:setVisible(true)
        inventory:setPinned()
        if active[index] then active[index]:close() end
        local font = getTextManager()
        local lineHeight = font:getFontHeight(UIFont.Small) + 3
        local titleHeight = font:getFontHeight(UIFont.Medium) + 16
        local width = math.min(getPlayerScreenWidth(index) - 24, math.max(600, lineHeight * 29))
        local slotHeight = lineHeight + 48
        local top = titleHeight + lineHeight + 12
        local modulesY = top + (slotHeight + 8) * 2
        local detailsY = modulesY + lineHeight + slotHeight + 12
        local height = detailsY + lineHeight * 6 + 48
        local x = getPlayerScreenLeft(index) + getPlayerScreenWidth(index) - width - 12
        local y = getPlayerScreenTop(index) + math.max(12, (getPlayerScreenHeight(index) - height) / 2)
        local panel = Panel:new(x, y, width, height)
        panel.player, panel.object, panel.nextRefresh = self.character, self.object, 0
        panel.deviceId, panel.slots, panel.moduleSlots = T.state(self.object).id, {}, {}
        panel.modulePage, panel.pages = 0, 1
        panel.lineHeight, panel.titleHeight, panel.slotHeight = lineHeight, titleHeight, slotHeight
        panel.modulesY, panel.detailsY, panel.result, panel.reason = modulesY, detailsY, "", ""
        panel.moveWithMouse = true
        panel.backgroundColor = {r = 0.04, g = 0.04, b = 0.04, a = 0.96}
        panel:initialise()
        panel.headSlot = panel:addSlot("head", getText("UI_OMHTT_ManageHead"), 12, top, (width - 32) / 2)
        panel.batterySlot = panel:addSlot("battery", "", width / 2 + 4, top, (width - 32) / 2)
        panel.ammoSlot = panel:addSlot("ammo", "", 12, top + slotHeight + 8, width - 24)
        local moduleWidth = (width - 48) / 4
        for i = 1, 4 do
            panel.moduleSlots[i] = panel:addSlot("module", "", 12 + (i - 1) * (moduleWidth + 8), modulesY + lineHeight, moduleWidth)
        end
        panel.fireButton = ISButton:new(12, height - 38, 110, 28, getText("UI_OMHTT_ManageFire"), panel, Panel.fire)
        panel.unloadButton = ISButton:new(130, height - 38, 150, 28, getText("UI_OMHTT_ManageUnload"), panel, Panel.unload)
        panel.previousButton = ISButton:new(width - 80, modulesY - 3, 28, lineHeight, "<", panel, Panel.page)
        panel.nextButton = ISButton:new(width - 44, modulesY - 3, 28, lineHeight, ">", panel, Panel.page)
        panel.previousButton.delta, panel.nextButton.delta = -1, 1
        local close = ISButton:new(width - 34, 6, 26, 24, "X", panel, Panel.close)
        local buttons = {panel.fireButton, panel.unloadButton, panel.previousButton, panel.nextButton, close}
        for i = 1, #buttons do buttons[i]:initialise(); panel:addChild(buttons[i]) end
        panel:refresh()
        panel:addToUIManager()
        active[index] = panel
        Range.focus(index, "manage", self.object, true)
        D.emit("turret-manage-open", {id = panel.deviceId, interface = "dedicated", width = width, height = height})
    end
    ISBaseTimedAction.perform(self)
end

---@return boolean valid
function OpenAction:isValid()
    return require("OMHTT/TurretWorld").near(self.character, self.object)
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
