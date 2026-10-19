if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("RadioCom/ISUIRadio/ISSliderPanel")
require("TimedActions/ISBaseTimedAction")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local X = require(isClient() and "OMHTT/TurretNetworkTransfers" or "OMHTT/TurretTransfers")
local Access = require("OMHTT/TurretAccess")
local View = require("OMHTT/TurretNetworkView")
local G = require("OMHTT/Firearms")
local Magazine = require("OMHTT/TurretMagazineAction")
local Slot = require("OMHTT/TurretSlot")
local Hint = require("OMHTT/SlotHint")
local Range = require("OMHTT/TurretRange")
local Benefits = require("OMHTT/TurretBenefits")
local BenefitList = require("OMHTT/TurretBenefitList")
local Rarity = require("OMHTT/TurretRarity")
local Search
if not isClient() then
    Search = require("OMHTT/TurretSearch")
end
local Panel = ISPanel:derive("OMHTTTurretPanel")
local OpenAction = ISBaseTimedAction:derive("OMHTTTurretOpenAction")
local active = {}
local Drag = require("OMHTT/ControlWindowDrag")
Panel.onMouseDown = Drag.start
Panel.onMouseUp = Drag.stop
Panel.onMouseUpOutside = Drag.stop
Panel.update = Drag.update
local Utilities = require("OMHTT/TurretUtilities")
Panel.storeVoid = Utilities.store
Panel.inspectVoid = Utilities.inspect

---@return nil
function Panel:close()
    self.closed = true
    if self.cursor then
        getCell():setDrag(nil, self.player:getPlayerNum())
    end
    require("OMHTT/WindowGeometry").close(self)
    self.nameEntry:commit()
    Drag.stop(self)
    if self.orderPanel then
        self.orderPanel:close()
    end
    if self.voidList then self.voidList:onMouseDown() end
    self.benefitList:hideTooltip()
    for i = 1, #self.headerHelp do
        local control = self.headerHelp[i]
        if control.tooltipUI then
            control.tooltipUI:removeFromUIManager()
            control.tooltipUI = nil
        end
    end
    for i = 1, #self.slots do self.slots[i]:hideTooltip(); self.slots[i]:clearDrag() end
    if Range then
        Range.focus(self.player:getPlayerNum(), "manage", self.object, false)
    end
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
---@param replaced InventoryItem? Exact occupied module slot
---@return nil
function Panel:transfer(items, incoming, kind, replaced)
    if incoming and kind == "module" and replaced then
        if #items ~= 1 then self:feedback(0, "SwapFailed"); return end
        local Swap = require("OMHTT/TurretModuleSwap")
        local action = Swap:new(self.player, self.object, items[1], replaced, self.deviceId, self.controller)
        if not action:isValid() then self:feedback(0, "SwapFailed"); return end
        ISTimedActionQueue.add(action)
        self:feedback(1)
        return
    end
    local route = self.controller and require("OMHTT/TurretNetworkTransfers") or X
    local count, reason = route.queue(self.player, self.object, items, incoming, kind, self.toStockpile, self.controller)
    self:feedback(count, reason)
end

---@param item InventoryItem? Insert this magazine, or eject when nil
---@return nil
function Panel:magazine(item)
    local count, reason = Magazine.queue(self.player, self.object, item, self.toStockpile, self.controller)
    self:feedback(count, reason)
end

---@return nil
function Panel:fire()
    if isClient() then
        View.control(self.player, self.object, "Fire", true)
        return
    end
    local result = require("OMHTT/TurretWorld").fire(self.player, self.object)
    self.result, self.reason = getText("UI_OMHTT_Manage" .. result), ""
    self.nextRefresh = 0
end

---@return nil
function Panel:togglePower()
    if isClient() then
        View.control(self.player, self.object, "Power", not T.isOn(T.state(self.object)))
        return
    end
    require("OMHTT/TurretWorld").setPower(self.player, self.object, not T.isOn(T.state(self.object)))
    self.nextRefresh = 0
