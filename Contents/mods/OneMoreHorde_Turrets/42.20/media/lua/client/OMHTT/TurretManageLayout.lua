if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local L = {}
local T = require("OMHTT/Turret")
local Body = ISPanel:derive("OMHTTManageBody")

---@param delta number Wheel movement
---@return boolean handled
function Body:onMouseWheel(delta)
    self:setYScroll(0)
    return true
end

---@param panel ISPanel Window
---@return nil
function L.refresh(panel)
    if not panel.body or panel.orderPanel then return end
    local screen = getPlayerScreenHeight(panel.player:getPlayerNum())
    if screen == panel.layoutScreen and panel.detailsOpen == panel.layoutDetails and panel.moduleLines == panel.layoutLines
        and panel.hasLure == panel.layoutLure and panel.hasLanding == panel.layoutLanding then return end
    local resized = screen ~= panel.layoutScreen
    panel.layoutScreen, panel.layoutDetails, panel.layoutLines = screen, panel.detailsOpen, panel.moduleLines
    panel.layoutLure, panel.layoutLanding = panel.hasLure, panel.hasLanding
    local h, row = panel.lineHeight, math.max(28, panel.lineHeight + 8)
    panel.detailLines = string.split(getTextManager():WrapText(UIFont.Small, panel.moduleLines or "", math.floor(panel.body.width / 2) - 28), "\n")
    panel.detailsButton:setTitle(getText(panel.detailsOpen and "UI_OMHTT_DetailsClose" or "UI_OMHTT_DetailsOpen"))
    if resized then
        local moduleHeight = screen >= 900 and h * 2 + 16 or h + 8
        local moduleTop = panel.modulesY + panel.headerHeight + 6
        for i = 1, 16 do
            local gridRow = i <= 4 and 0 or 1 + math.floor((i - 5) / 6)
            panel.moduleSlots[i]:setY(moduleTop + gridRow * (moduleHeight + 4))
            panel.moduleSlots[i]:setHeight(moduleHeight)
        end
        panel.moduleGridBottom = moduleTop + 3 * (moduleHeight + 4)
    end
    local detailsHeight = math.max(h * (#panel.detailLines + 3) + 16, h * 7 + 16)
    local footer = 48 + h * 2 + 14 + row * (1 + (panel.hasLure and 1 or 0) + (panel.hasLanding and 1 or 0))
    local bodyHeight = panel.moduleGridBottom + 8
    local desired = panel.body.y + bodyHeight + footer + (panel.detailsOpen and detailsHeight + 8 or 0)
    panel:setHeight(math.min(screen - 24, desired))
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
    panel.body:setHeight(math.max(80, panel.rangeY - panel.body.y - 6))
    panel.detailsPage = panel.detailsOpen and desired > screen - 24
    panel.detailsY = panel.detailsPage and panel.headerHeight + 12 or panel.moduleGridBottom + 8
    panel.detailsButton:setY(panel.detailsPage and 4 or panel.modulesY + 2)
    panel.benefitList:setY(panel.detailsY)
    panel.benefitList:setX(math.floor(panel.body.width / 2) + 4)
    panel.benefitList:setWidth(panel.body.width - panel.benefitList.x - 8)
    panel.benefitList:setHeight(math.max(h * 2, math.min(detailsHeight, panel.body.height - panel.detailsY - 6)))
    panel.benefitList.visibleRows = math.max(1, math.floor(panel.benefitList.height / h) - 1)
    panel.benefitList:setVisible(panel.detailsOpen == true)
    if not panel.detailsOpen then
        panel.benefitList:hideTooltip()
    end
    for i = 1, #panel.slots do
        panel.slots[i]:setVisible(not panel.detailsPage)
    end
    panel.powerButton:setVisible(not panel.detailsPage)
    panel.reloadButton:setVisible(not panel.detailsPage)
    panel.loadOrderButton:setVisible(not panel.detailsPage)
    panel.equipmentHelp:setVisible(not panel.detailsPage)
    panel.ammunitionHelp:setVisible(not panel.detailsPage)
    panel.modulesHelp:setVisible(not panel.detailsPage)
    panel.body.contentHeight = panel.body.height
    panel.body:setScrollHeight(panel.body.height)
    panel.body:setYScroll(0)
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
    if not p.detailsPage then
        self:section(4, p.equipmentWidth, 4, p.equipmentBottom, getText("UI_OMHTT_Equipment"))
        self:section(p.ammunitionX, p.ammunitionWidth, 4, p.ammunitionBottom, getText("UI_OMHTT_Ammunition"))
        self:section(4, self.width - 12, p.modulesY, p.moduleGridBottom, p.moduleLabel)
    else
        self:section(4, self.width - 12, 4, self.height - 4, getText("UI_OMHTT_DetailsOpen"))
    end
    if p.detailsOpen then
        local y, stats = p.detailsY + 8, p.stats
        self:drawRect(4, p.detailsY, p.benefitList.x - 12, p.benefitList.height, .95, .055, .055, .055)
        self:drawRectBorder(4, p.detailsY, p.benefitList.x - 12, p.benefitList.height, .6, .25, .25, .25)
        local clipX, clipY, clipW, clipH = self:clampStencilRectToParent(8, p.detailsY, p.benefitList.x - 20, p.benefitList.height)
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
        self:clearStencilRect()
        self:repaintStencilRect(clipX, clipY, clipW, clipH)
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
    panel.body:setScrollChildren(false)
    for i = 1, #panel.slots do
        adopt(panel, panel.slots[i])
    end
    adopt(panel, panel.powerButton)
    adopt(panel, panel.reloadButton)
    adopt(panel, panel.loadOrderButton)
    adopt(panel, panel.benefitList)
    local rowWidth = panel.body.width - 28
    panel.headerHeight = math.max(26, h + 8)
    local slot = math.max(54, h * 3 + 6)
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
    local moduleTop = panel.modulesY + panel.headerHeight + 6
    local moduleHeight = getPlayerScreenHeight(panel.player:getPlayerNum()) >= 900 and h * 2 + 16 or h + 8
    local moduleWidth = (rowWidth - 30) / 6
    for i = 1, 16 do
        local row = i <= 4 and 0 or 1 + math.floor((i - 5) / 6)
        local column = i <= 4 and i or (i - 5) % 6
        panel.moduleSlots[i]:setX(8 + column * (moduleWidth + 6))
        panel.moduleSlots[i]:setWidth(moduleWidth)
        panel.moduleSlots[i]:setY(moduleTop + row * (moduleHeight + 4))
        panel.moduleSlots[i]:setHeight(moduleHeight)
        panel.moduleSlots[i].compact = true
    end
    panel.benefitList:setX(8)
    panel.moduleGridBottom = moduleTop + 3 * (moduleHeight + 4)
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
    ---@param x number Header left
    ---@param y number Header top
    ---@param w number Hover width
    ---@param key string Tooltip translation
    ---@return ISButton help Hover-only header region
    local function help(x, y, w, key)
        local control = ISButton:new(x, y, w, panel.headerHeight, "", panel, nil)
        control:initialise()
        control.tooltip = getText(key)
        control.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
        control.backgroundColorMouseOver = control.backgroundColor
        control.borderColor = control.backgroundColor
        panel.body:addChild(control)
        return control
    end
    panel.equipmentHelp = help(4, 4, panel.equipmentWidth, "UI_OMHTT_EquipmentHelp")
    panel.ammunitionHelp = help(panel.ammunitionX, 4, panel.reloadButton.x - panel.ammunitionX - 2, "UI_OMHTT_AmmunitionHelp")
    panel.modulesHelp = help(4, panel.modulesY, panel.detailsButton.x - 8, "UI_OMHTT_ModulesHelp")
    panel.detailsButton.tooltip = getText("UI_OMHTT_ModuleStatsHelp")
    panel.headerHelp = {panel.equipmentHelp, panel.ammunitionHelp, panel.modulesHelp, panel.detailsButton}
    L.refresh(panel)
end

---@param panel ISPanel Window
---@return nil
function L.page(panel)
    local visible = panel.orderPanel == nil
    if panel.pageVisible ~= visible or panel.pageDetails ~= panel.detailsPage then
        for i = 1, #panel.headerHelp do
            local control = panel.headerHelp[i]
            if control.tooltipUI then
                control.tooltipUI:removeFromUIManager()
                control.tooltipUI = nil
            end
        end
        panel.pageVisible, panel.pageDetails = visible, panel.detailsPage
    end
    panel.body:setVisible(visible)
    panel.nameEntry:setVisible(visible)
    if panel.sourceButton then
        panel.sourceButton:setVisible(visible)
    end
    panel.rangeSlider:setVisible(visible)
    panel.fireButton:setVisible(visible)
    panel.priorityButton:setVisible(visible)
    panel.lureSlider:setVisible(visible and panel.hasLure)
    panel.lurePlay:setVisible(visible and panel.hasLure)
    panel.lureLoop:setVisible(visible and panel.hasLure)
    panel.landingSlider:setVisible(visible and panel.hasLanding)
    if not visible then
        panel.benefitList:hideTooltip()
        for i = 1, #panel.slots do
            panel.slots[i]:hideTooltip()
        end
    end
end

---@param panel ISPanel Window
---@return nil
function L.draw(panel)
    panel:drawRect(1, 1, panel.width - 2, panel.titleHeight - 2, 1, .13, .15, .13)
    panel:drawText(getText("UI_OMHTT_TurretTitle"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    if panel.orderPanel then return end
    panel:drawTextRight(panel.weightLabel or "", panel.width - 12, panel.titleHeight + 10, .75, .75, .75, 1, UIFont.Small)
    panel:drawText(getText("UI_OMHTT_EngagementRange", T.state(panel.object).engagementRange and string.format("%.1f", panel.engagementRange) or getText("UI_OMHTT_RangeMax")), 12, panel.rangeY + 4, 1, 1, 1, 1, UIFont.Small)
    require("OMHTT/TurretManageExtras").draw(panel)
    panel:setStencilRect(12, panel.feedbackY, panel.width - 24, panel.lineHeight * 2)
    panel:drawText(getText("UI_OMHTT_Manage" .. panel.status) .. " | " .. panel.powerLabel, 12, panel.feedbackY, .85, .85, .85, 1, UIFont.Small)
    panel:drawText(panel.reason ~= "" and panel.reason or panel.result, 12, panel.feedbackY + panel.lineHeight, .95, .85, .65, 1, UIFont.Small)
    panel:clearStencilRect()
end

return L
