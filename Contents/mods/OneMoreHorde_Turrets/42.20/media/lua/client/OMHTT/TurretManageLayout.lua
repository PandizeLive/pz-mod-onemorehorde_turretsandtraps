if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local L = {}
local T = require("OMHTT/Turret")
local Body = ISPanel:derive("OMHTTManageBody")

---@param delta number Wheel movement
---@return boolean handled
function Body:onMouseWheel(delta)
    self:setYScroll(math.max(math.min(0, self.height - self.contentHeight), math.min(0, self:getYScroll() - delta * 36)))
    return true
end

---@param panel ISPanel Window
---@param tab string Selected tab
---@return nil
function L.select(panel, tab)
    panel.selectedTab = tab
    panel.body:setYScroll(0)
    for i = 1, #panel.slots do
        local slot = panel.slots[i]
        slot:hideTooltip()
        slot:clearDrag()
        slot:setVisible((slot.kind == "module") == (tab == "modules"))
    end
    panel.benefitList:hideTooltip()
    panel.benefitList:setVisible(tab == "modules")
    panel.loadOrderButton:setVisible(tab == "equipment")
    panel.reloadButton:setVisible(tab == "equipment")
    panel.powerButton:setVisible(tab == "equipment")
    panel.equipmentTab.backgroundColor = {r = .12, g = .12, b = .12, a = tab == "equipment" and 1 or .3}
    panel.modulesTab.backgroundColor = {r = .12, g = .12, b = .12, a = tab == "modules" and 1 or .3}
    panel.layoutTab = nil
    L.refresh(panel)
end

---@param panel ISPanel Window
---@return nil
function L.refresh(panel)
    if not panel.body then return end
    local screen = getPlayerScreenHeight(panel.player:getPlayerNum())
    if screen == panel.layoutScreen and panel.detailsOpen == panel.layoutDetails and panel.selectedTab == panel.layoutTab
        and panel.hasLure == panel.layoutLure and panel.hasLanding == panel.layoutLanding then return end
    panel.layoutScreen, panel.layoutDetails, panel.layoutTab = screen, panel.detailsOpen, panel.selectedTab
    panel.layoutLure, panel.layoutLanding = panel.hasLure, panel.hasLanding
    local h, row = panel.lineHeight, math.max(32, panel.lineHeight + 12)
    panel:setHeight(math.min(screen - 24, 240 + h * 26))
    local top = getPlayerScreenTop(panel.player:getPlayerNum())
    panel:setY(math.max(top + 12, math.min(panel.y, top + screen - panel.height - 12)))
    local bottom = panel.height - 48
    panel.fireButton:setY(bottom)
    panel.priorityButton:setY(bottom)
    panel.feedbackY = bottom - h * 2 - 8
    local y = panel.feedbackY - row * (1 + (panel.hasLure and 1 or 0) + (panel.hasLanding and 1 or 0)) - 6
    panel.rangeY = y
    panel.rangeSlider:setY(y + 4)
    y = y + row
    panel.lureY = y
    panel.lureSlider:setY(y + 4)
    panel.lurePlay:setY(y)
    panel.lureLoop:setY(y)
    if panel.hasLure then
        y = y + row
    end
    panel.landingY = y
    panel.landingSlider:setY(y + 4)
    panel.body:setHeight(math.max(80, panel.rangeY - panel.body.y - 10))
    panel.detailsY = panel.selectedTab == "equipment" and panel.equipmentBottom or panel.modulesBottom
    panel.detailsButton:setY(panel.detailsY)
    panel.detailsButton:setTitle(getText(panel.detailsOpen and "UI_OMHTT_DetailsClose" or "UI_OMHTT_DetailsOpen"))
    panel.body.contentHeight = panel.detailsY + row + (panel.detailsOpen and h * 6 + 8 or 0)
    panel.body:setScrollHeight(panel.body.contentHeight)
    panel.body:setYScroll(math.max(math.min(0, panel.body.height - panel.body.contentHeight), panel.body:getYScroll()))
end

