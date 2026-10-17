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
---@return nil
function L.refresh(panel)
    if not panel.body then return end
    local screen = getPlayerScreenHeight(panel.player:getPlayerNum())
    if screen == panel.layoutScreen and panel.detailsOpen == panel.layoutDetails and panel.moduleLines == panel.layoutLines
        and panel.hasLure == panel.layoutLure and panel.hasLanding == panel.layoutLanding then return end
    panel.layoutScreen, panel.layoutDetails, panel.layoutLines = screen, panel.detailsOpen, panel.moduleLines
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
    panel.detailsY = panel.moduleGridBottom + 8
    panel.detailLines = string.split(panel.moduleLines or "", "\n")
    panel.detailsButton:setTitle(getText(panel.detailsOpen and "UI_OMHTT_DetailsClose" or "UI_OMHTT_DetailsOpen"))
    local detailsHeight = panel.detailsOpen and h * (#panel.detailLines + 3) + 16 or 0
    panel.benefitList:setY(panel.detailsY + detailsHeight + 8)
    panel.body.contentHeight = panel.benefitList.y + panel.benefitList.height + 8
    panel.body:setScrollHeight(panel.body.contentHeight)
    panel.body:setYScroll(math.max(math.min(0, panel.body.height - panel.body.contentHeight), panel.body:getYScroll()))
end

---@param x number Content left
---@param width number Section width
---@param y number Content top
---@param bottom number Content bottom
---@param title string Section caption
---@return nil
function Body:section(x, width, y, bottom, title)
    self:drawRect(x, y, width, bottom - y, .95, .055, .055, .055)
    self:drawRectBorder(x, y, width, bottom - y, .6, .25, .25, .25)
    self:drawRect(x, y, width, self.owner.headerHeight, 1, .12, .12, .12)
    self:drawText(title, x + 6, y + 4, .9, .9, .9, 1, UIFont.Small)
end

---@return nil
function Body:prerender()
    local p, h = self.owner, self.owner.lineHeight
    self:drawRectStatic(0, 0, self.width, self.height, .95, .025, .025, .025)
    self:setStencilRect(0, 0, self.width, self.height)
    self:section(4, p.equipmentWidth, 4, p.equipmentBottom, getText("UI_OMHTT_Equipment"))
    self:section(p.ammunitionX, p.ammunitionWidth, 4, p.ammunitionBottom, getText("UI_OMHTT_Ammunition"))
    self:section(4, self.width - 20, p.modulesY, p.moduleGridBottom, p.moduleLabel)
    self:drawText(getText(p.rows > 3 and "UI_OMHTT_ManageScroll" or "UI_OMHTT_ModuleDropHint"),
        10, p.modulesY + p.headerHeight + 4, .65, .65, .65, 1, UIFont.Small)
    if p.detailsOpen then
        local y, stats = p.detailsY + 8, p.stats
        self:drawRect(4, p.detailsY, self.width - 20, p.benefitList.y - p.detailsY - 8, .95, .055, .055, .055)
        self:drawRectBorder(4, p.detailsY, self.width - 20, p.benefitList.y - p.detailsY - 8, .6, .25, .25, .25)
        for i = 1, #p.detailLines do
            self:drawText(p.detailLines[i], 10, y, .8, .8, .8, 1, UIFont.Small)
            y = y + h
        end
        self:drawText(getText("UI_OMHTT_CompactStats", string.format("%.1f", stats.damage), string.format("%.1f", stats.range), p.object:getHealth(), p.object:getMaxHealth()), 10, y, 1, 1, 1, 1, UIFont.Small)
        local timing = getText("UI_OMHTT_ManageTiming", string.format("%.2f", stats.reload / 1000), string.format("%.2f", 1000 / stats.cooldown))
        if stats.rotary then
            timing = getText("UI_OMHTT_MotorSpeed", string.format("%.1f", stats.motorSpeed / 6))
        end
        self:drawText(timing, 10, y + h, 1, 1, 1, 1, UIFont.Small)
        self:drawText(getText("UI_OMHTT_CompactChances", string.format("%.0f", stats.accuracy), string.format("%.0f", stats.critChance), string.format("%.1f", stats.critMultiplier)), 10, y + h * 2, 1, 1, 1, 1, UIFont.Small)
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
    local nameBottom = panel.nameEntry.y + panel.nameEntry.height
    if panel.sourceButton then
        nameBottom = panel.sourceButton.y + panel.sourceButton.height
    end
    panel.body = Body:new(6, nameBottom + 8, width - 12, 200)
    panel.body.owner = panel
    panel.body:initialise()
    panel.body.background = false
    panel:addChild(panel.body)
    panel.body:setScrollChildren(true)
    panel.body:addScrollBars(false)
    for i = 1, #panel.slots do
        adopt(panel, panel.slots[i])
    end
    adopt(panel, panel.powerButton)
    adopt(panel, panel.reloadButton)
    adopt(panel, panel.loadOrderButton)
    adopt(panel, panel.benefitList)
    local rowWidth = panel.body.width - 28
    panel.headerHeight = math.max(32, h + 10)
    local slot = math.max(60, h * 3 + 12)
    panel.slotHeight = slot
    panel.equipmentWidth = math.floor((rowWidth - 8) * .40)
    panel.ammunitionX = panel.equipmentWidth + 12
    panel.ammunitionWidth = panel.body.width - 16 - panel.ammunitionX
    local equipment = panel.equipmentWidth - 8
    local ammoX, ammoWidth = panel.ammunitionX + 4, panel.ammunitionWidth - 8
    local measure = getTextManager()
    local reloadWidth = math.max(80, measure:MeasureStringX(UIFont.Small, getText("UI_OMHTT_Reload")) + 16)
    local orderWidth = math.max(114, measure:MeasureStringX(UIFont.Small, getText("UI_OMHTT_LoadOrder")) + 16)
    if measure:MeasureStringX(UIFont.Small, getText("UI_OMHTT_Ammunition")) + reloadWidth + orderWidth + 24 > ammoWidth then
        panel.headerHeight = panel.headerHeight + h + 10
    end
    local top, second = 4 + panel.headerHeight + 6, 4 + panel.headerHeight + slot + 14
    local headWidth = math.floor((equipment - 6) * .60)
    panel.headSlot:setX(8)
    panel.headSlot:setWidth(headWidth)
    panel.headSlot:setY(top)
    panel.capacitySlot:setX(14 + headWidth)
    panel.capacitySlot:setWidth(equipment - headWidth - 6)
    panel.capacitySlot:setY(top)
    panel.batterySlot:setX(8)
    panel.batterySlot:setWidth(equipment - 60)
    panel.batterySlot:setY(second)
    panel.powerButton:setX(8 + equipment - 54)
    panel.powerButton:setY(second)
    panel.ammoSlot:setX(ammoX)
    panel.ammoSlot:setWidth((ammoWidth - 8) / 2)
    panel.ammoSlot:setY(top)
    panel.voidSlot:setX(ammoX + (ammoWidth + 8) / 2)
    panel.voidSlot:setWidth((ammoWidth - 8) / 2)
    panel.voidSlot:setY(top)
    panel.magazineSlot:setX(ammoX)
    panel.magazineSlot:setWidth(ammoWidth)
    panel.magazineSlot:setY(second)
    panel.magazineSlot.textInsetRight = 0
    local slots = {panel.headSlot, panel.capacitySlot, panel.batterySlot, panel.ammoSlot, panel.voidSlot, panel.magazineSlot, panel.powerButton}
    for i = 1, #slots do
        slots[i]:setHeight(slot)
    end
    local buttonY = 4 + panel.headerHeight - panel.reloadButton.height - 3
    panel.loadOrderButton:setWidth(orderWidth)
    panel.loadOrderButton:setX(ammoX + ammoWidth - orderWidth)
    panel.loadOrderButton:setY(buttonY)
    panel.reloadButton:setX(panel.loadOrderButton.x - reloadWidth - 6)
    panel.reloadButton:setWidth(reloadWidth)
    panel.reloadButton:setY(buttonY)
    panel.equipmentBottom = second + slot + 6
    panel.ammunitionY, panel.ammunitionBottom = 4, panel.equipmentBottom
    panel.modulesY = panel.ammunitionBottom + 10
    local moduleTop = panel.modulesY + panel.headerHeight + h + 10
    local moduleHeight = h * 2 + 16
    local moduleWidth = (rowWidth - 30) / 6
    for i = 1, 16 do
        local row = i <= 4 and 0 or 1 + math.floor((i - 5) / 6)
        local column = i <= 4 and i or (i - 5) % 6
        panel.moduleSlots[i]:setX(8 + column * (moduleWidth + 6))
        panel.moduleSlots[i]:setWidth(moduleWidth)
        panel.moduleSlots[i]:setY(moduleTop + row * (moduleHeight + 6))
        panel.moduleSlots[i]:setHeight(moduleHeight)
        panel.moduleSlots[i].compact = true
    end
    panel.benefitList:setX(8)
    panel.moduleGridBottom = moduleTop + 3 * (moduleHeight + 6)
    panel.benefitList:setY(panel.moduleGridBottom + 10)
    panel.benefitList:setWidth(rowWidth)
    panel.benefitList:setHeight(h * 7)
    panel.benefitList.visibleRows = 6
    panel.detailsButton = ISButton:new(8 + rowWidth - 110, panel.modulesY + 2, 110, panel.headerHeight - 4, "", panel, function(self)
        self.detailsOpen = not self.detailsOpen
        L.refresh(self)
    end)
    panel.detailsButton:initialise()
    panel.body:addChild(panel.detailsButton)
    L.refresh(panel)
end

---@param panel ISPanel Window
---@return nil
function L.draw(panel)
    panel:drawRect(1, 1, panel.width - 2, panel.titleHeight - 2, 1, .13, .15, .13)
    panel:drawText(getText("UI_OMHTT_TurretTitle"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    panel:drawTextRight(panel.weightLabel or "", panel.width - 12, panel.titleHeight + 10, .75, .75, .75, 1, UIFont.Small)
    panel:drawText(getText("UI_OMHTT_EngagementRange", T.state(panel.object).engagementRange and string.format("%.1f", panel.engagementRange) or getText("UI_OMHTT_RangeMax")), 12, panel.rangeY + 4, 1, 1, 1, 1, UIFont.Small)
    require("OMHTT/TurretManageExtras").draw(panel)
    panel:setStencilRect(12, panel.feedbackY, panel.width - 24, panel.lineHeight * 2)
    panel:drawText(getText("UI_OMHTT_Manage" .. panel.status) .. " | " .. panel.powerLabel, 12, panel.feedbackY, .85, .85, .85, 1, UIFont.Small)
    panel:drawText(panel.reason ~= "" and panel.reason or panel.result, 12, panel.feedbackY + panel.lineHeight, .95, .85, .65, 1, UIFont.Small)
    panel:clearStencilRect()
end

return L
