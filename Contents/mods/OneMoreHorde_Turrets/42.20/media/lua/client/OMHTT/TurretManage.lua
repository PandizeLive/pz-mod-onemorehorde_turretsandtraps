if isClient() or isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("RadioCom/ISUIRadio/ISSliderPanel")
require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local X = require("OMHTT/TurretTransfers")
local G = require("OMHTT/Firearms")
local Magazine = require("OMHTT/TurretMagazineAction")
local Slot = require("OMHTT/TurretSlot")
local Range = require("OMHTT/TurretRange")
local Benefits = require("OMHTT/TurretBenefits")
local BenefitList = require("OMHTT/TurretBenefitList")
local Search = require("OMHTT/TurretSearch")
local Panel = ISPanel:derive("OMHTTTurretPanel")
local OpenAction = ISBaseTimedAction:derive("OMHTTTurretOpenAction")
local active = {}

---@return nil
function Panel:close()
    self.benefitList:hideTooltip()
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

---@param item InventoryItem? Insert this magazine, or eject when nil
---@return nil
function Panel:magazine(item)
    local count, reason = Magazine.queue(self.player, self.object, item)
    self:feedback(count, reason)
end

---@return nil
function Panel:fire()
    local result = require("OMHTT/TurretWorld").fire(self.player, self.object)
    self.result, self.reason = getText("UI_OMHTT_Manage" .. result), ""
    self.nextRefresh = 0
end

---@return nil
function Panel:togglePower()
    require("OMHTT/TurretWorld").setPower(self.player, self.object, not T.isOn(T.state(self.object)))
    self.nextRefresh = 0
end