---@return nil
function Body:prerender()
    local p, h = self.owner, self.owner.lineHeight
    self:drawRectStatic(0, 0, self.width, self.height, .8, .025, .025, .025)
    self:setStencilRect(0, 0, self.width, self.height)
    if p.selectedTab == "equipment" then
        self:drawText(getText("UI_OMHTT_Equipment"), 8, 4, .75, .75, .75, 1, UIFont.Small)
        self:drawText(getText("UI_OMHTT_Ammunition"), 8, p.ammunitionY, .75, .75, .75, 1, UIFont.Small)
    else
        self:drawText(p.moduleLabel, 8, 4, .9, .9, .9, 1, UIFont.Small)
        self:drawText(getText(p.rows > 3 and "UI_OMHTT_ManageScroll" or "UI_OMHTT_ModuleDropHint"), 8, h + 4, .65, .65, .65, 1, UIFont.Small)
    end
    if p.detailsOpen then
        local y, stats = p.detailsY + math.max(32, h + 12), p.stats
        self:drawText(p.moduleLines, 8, y, .8, .8, .8, 1, UIFont.Small)
        self:drawText(getText("UI_OMHTT_CompactStats", string.format("%.1f", stats.damage), string.format("%.1f", stats.range), p.object:getHealth(), p.object:getMaxHealth()), 8, y + h * 3, 1, 1, 1, 1, UIFont.Small)
        local timing = getText("UI_OMHTT_ManageTiming", string.format("%.2f", stats.reload / 1000), string.format("%.2f", 1000 / stats.cooldown))
        if stats.rotary then
            timing = getText("UI_OMHTT_MotorSpeed", string.format("%.1f", stats.motorSpeed / 6))
        end
        self:drawText(timing, 8, y + h * 4, 1, 1, 1, 1, UIFont.Small)
        self:drawText(getText("UI_OMHTT_CompactChances", string.format("%.0f", stats.accuracy), string.format("%.0f", stats.critChance), string.format("%.1f", stats.critMultiplier)), 8, y + h * 5, 1, 1, 1, 1, UIFont.Small)
    end
end

---@return nil
function Body:render()
    self:clearStencilRect()
end

---@param panel ISPanel Window
---@param child ISUIElement Content control
---@return nil
local function adopt(panel, child)
    panel:removeChild(child)
    panel.body:addChild(child)
end