end

---@return nil
function Panel:changePriority()
    if not Access.near(self.player, self.object) then return end
    local contents = T.contents(self.object:getContainer())
    if not contents.active.Filter then return end
    local state = T.state(self.object)
    local priority = M.profile(state, contents).priority
    for i = 1, #M.PRIORITIES do
        if priority == M.PRIORITIES[i] then
            if isClient() then
                View.control(self.player, self.object, "Priority", M.PRIORITIES[i % #M.PRIORITIES + 1])
                return
            end
            state.priority = M.PRIORITIES[i % #M.PRIORITIES + 1]
            break
        end
    end
    require("OMHTT/TurretWorld").refresh(self.object)
    self.nextRefresh = 0
    D.emit("turret-priority", {id = state.id, priority = state.priority})
end

---@param value number Slider tile value
---@return nil
function Panel:changeRange(value)
    if isClient() then
        self.pendingRange = value < self.rangeMaximum and math.floor(value) or 0
        return
    end
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
    local storage = self.object:getContainer()
    local contents = T.contents(storage)
    local stats = T.cycleConfig(contents)
    local cycle, status, power
    if isClient() then
        cycle, status = View.cycle(contents)
        power = View.power(self.object, contents, stats)
        local result = View.result
        if result and result.id == self.deviceId and getTimestampMs() - result.at < 3000 then
            self.result = getText("UI_OMHTT_Manage" .. result.status)
        end
        if self.pendingRange ~= nil and not self.rangeSlider.dragInside then
            View.control(self.player, self.object, "Range", self.pendingRange)
            self.pendingRange = nil
        end
    else
        cycle, status = T.cycle(contents, require("OMHTT/TurretClock").now(), stats)
        power = require("OMHTT/TurretWorld").power(self.object, contents, stats)
    end
    if not power and contents.head then status = "NoPower" end
    if contents.head and contents.head:getCondition() <= 0 then status = "NoHead" end
    if not T.isOn(T.state(self.object)) then status = "Off" end
    self.status = status
    local response = Search and Search.results[self.object]
    if response and self.searchResponse ~= response then
        self.searchResponse = response
        self.result, self.reason = getText("UI_OMHTT_Manage" .. response.status), ""
    end
    local state = T.state(self.object)
    local profile = M.profile(state, contents, false, stats)
    local signature = {contents.head and contents.head:getID() or 0, contents.head and contents.head:getCondition() or 0}
    for name, entry in pairs(contents.moduleDetails) do
        signature[#signature + 1] = name .. ":" .. entry.count .. ":" .. (contents.active[name] or 0)
    end
    table.sort(signature, function(a, b) return tostring(a) < tostring(b) end)
    local benefitsKey = table.concat(signature, "|")
    if self.benefitsKey ~= benefitsKey then
        self.benefitsKey = benefitsKey
        self.benefitList.rows = Benefits.rows(contents, stats)
    end
    self.batteryContents = contents
    local batteryKey = benefitsKey .. ":" .. (contents.battery and require("OMHTT/TurretBattery").charge(contents.battery) or 0)
        .. ":" .. stats.batteryPercent .. ":" .. stats.reload .. ":" .. stats.cooldown .. ":" .. stats.magazine
        .. ":" .. getGameTime():getMinutesPerDay()
        .. ":" .. (cycle and cycle.loaded or 0) .. ":" .. (cycle and cycle.conservationDebt or 0)
    if batteryKey ~= self.batteryKey then self.batteryKey, self.batteryText = batteryKey, nil end
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
    require("OMHTT/ControlTheme").power(self.powerButton, powered, not self.readOnly)
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
    for i = 1, #self.slots do self.slots[i].items, self.slots[i].rarity = {}, nil end
    for i = 1, 16 do
        local number = self.moduleRow * 6 + i
        local slot = self.moduleSlots[i]
        slot.disabled = number > capacity
        slot.label = ""
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
        if kind and slot then
            slot.items[#slot.items + 1] = item
            if kind == "module" or kind == "capacity" then slot.rarity = Rarity.get(T.component(item:getFullType())) end
        end
    end
    local ordered = require("OMHTT/TurretModuleSwap").modules(self.object)
    for i = 1, #self.moduleSlots do
        local slot = self.moduleSlots[i]
        local item = ordered[self.moduleRow * 6 + i]
        slot.items = item and {item} or {}
        slot.rarity = item and Rarity.get(T.component(item:getFullType())) or nil
    end
    local loaded = stats.firearm and G.loaded(contents.head) or 0
    local physicalLimit, freeWeight = require("OMHTT/TurretCapacity").limit(storage, contents, stats)
    self.ammoSlot.detailText = getText("UI_OMHTT_AmmoPhysical", stats.ammo, physicalLimit, string.format("%.1f", freeWeight))
    self.headSlot.detailText = contents.head and require("OMHTT/TurretHeadDescription").get(contents.head, true, stats) or getText("UI_OMHTT_EmptyHeadHint")
    self.ammoSlot.label = getText("UI_OMHTT_ManageReserve", contents.reserveAll, physicalLimit)
    local gun = stats.firearm and contents.head or nil
    local magazineType = gun and gun:getMagazineType()
    self.magazineSlot.disabled = not magazineType
    self.magazineSlot.emptyText = getText(contents.head and "UI_OMHTT_ManageInternal" or "UI_OMHTT_ManageNotNeeded")
    self.magazineSlot.label = getText("UI_OMHTT_ManageMagazine", cycle and cycle.loaded or 0, stats.magazine)
    if magazineType then
        self.magazineSlot.emptyText = getText("UI_OMHTT_ManageDrop")
        local chamber = gun:isRoundChambered() and "+1" or ""
        if not (cycle and cycle.virtual) then
            self.magazineSlot.label = getText("UI_OMHTT_ManageMagazine", tostring(gun:getCurrentAmmoCount() + require("OMHTT/FirearmFeed").count(gun)) .. chamber, stats.magazine)
        end
        if gun:isContainsClip() then
            if not self.magazineIcon or self.magazineIcon:getFullType() ~= magazineType then
                self.magazineIcon = instanceItem(magazineType)
            end
            self.magazineIcon:setCurrentAmmoCount(gun:getCurrentAmmoCount())
            self.magazineSlot.items[1] = self.magazineIcon
        end
    end
    self.voidSlot.disabled = contents.void == nil
    if not magazineType and cycle and cycle.payload then
        local script = getScriptManager():getItem(cycle.payload)
        self.magazineSlot.emptyText = script and script:getDisplayName() or cycle.payload
    end
    self.voidSlot.label = getText("UI_OMHTT_Void") .. ": " .. tostring(contents.virtualAmmo)
    local rows = require("OMHTT/TurretLoadOrder").rows(contents, state, nil, true)
    local firstAmmo, firstVoid, ammoTypes = nil, nil, 0
    for i = 1, #rows do
        if rows[i].physical > 0 then
            ammoTypes = ammoTypes + 1
            firstAmmo = firstAmmo or rows[i].type
        end
        if rows[i].virtual > 0 then
            firstVoid = firstVoid or rows[i].type
        end
    end
    local _, voidTypes = require("OMHTT/TurretVoid").preview(contents.void, contents.head)
    ---@param fullType string? Ammunition identity
    ---@return string name
    local function label(fullType)
        local script = fullType and getScriptManager():getItem(fullType)
        return script and script:getDisplayName() or getText("UI_OMHTT_None")
    end
    self.ammoSlot.summary = getText("UI_OMHTT_NextLoad", label(firstAmmo))
    self.ammoSlot.subtext = getText("UI_OMHTT_AmmoTypes", ammoTypes)
    self.voidSlot.summary = getText("UI_OMHTT_NextLoad", label(firstVoid))
    self.voidSlot.subtext = getText("UI_OMHTT_AmmoTypes", voidTypes)
    local nextShot = cycle and cycle.loaded and cycle.loaded > 0 and (cycle.payload or contents.payloadType)
    self.magazineSlot.summary = getText("UI_OMHTT_NextShot", label(nextShot))
    self.magazineSlot.subtext = nil
    local ammoHint = contents.head and not stats.rotary and contents.payloadType or nil
    if stats.headKind == "Lobber" and not require("OMHTT/TurretAmmo").bombs[ammoHint] then
        ammoHint = require("OMHTT/TurretFeed").BOMBS[1]
    end
    Hint.set(self.ammoSlot, not firstAmmo and ammoHint or nil)
    Hint.set(self.voidSlot, contents.void and not firstVoid and ammoHint or nil)
    Hint.set(self.magazineSlot, magazineType and not gun:isContainsClip() and magazineType or nil)
    if not contents.head then
        self.ammoSlot.summary = getText("UI_OMHTT_ManageNoHead")
    elseif not magazineType and not stats.rotary then
        self.magazineSlot.subtext = getText("UI_OMHTT_ManageInternal")
    end
    if not contents.void then
        self.voidSlot.summary = getText("UI_OMHTT_VoidRequired")
        self.voidSlot.subtext = nil
    end
    self.loadOrderButton:setEnable(true)
    self.reloadButton:setEnable(power ~= nil and T.isOn(state) and require("OMHTT/TurretReload").allowed(contents, stats))
    self.voidSlot.detailText = require("OMHTT/TurretVoid").description(contents.void, contents.head, true)
    require("OMHTT/TurretManageExtras").refresh(self, contents, stats)
    self.ammoSlot.meter = math.min(1, contents.reserveAll / math.max(1, stats.ammo - loaded))
    self.magazineSlot.meter = math.min(1, (cycle and cycle.loaded or 0) / math.max(1, stats.magazine))
    self.batterySlot.meter = contents.battery and require("OMHTT/TurretBattery").charge(contents.battery) or 0
    self.headSlot.missing = not contents.head or contents.head:getCondition() <= 0
    self.batterySlot.missing = contents.head ~= nil and not power
    self.ammoSlot.missing = contents.head ~= nil and not stats.rotary and contents.ammo == 0
    self.ammoSlot.disabled = stats.rotary
    if stats.rotary then
        self.ammoSlot.label = getText("UI_OMHTT_ManageNotNeeded")
        self.magazineSlot.label = getText("UI_OMHTT_ManageNotNeeded")
    end
    local revision = state.transferRevision or 0
    local changed = self.transferRevision ~= nil and self.transferRevision ~= revision
    for i = 1, #self.slots do
        local slot = self.slots[i]
        local key = tostring(slot.items[1] and slot.items[1]:getID() or 0) .. ":" .. #slot.items
        if slot == self.voidSlot then
            key = tostring(contents.virtualAmmo)
        elseif slot == self.magazineSlot then
            key = key .. ":" .. tostring(cycle and cycle.loaded or 0)
        end
        if changed and slot.itemKey ~= key then
            slot.pulseUntil = getTimestampMs() + 250
        end
        slot.itemKey = key
    end
    self.transferRevision = revision
    self.magazineSlot.missing = magazineType ~= nil and not gun:isContainsClip()
    self.modulesMissing = false
    if contents.active.Firing and not contents.active.MotionDetection then
        self.moduleEffects = self.moduleEffects .. " | " .. getText("UI_OMHTT_FixedFacing")
    elseif contents.active.MotionDetection and not contents.active.Firing then
        self.moduleEffects = self.moduleEffects .. " | " .. getText("UI_OMHTT_TrackingOnly")
    end
    self.moduleWarning = ""
    if (contents.active.Piercing or 0) > 0 and stats.piercing == 0 then
        self.moduleWarning = getText("UI_OMHTT_PiercingInactive")
    end
    self.moduleLines = getTextManager():WrapText(UIFont.Small, self.moduleEffects
        .. (self.moduleWarning ~= "" and "\n" .. self.moduleWarning or ""), self.width - 48)
    local charge = getText("UI_OMHTT_None")
    if contents.battery then charge = tostring(math.floor(require("OMHTT/TurretBattery").charge(contents.battery) * 100)) .. "%" end
    self.batterySlot.label = getText("UI_OMHTT_ManageBattery", charge)
    self.capacitySlot.disabled = self.capacitySlot.items[1] ~= nil and not T.canRemove(storage, self.capacitySlot.items[1])
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
    if not Access.near(self.player, self.object, self.deviceId, true) then self:close(); return end
    ISPanel.prerender(self)
    local now = getTimestampMs()
    if now >= self.nextRefresh then
        self.nextRefresh = now + 200
        self:refresh()
        require("OMHTT/ControlManage").refresh(self)
    end
    require("OMHTT/TurretManageLayout").refresh(self)
    require("OMHTT/TurretManageLayout").page(self)
    require("OMHTT/TurretManageLayout").draw(self)
end

---@param delta number Scroll direction
---@return boolean handled
function Panel:onMouseWheel(delta)
    return self.body:onMouseWheel(delta)
end


---@return nil
function OpenAction:perform()
    Rarity.refresh(SandboxVars.OMHTurretsTraps or {})
    if Access.near(self.character, self.object, nil, true) then
        if isClient() then
            self.object:getContainer():requestSync()
        end
        local index = self.character:getPlayerNum()
        if active[index] then active[index]:close() end
        local font = getTextManager()
        local lineHeight = font:getFontHeight(UIFont.Small) + (getPlayerScreenHeight(index) >= 800 and 3 or 0)
        local titleHeight = font:getFontHeight(UIFont.Medium) + 16
        local width = math.min(getPlayerScreenWidth(index) - 24, math.max(900, lineHeight * 48))
        local slotHeight = math.max(60, lineHeight * 3 + 12)
        local top, ammunitionY, ammoY, magazineY, modulesY, detailsY = 0, 0, 0, 0, 0, 0
        local moduleHeight = lineHeight * 2 + 16
        local height = math.min(getPlayerScreenHeight(index) - 24, 240 + lineHeight * 26)
        local x = getPlayerScreenLeft(index) + getPlayerScreenWidth(index) - width - 12
        local y = getPlayerScreenTop(index) + math.max(12, (getPlayerScreenHeight(index) - height) / 2)
        local panel = Panel:new(x, y, width, height)
        panel.player, panel.object, panel.nextRefresh = self.character, self.object, 0
        panel.controller = self.controller
        panel.deviceId, panel.slots, panel.moduleSlots = T.state(self.object).id, {}, {}
        panel.moduleRow, panel.rows = 0, 3
        panel.equipmentY, panel.ammunitionY = top - lineHeight, ammunitionY
        panel.lineHeight, panel.titleHeight, panel.slotHeight = lineHeight, titleHeight, slotHeight
        panel.modulesY, panel.detailsY, panel.result, panel.reason = modulesY, detailsY, "", ""
        panel.moveWithMouse = true
        panel.backgroundColor = {r = 0.04, g = 0.04, b = 0.04, a = 0.96}
        panel:initialise()
        panel.benefitList = BenefitList:new(width / 2 + 4, detailsY - lineHeight, width / 2 - 16, lineHeight * 9, lineHeight)
        panel.benefitList:initialise()
        panel:addChild(panel.benefitList)
        local rangeLabel = getText("UI_OMHTT_EngagementRange", getText("UI_OMHTT_RangeMax"))
        local rangeX = math.min(width - 150, 28 + font:MeasureStringX(UIFont.Small, rangeLabel))
        panel.rangeSlider = ISSliderPanel:new(rangeX, detailsY + lineHeight * 8 + 5, width - rangeX - 24, lineHeight + 2, panel, Panel.changeRange)
        panel.rangeSlider:initialise()
        panel.rangeSlider.toolTipText = getText("UI_OMHTT_RangeTooltip")
        panel:addChild(panel.rangeSlider)
        local equipmentWidth = width - 40
        local headWidth, expansionWidth = equipmentWidth * .36, equipmentWidth * .20
        local batteryX = 28 + headWidth + expansionWidth
        panel.headSlot = panel:addSlot("head", getText("UI_OMHTT_ManageHead"), 12, top, headWidth)
        panel.capacitySlot = panel:addSlot("capacity", getText("UI_OMHTT_ManageCapacity"), 20 + headWidth, top, expansionWidth)
        panel.batterySlot = panel:addSlot("battery", "", batteryX, top, width - batteryX - 72)
        panel.batterySlot.detailProvider = function()
            if not panel.batteryText then panel.batteryText = Benefits.battery(panel.batteryContents, panel.stats) end
            return panel.batteryText
        end
        panel.powerButton = ISButton:new(width - 66, top, 54, panel.slotHeight, "", panel, Panel.togglePower)
        panel.powerButton.prerender = Panel.drawPower
        local reserveWidth = (width - 32) / 2
        panel.ammoSlot = panel:addSlot("ammo", "", 12, ammoY, reserveWidth)
        panel.voidSlot = panel:addSlot("void", getText("UI_OMHTT_Void"), 20 + reserveWidth, ammoY, reserveWidth)
        panel.voidSlot.detailText = getText("UI_OMHTT_VoidHint")
        panel.magazineSlot = panel:addSlot("magazine", "", 12, magazineY, width - 24)
        panel.magazineSlot.textInsetRight = 88
        panel.loadOrderButton = ISButton:new(width - 126, ammunitionY + 2, 114, 26, getText("UI_OMHTT_LoadOrder"), panel, function(self)
            require("OMHTT/TurretLoadOrderPanel").open(self)
        end)
        panel.reloadButton = ISButton:new(width - 96, magazineY + math.max(4, (slotHeight - 26) / 2), 76, 26, getText("UI_OMHTT_Reload"), panel, function(self)
            local contents = T.contents(self.object:getContainer())
            if contents.head then
                Utilities.control(self, "Reload", contents.head:getID())
            end
        end)
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
        panel.closeButton = close
        require("OMHTT/TurretManageExtras").create(panel, rangeX)
        local buttons = {panel.fireButton, panel.powerButton, panel.priorityButton, panel.loadOrderButton, panel.reloadButton, close}
        for i = 1, #buttons do buttons[i]:initialise(); panel:addChild(buttons[i]) end
        require("OMHTT/ControlManage").create(panel)
        require("OMHTT/TurretManageLayout").create(panel)
        panel:refresh()
        require("OMHTT/ControlManage").refresh(panel)
        require("OMHTT/WindowGeometry").install(panel, "Manage", math.max(900, lineHeight * 48), 540,
            require("OMHTT/TurretManageLayout").refresh)
        panel:addToUIManager()
        active[index] = panel
        if Range then
            Range.focus(index, "manage", self.object, true)
        end
        D.emit("turret-manage-open", {id = panel.deviceId, interface = "dedicated", width = width, height = panel.height})
    end
    ISBaseTimedAction.perform(self)
end

---@return boolean valid
function OpenAction:isValid()
    return Access.near(self.character, self.object, nil, true)
end

---@param player IsoPlayer Operator
---@param object IsoObject Exact turret
---@return table action
function OpenAction:new(player, object, controller)
    local action = ISBaseTimedAction.new(self, player)
    action.object, action.maxTime = object, 1
    action.controller = controller
    return action
end

---@param object IsoObject Exact turret
---@param player IsoPlayer Operator
---@return nil
local function open(object, player, controller)
    if controller then
        ISTimedActionQueue.add(OpenAction:new(player, object, controller))
        return
    end
    if luautils.walkAdjObject(player, object, false) then ISTimedActionQueue.add(OpenAction:new(player, object)) end
end

return open