---@return nil
function Panel:changePriority()
    local W = require("OMHTT/TurretWorld")
    if not W.near(self.player, self.object) then return end
    local contents = T.contents(self.object:getContainer())
    if not contents.active.Filter then return end
    local state = T.state(self.object)
    local priority = M.profile(state, contents).priority
    for i = 1, #M.PRIORITIES do
        if priority == M.PRIORITIES[i] then
            state.priority = M.PRIORITIES[i % #M.PRIORITIES + 1]
            break
        end
    end
    W.refresh(self.object)
    self.nextRefresh = 0
    D.emit("turret-priority", {id = state.id, priority = state.priority})
end

---@param value number Slider tile value
---@return nil
function Panel:changeRange(value)
    local W = require("OMHTT/TurretWorld")
    if not W.near(self.player, self.object) then return end
    local state = T.state(self.object)
    state.engagementRange = value < self.rangeMaximum and math.floor(value) or nil
    W.queueRefresh(self.object, true)
    self.engagementRange = value
    self.nextRefresh = 0
end

---@param delta number Wheel direction
---@return boolean handled
function Panel:scrollModules(delta)
    self.moduleRow = math.max(0, math.min(self.rows - 3, self.moduleRow + (delta > 0 and 1 or -1)))
    self.nextRefresh = 0
    return true
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
function Panel:drawPower()
    ISButton.prerender(self)
    local cx, cy = self.width / 2, self.height / 2
    for i = 0, 28 do
        local angle = math.rad(55 + i * 250 / 28)
        self:drawRect(cx + math.sin(angle) * 12 - 1, cy - math.cos(angle) * 12 - 1, 3, 3, 1, 1, 1, 1)
    end
    self:drawRect(cx - 1, cy - 16, 3, 14, 1, 1, 1, 1)
end

---@return nil
function Panel:refresh()
    local W = require("OMHTT/TurretWorld")
    local storage = self.object:getContainer()
    local contents = T.contents(storage)
    local stats = T.cycleConfig(contents)
    local cycle, status = T.cycle(contents, require("OMHTT/TurretClock").now(), stats)
    local power = W.power(self.object, contents, stats)
    if not power and contents.head then status = "NoPower" end
    if contents.head and contents.head:getCondition() <= 0 then status = "NoHead" end
    if not T.isOn(T.state(self.object)) then status = "Off" end
    self.status = status
    local response = Search.results[self.object]
    if response and self.searchResponse ~= response then
        self.searchResponse = response
        self.result, self.reason = getText("UI_OMHTT_Manage" .. response.status), ""
    end
    local state = T.state(self.object)
    local profile = M.profile(state, contents, false, stats)
    self.benefitList.rows = Benefits.rows(contents, stats)
    self.batterySlot.detailText = Benefits.battery(contents, stats)
    self.stats = stats
    self.engagementRange = profile.range
    if self.rangeMaximum ~= math.max(2, math.ceil(stats.range)) then
        self.rangeMaximum = math.max(2, math.ceil(stats.range))
        self.rangeSlider:setValues(1, self.rangeMaximum, 1, 5, true)
    end
    if not self.rangeSlider.dragInside then
        self.rangeSlider:setCurrentValue(state.engagementRange and math.min(state.engagementRange, self.rangeMaximum) or self.rangeMaximum, true)
    end
    local powered = T.isOn(state)
    self.powerButton:setTitle("")
    self.powerButton.tooltip = getText(powered and "UI_OMHTT_PowerOn" or "UI_OMHTT_PowerOff")
    self.powerButton.backgroundColor = powered and {r = 0.08, g = 0.42, b = 0.16, a = 0.9} or {r = 0.48, g = 0.08, b = 0.08, a = 0.9}
    self.powerButton.backgroundColorMouseOver = powered and {r = 0.12, g = 0.58, b = 0.22, a = 1} or {r = 0.65, g = 0.12, b = 0.12, a = 1}
    local automationAllowed = SandboxVars.OMHTurretsTraps.AutomationEnabled ~= false
    self.priorityButton:setTitle(getText("UI_OMHTT_Priority", getText("UI_OMHTT_Priority" .. profile.priority)))
    self.priorityButton:setEnable(contents.active.Filter ~= nil)
    local active = {}
    for name in pairs(M.CORE) do
        if contents.active[name] and name ~= "FiringImprovised" and name ~= "MotionDetectionImprovised" then
            active[#active + 1] = contents.active[name]
        end
    end
    self.moduleEffects = getText("UI_OMHTT_ActiveModules", #active, profile.cone)
    if contents.active.MotionDetectionImprovised or contents.active.FiringImprovised then
        self.moduleEffects = self.moduleEffects .. " | " .. getText("UI_OMHTT_ImprovisedStatus",
            string.format("%.1f", M.profile(state, contents, true).range))
    end
    self.fireButton:setEnable(status == "Ready")
    local capacity = stats.modules
    self.rows = 3 + math.ceil(math.max(0, math.max(contents.modules, capacity) - 16) / 6)
    self.moduleRow = math.min(self.moduleRow, self.rows - 3)
    for i = 1, #self.slots do self.slots[i].items = {} end
    for i = 1, 16 do
        local number = self.moduleRow * 6 + i
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
        if kind == "capacity" then slot = self.capacitySlot end
        if kind == "module" then
            modules = modules + 1
            slot = self.moduleSlots[modules - self.moduleRow * 6]
        end
        if kind and slot then slot.items[#slot.items + 1] = item end
    end
    local loaded = stats.firearm and G.loaded(contents.head) or 0
    self.ammoSlot.label = getText("UI_OMHTT_ManageReserve", contents.reserveAll + loaded, stats.ammo)
    local gun = stats.firearm and contents.head or nil
    local magazineType = gun and gun:getMagazineType()
    self.magazineSlot.disabled = not magazineType
    self.magazineSlot.emptyText = getText(contents.head and "UI_OMHTT_ManageInternal" or "UI_OMHTT_ManageNotNeeded")
    self.magazineSlot.label = getText("UI_OMHTT_ManageMagazine", cycle and cycle.loaded or 0, stats.magazine)
    if magazineType then
        self.magazineSlot.emptyText = getText("UI_OMHTT_ManageDrop")
        local chamber = gun:isRoundChambered() and "+1" or ""
        self.magazineSlot.label = getText("UI_OMHTT_ManageMagazine", tostring(gun:getCurrentAmmoCount() + require("OMHTT/FirearmFeed").count(gun)) .. chamber, stats.magazine)
        if gun:isContainsClip() then
            if not self.magazineIcon or self.magazineIcon:getFullType() ~= magazineType then
                self.magazineIcon = instanceItem(magazineType)
            end
            self.magazineIcon:setCurrentAmmoCount(gun:getCurrentAmmoCount())
            self.magazineSlot.items[1] = self.magazineIcon
        end
    end
    self.headSlot.missing = not contents.head or contents.head:getCondition() <= 0
    self.batterySlot.missing = contents.head ~= nil and not power
    self.ammoSlot.missing = contents.head ~= nil and contents.ammo == 0
    self.magazineSlot.missing = magazineType ~= nil and not gun:isContainsClip()
    local missing = {}
    if T.isOn(state) and automationAllowed and contents.head and (contents.active.MotionDetection or contents.active.Firing) then
        if not contents.active.MotionDetection then missing[#missing + 1] = getText("UI_OMHTT_ModuleMotionDetection") end
        if not contents.active.Firing then missing[#missing + 1] = getText("UI_OMHTT_ModuleFiring") end
    end
    self.modulesMissing = #missing > 0
    if self.modulesMissing then self.moduleEffects = getText("UI_OMHTT_ManageMissing", table.concat(missing, ", ")) end
    if (contents.active.Piercing or 0) > 0 and stats.piercing == 0 then
        self.moduleEffects = self.moduleEffects .. " | " .. getText("UI_OMHTT_PiercingInactive")
    end
    local charge = getText("UI_OMHTT_None")
    if contents.battery then charge = tostring(math.floor(contents.battery:getCurrentUsesFloat() * 100)) .. "%" end
    self.batterySlot.label = getText("UI_OMHTT_ManageBattery", charge)
    self.capacitySlot.disabled = contents.capacities > 0
    self.moduleLabel = getText("UI_OMHTT_ManageModules", contents.modules, capacity)
    self.powerLabel = getText("UI_OMHTT_ManagePowerNone")
    if power then
        self.powerLabel = getText("UI_OMHTT_ManagePowerExternal")
        if power.kind == "battery" then self.powerLabel = getText("UI_OMHTT_ManagePowerBattery") end
        if power.kind == "disabled" then self.powerLabel = getText("UI_OMHTT_ManagePowerDisabled") end
    end

    local statKey = table.concat({stats.damage, stats.range, stats.reload, stats.cooldown, stats.ammo, stats.modules, stats.knockdown, stats.accuracy, stats.critChance, stats.critMultiplier, stats.hearingMultiplier, stats.batteryPercent, stats.generatorFuel}, ":")
    if self.lastStatKey ~= statKey then
        D.emit("turret-effective-stats", {id = self.deviceId, damage = stats.damage, range = stats.range,
            reload = stats.reload, cooldown = stats.cooldown, ammoCapacity = stats.ammo, moduleCapacity = stats.modules,
            knockdown = stats.knockdown, autoloader = stats.autoloader, accuracy = stats.accuracy, critChance = stats.critChance, critMultiplier = stats.critMultiplier, hearingMultiplier = stats.hearingMultiplier, batteryPercent = stats.batteryPercent, generatorFuel = stats.generatorFuel})
        self.lastStatKey = statKey
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
    local label = self.moduleLabel
    if self.rows > 3 then label = label .. " — " .. getText("UI_OMHTT_ManageScroll") end
    self:drawText(label, 12, self.modulesY, 1, 1, 1, 1, UIFont.Small)
    self:setStencilRect(12, y, self.width / 2 - 18, h * 7)
    self:drawText(self.moduleEffects, 12, y, self.modulesMissing and 1 or 0.8, self.modulesMissing and 0.3 or 0.8, self.modulesMissing and 0.3 or 0.8, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_Manage" .. self.status) .. " | " .. self.powerLabel, 12, y + h, 1, 1, 1, 1, UIFont.Small)
    local stats = self.stats
    self:drawText(getText("UI_OMHTT_CompactStats", string.format("%.1f", stats.damage), string.format("%.1f", stats.range),
        self.object:getHealth(), self.object:getMaxHealth()), 12, y + h * 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_ManageTiming", string.format("%.2f", stats.reload / 1000), string.format("%.2f", 1000 / stats.cooldown)),
        12, y + h * 3, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_CompactChances", string.format("%.0f", stats.accuracy), string.format("%.0f", stats.critChance),
        string.format("%.1f", stats.critMultiplier)), 12, y + h * 4, 1, 1, 1, 1, UIFont.Small)
    local message = self.result .. ":" .. self.reason
    if self.lastMessage ~= message then
        self.lastMessage, self.messageAt = message, now
    end
    local elapsed = now - self.messageAt
    local glow = 0
    if elapsed < 1500 then glow = (1 - elapsed / 1500) * (0.5 + 0.5 * math.cos(elapsed / 120)) end
    self:drawText(self.result, 12, y + h * 5, 0.9 + glow * 0.1, 0.85 + glow * 0.15, 0.65 + glow * 0.35, 1, UIFont.Small)
    self:drawText(self.reason, 12, y + h * 6, 0.9 + glow * 0.1, 0.85 + glow * 0.15, 0.65 + glow * 0.35, 1, UIFont.Small)
    self:clearStencilRect()
    self:drawText(getText("UI_OMHTT_EngagementRange", T.state(self.object).engagementRange and string.format("%.1f", self.engagementRange) or getText("UI_OMHTT_RangeMax")),
        12, y + h * 7, 1, 1, 1, 1, UIFont.Small)
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
        if active[index] then active[index]:close() end
        local font = getTextManager()
        local lineHeight = font:getFontHeight(UIFont.Small) + 3
        local titleHeight = font:getFontHeight(UIFont.Medium) + 16
        local width = math.min(getPlayerScreenWidth(index) - 24, math.max(640, lineHeight * 32))
        local slotHeight = lineHeight + 48
        local top = titleHeight + lineHeight + 12
        local moduleHeight = lineHeight * 2 + 24
        local available = getPlayerScreenHeight(index) - 24
        local preferred = top + (slotHeight + 8) * 2 + lineHeight + (moduleHeight + 6) * 3 + 6 + lineHeight * 8 + 82
        local trim = math.max(0, preferred - available)
        local slotTrim = math.min(24, trim / 5)
        slotHeight = slotHeight - slotTrim
        moduleHeight = moduleHeight - math.min(12, math.max(0, trim - slotTrim * 2) / 3)
        local modulesY = top + (slotHeight + 8) * 2
        local detailsY = modulesY + lineHeight + (moduleHeight + 6) * 3 + 6
        local height = detailsY + lineHeight * 8 + 82
        local x = getPlayerScreenLeft(index) + getPlayerScreenWidth(index) - width - 12
        local y = getPlayerScreenTop(index) + math.max(12, (getPlayerScreenHeight(index) - height) / 2)
        local panel = Panel:new(x, y, width, height)
        panel.player, panel.object, panel.nextRefresh = self.character, self.object, 0
        panel.deviceId, panel.slots, panel.moduleSlots = T.state(self.object).id, {}, {}
        panel.moduleRow, panel.rows = 0, 3
        panel.lineHeight, panel.titleHeight, panel.slotHeight = lineHeight, titleHeight, slotHeight
        panel.modulesY, panel.detailsY, panel.result, panel.reason = modulesY, detailsY, "", ""
        panel.moveWithMouse = true
        panel.backgroundColor = {r = 0.04, g = 0.04, b = 0.04, a = 0.96}
        panel:initialise()
        panel.benefitList = BenefitList:new(width / 2 + 4, detailsY, width / 2 - 16, lineHeight * 7, lineHeight)
        panel.benefitList:initialise()
        panel:addChild(panel.benefitList)
        panel.rangeSlider = ISSliderPanel:new(width / 2, detailsY + lineHeight * 7 - 3, width / 2 - 12, 24, panel, Panel.changeRange)
        panel.rangeSlider:initialise()
        panel.rangeSlider.toolTipText = getText("UI_OMHTT_RangeTooltip")
        panel:addChild(panel.rangeSlider)
        panel.headSlot = panel:addSlot("head", getText("UI_OMHTT_ManageHead"), 12, top, (width - 32) / 2)
        panel.batterySlot = panel:addSlot("battery", "", width / 2 + 4, top, (width - 32) / 2 - 88)
        panel.powerButton = ISButton:new(width - 92, top, 80, panel.slotHeight, "", panel, Panel.togglePower)
        panel.powerButton.prerender = Panel.drawPower
        local storageWidth = width - 40
        panel.ammoSlot = panel:addSlot("ammo", "", 12, top + slotHeight + 8, storageWidth * 0.38)
        panel.magazineSlot = panel:addSlot("magazine", "", 20 + storageWidth * 0.38, top + slotHeight + 8, storageWidth * 0.30)
        panel.capacitySlot = panel:addSlot("capacity", getText("UI_OMHTT_ManageCapacity"), 28 + storageWidth * 0.68, top + slotHeight + 8, storageWidth * 0.32)
        local moduleWidth = (width - 54) / 6
        for i = 1, 16 do
            local row = i <= 4 and 0 or 1 + math.floor((i - 5) / 6)
            local column = i <= 4 and i or (i - 5) % 6
            panel.moduleSlots[i] = panel:addSlot("module", "", 12 + column * (moduleWidth + 6),
                modulesY + lineHeight + row * (moduleHeight + 6), moduleWidth)
            panel.moduleSlots[i]:setHeight(moduleHeight)
        end
        panel.priorityButton = ISButton:new(130, height - 38, width - 142, 28, "", panel, Panel.changePriority)
        panel.fireButton = ISButton:new(12, height - 38, 110, 28, getText("UI_OMHTT_ManageFire"), panel, Panel.fire)
        local close = ISButton:new(width - 34, 6, 26, 24, "X", panel, Panel.close)
        local buttons = {panel.fireButton, panel.powerButton, panel.priorityButton, close}
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