---@param panel ISPanel Window
---@return nil
function L.create(panel)
    local h, width = panel.lineHeight, panel.width
    panel:setScrollChildren(false)
    panel:setHeight(math.min(getPlayerScreenHeight(panel.player:getPlayerNum()) - 24, 240 + h * 26))
    panel.contentHeight = panel.height
    local tabsY = panel.titleHeight + 72
    panel.body = Body:new(6, tabsY + 36, width - 12, 200)
    panel.body.owner = panel
    panel.body:initialise()
    panel.body.background = false
    panel.body:setScrollChildren(true)
    panel.body:addScrollBars(false)
    panel:addChild(panel.body)
    panel.equipmentTab = ISButton:new(12, tabsY, (width - 30) / 2, 28, getText("UI_OMHTT_EquipmentAmmo"), panel, function(self) L.select(self, "equipment") end)
    panel.modulesTab = ISButton:new(18 + (width - 30) / 2, tabsY, (width - 30) / 2, 28, getText("UI_OMHTT_ModulesTab"), panel, function(self) L.select(self, "modules") end)
    panel.equipmentTab:initialise()
    panel.modulesTab:initialise()
    panel:addChild(panel.equipmentTab)
    panel:addChild(panel.modulesTab)
    for i = 1, #panel.slots do adopt(panel, panel.slots[i]) end
    adopt(panel, panel.powerButton)
    adopt(panel, panel.reloadButton)
    adopt(panel, panel.loadOrderButton)
    adopt(panel, panel.benefitList)
    local rowWidth = panel.body.width - 28
    local equipmentWidth = rowWidth - 78
    local headWidth, expansionWidth = math.floor(equipmentWidth * .43), math.floor(equipmentWidth * .24)
    panel.headSlot:setX(8)
    panel.headSlot:setWidth(headWidth)
    panel.capacitySlot:setX(16 + headWidth)
    panel.capacitySlot:setWidth(expansionWidth)
    panel.batterySlot:setX(24 + headWidth + expansionWidth)
    panel.batterySlot:setWidth(equipmentWidth - headWidth - expansionWidth)
    panel.powerButton:setX(8 + rowWidth - 54)
    panel.ammoSlot:setX(8)
    panel.ammoSlot:setWidth((rowWidth - 8) / 2)
    panel.voidSlot:setX(16 + (rowWidth - 8) / 2)
    panel.voidSlot:setWidth((rowWidth - 8) / 2)
    panel.magazineSlot:setX(8)
    panel.magazineSlot:setWidth(rowWidth)
    panel.loadOrderButton:setX(8 + rowWidth - 114)
    panel.reloadButton:setX(8 + rowWidth - 88)
    local top, slot = h + 12, math.max(60, h * 3 + 12)
    panel.slotHeight = slot
    panel.headSlot:setY(top)
    panel.capacitySlot:setY(top)
    panel.batterySlot:setY(top)
    panel.powerButton:setY(top)
    panel.ammunitionY = top + slot + 10
    local ammoY = panel.ammunitionY + math.max(32, h + 10)
    panel.ammoSlot:setY(ammoY)
    panel.voidSlot:setY(ammoY)
    panel.magazineSlot:setY(ammoY + slot + 8)
    local equipment = {panel.headSlot, panel.capacitySlot, panel.batterySlot, panel.ammoSlot, panel.voidSlot, panel.magazineSlot, panel.powerButton}
    for i = 1, #equipment do equipment[i]:setHeight(slot) end
    panel.loadOrderButton:setY(panel.ammunitionY)
    panel.reloadButton:setY(panel.magazineSlot.y + (slot - 26) / 2)
    panel.equipmentBottom = panel.magazineSlot.y + slot + 12
    local moduleHeight = h * 2 + 16
    local moduleWidth = (rowWidth - 30) / 6
    for i = 1, 16 do
        local row = i <= 4 and 0 or 1 + math.floor((i - 5) / 6)
        local column = i <= 4 and i or (i - 5) % 6
        panel.moduleSlots[i]:setX(8 + column * (moduleWidth + 6))
        panel.moduleSlots[i]:setWidth(moduleWidth)
        panel.moduleSlots[i]:setY(h * 2 + 10 + row * (moduleHeight + 6))
        panel.moduleSlots[i]:setHeight(moduleHeight)
        panel.moduleSlots[i].compact = true
    end
    panel.benefitList:setX(8)
    panel.benefitList:setY(h * 2 + 10 + 3 * (moduleHeight + 6))
    panel.benefitList:setWidth(rowWidth)
    panel.benefitList:setHeight(h * 7)
    panel.benefitList.visibleRows = 6
    panel.modulesBottom = panel.benefitList.y + panel.benefitList.height + 12
    panel.detailsButton = ISButton:new(8, 0, rowWidth, math.max(28, h + 8), "", panel, function(self)
        self.detailsOpen = not self.detailsOpen
        L.refresh(self)
    end)
    panel.detailsButton:initialise()
    panel.body:addChild(panel.detailsButton)
    L.select(panel, "equipment")
end

---@param panel ISPanel Window
---@return nil
function L.draw(panel)
    panel:drawRect(1, 1, panel.width - 2, panel.titleHeight - 2, 1, .13, .15, .13)
    panel:drawText(getText("UI_OMHTT_TurretTitle"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    if not panel.controller then
        panel:drawText(panel.weightLabel or "", 12, panel.titleHeight + 40, .75, .75, .75, 1, UIFont.Small)
    end
    panel:drawText(getText("UI_OMHTT_EngagementRange", T.state(panel.object).engagementRange and string.format("%.1f", panel.engagementRange) or getText("UI_OMHTT_RangeMax")), 12, panel.rangeY + 4, 1, 1, 1, 1, UIFont.Small)
    require("OMHTT/TurretManageExtras").draw(panel)
    panel:setStencilRect(12, panel.feedbackY, panel.width - 24, panel.lineHeight * 2)
    panel:drawText(getText("UI_OMHTT_Manage" .. panel.status) .. " | " .. panel.powerLabel, 12, panel.feedbackY, .85, .85, .85, 1, UIFont.Small)
    panel:drawText(panel.reason ~= "" and panel.reason or panel.result, 12, panel.feedbackY + panel.lineHeight, .95, .85, .65, 1, UIFont.Small)
    panel:clearStencilRect()
end

return L
