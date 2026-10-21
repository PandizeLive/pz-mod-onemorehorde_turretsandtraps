if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local L = {}
local Theme = require("OMHTT/ControlTheme")
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
    if not panel.body then return end
    local geometryChanged = require("OMHTT/TurretManageGeometry").apply(panel)
    if panel.orderPanel then
        panel.orderPanel:reflow()
        return
    end
    local screen = getPlayerScreenHeight(panel.player:getPlayerNum())
    if not geometryChanged and screen == panel.layoutScreen and panel.detailsOpen == panel.layoutDetails and panel.moduleLines == panel.layoutLines
        and panel.hasLure == panel.layoutLure and panel.hasLanding == panel.layoutLanding then return end
    local detailsChanged = panel.layoutDetails ~= panel.detailsOpen
    panel.layoutScreen, panel.layoutDetails, panel.layoutLines = screen, panel.detailsOpen, panel.moduleLines
    panel.layoutLure, panel.layoutLanding = panel.hasLure, panel.hasLanding
    local h = panel.lineHeight
    local compact = screen < 900
    local row = math.max(compact and 22 or 28, h + (compact and 2 or 8))
    panel.compactFooter = compact
    panel.detailsButton:setHeight(row)
    panel.detailLines = string.split(getTextManager():WrapText(UIFont.Small, panel.moduleLines or "", math.floor(panel.body.width / 2) - 28), "\n")
    panel.detailsButton:setTitle(getText(panel.detailsOpen and "UI_OMHTT_DetailsClose" or "UI_OMHTT_DetailsOpen"))
    panel.modulesBottom = panel.moduleGridBottom + (panel.compactModuleActions and 4 or row + 6)
    local detailsHeight = math.max(h * (#panel.detailLines + 3) + 16, h * 4 + 16)
    local footer = (compact and 40 or 48) + h * (compact and 1 or 2) + (compact and 8 or 14) + row * (1 + (panel.hasLure and 1 or 0) + (panel.hasLanding and 1 or 0))
    local bodyHeight = panel.modulesBottom + 8
    local desired = panel.body.y + bodyHeight + footer + (panel.detailsOpen and detailsHeight + 8 or 0)
    local detailsSpace = panel.detailsOpen and detailsHeight + 8 or 0
    panel.minimumHeight = panel.body.y + panel.minimumGridBottom + (panel.compactModuleActions and 4 or row + 6) + 8 + footer + detailsSpace
    if panel.detailsOpen and panel.minimumHeight > screen - 24 then
        panel.detailsOpen = false
        panel.result = getText("UI_OMHTT_DetailsNeedsSpace")
        panel.geometryWidth = nil
        L.refresh(panel)
        return
    end
    if panel.detailsOpen and panel.result == getText("UI_OMHTT_DetailsNeedsSpace") then
        panel.result = ""
    end
    if panel.userSized then
        if detailsChanged and panel.detailsOpen then
            panel.collapsedHeight = panel.height
            panel:setHeight(math.min(screen - 24, math.max(panel.height, desired)))
        elseif detailsChanged and panel.collapsedHeight then
            panel:setHeight(panel.collapsedHeight)
            panel.collapsedHeight = nil
        end
        panel:setHeight(math.min(screen - 24, math.max(panel.minimumHeight, desired, panel.height)))
    else
        panel:setHeight(math.min(screen - 24, desired))
    end
    if panel.resizeGrip then
        panel.resizeGrip:setY(panel.height - panel.resizeGrip.height)
    end
    local top = getPlayerScreenTop(panel.player:getPlayerNum())
    panel:setY(math.max(top + 12, math.min(panel.y, top + screen - panel.height - 12)))
    local bottom = panel.height - (compact and 40 or 48)
    panel.fireButton:setY(bottom)
    panel.priorityButton:setY(bottom)
    panel.targetingButton:setY(bottom)
    panel.feedbackY = bottom - h * (compact and 1 or 2) - (compact and 4 or 8)
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
    panel.detailsY = panel.modulesBottom + 8
    panel.detailsButton:setY(panel.compactModuleActions and panel.modulesY + panel.headerHeight + 2 or panel.moduleGridBottom + 2)
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
        panel.slots[i]:setVisible(true)
    end
    panel.powerButton:setVisible(true)
    if panel.sourceButton then
        panel.sourceButton:setVisible(true)
        panel.setAimButton:setVisible(true)
    end
    panel.reloadButton:setVisible(true)
    panel.loadOrderButton:setVisible(true)
    panel.equipmentHelp:setVisible(true)
    panel.ammunitionHelp:setVisible(true)
    panel.modulesHelp:setVisible(true)
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
    Theme.section(self, x, y, width, bottom - y, self.owner.headerHeight, title)
end

---@return nil
function Body:prerender()
    local p, h = self.owner, self.owner.lineHeight
    self:drawRectStatic(0, 0, self.width, self.height, .12, 0, 0, 0)
    self:setStencilRect(0, 0, self.width, self.height)
    self:section(4, p.equipmentWidth, 4, p.equipmentBottom, getText("UI_OMHTT_Equipment"))
    self:section(p.ammunitionX, p.ammunitionWidth, 4, p.ammunitionBottom, getText("UI_OMHTT_Ammunition"))
    self:section(4, self.width - 12, p.modulesY, p.modulesBottom, p.moduleLabel)
    if p.hasLockedSlots then
        self:drawText(getText("UI_OMHTT_ExpansionHint"), 12, p.modulesY + p.headerHeight + 4, .75, .75, .75, 1, UIFont.Small)
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
    panel.body = Body:new(6, nameBottom + 8, width - 12, 200)
    panel.body.owner = panel
    panel.body:initialise()
    panel.body.background = false
    panel:addChild(panel.body)
    panel.body:setScrollChildren(false)
    for i = 1, #panel.slots do
        adopt(panel, panel.slots[i])
    end
    adopt(panel, panel.setAimButton)
    adopt(panel, panel.powerButton)
    adopt(panel, panel.reloadButton)
    adopt(panel, panel.loadOrderButton)
    adopt(panel, panel.benefitList)
    if panel.sourceButton then
        adopt(panel, panel.sourceButton)
    end
    local rowWidth = panel.body.width - 28
    panel.headerHeight = math.max(26, h + 8)
    local slot = math.max(54, h * 3 + 6)
    panel.slotHeight = slot
    panel.equipmentWidth = math.floor((rowWidth - 8) * .50)
    panel.ammunitionX = panel.equipmentWidth + 12
    panel.ammunitionWidth = panel.body.width - 8 - panel.ammunitionX
    local equipment = panel.equipmentWidth - 8
    local ammoX, ammoWidth = panel.ammunitionX + 4, panel.ammunitionWidth - 8
    local measure = getTextManager()
    local reloadWidth = math.max(80, measure:MeasureStringX(UIFont.Small, getText("UI_OMHTT_Reload")) + 16)
    local orderWidth = math.max(114, measure:MeasureStringX(UIFont.Small, getText("UI_OMHTT_LoadOrder")) + 16)
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
    local buttonY = second + slot + 6
    panel.loadOrderButton:setWidth(orderWidth)
    panel.loadOrderButton:setX(ammoX + ammoWidth - orderWidth)
    panel.loadOrderButton:setY(buttonY)
    panel.reloadButton:setX(panel.loadOrderButton.x - reloadWidth - 6)
    panel.reloadButton:setWidth(reloadWidth)
    panel.reloadButton:setY(buttonY)
    panel.equipmentBottom = buttonY + panel.reloadButton.height + 6
    if panel.sourceButton then
        panel.sourceButton:setX(8)
        panel.sourceButton:setY(buttonY)
        panel.sourceButton:setWidth(equipment)
        panel.sourceButton:setHeight(panel.reloadButton.height)
    end
    panel.ammunitionY, panel.ammunitionBottom = 4, panel.equipmentBottom
    panel.modulesY = panel.ammunitionBottom + 10
    for i = 1, 16 do
        panel.moduleSlots[i].compact = true
    end
    panel.moduleGridBottom = panel.modulesY + panel.headerHeight + h + 10 + 4 * (h * 2 + 20)
    panel.benefitList:setX(8)
    panel.benefitList:setY(panel.moduleGridBottom + 10)
    panel.benefitList:setWidth(rowWidth)
    panel.benefitList:setHeight(h * 7)
    panel.benefitList.visibleRows = 6
    panel.detailsButton = ISButton:new(8 + rowWidth - 110, panel.moduleGridBottom + 2, 110, math.max(28, h + 8), "", panel, function(self)
        self.detailsOpen = not self.detailsOpen
        L.refresh(self)
    end)
    panel.detailsButton:initialise()
    Theme.button(panel.detailsButton)
    Theme.button(panel.loadOrderButton)
    Theme.button(panel.reloadButton)
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
    panel.ammunitionHelp = help(panel.ammunitionX, 4, panel.ammunitionWidth, "UI_OMHTT_AmmunitionHelp")
    panel.modulesHelp = help(4, panel.modulesY, panel.body.width - 12, "UI_OMHTT_ModulesHelp")
    panel.detailsButton.tooltip = getText("UI_OMHTT_ModuleStatsHelp")
    panel.headerHelp = {panel.equipmentHelp, panel.ammunitionHelp, panel.modulesHelp, panel.detailsButton}
    L.refresh(panel)
end

---@param panel ISPanel Window
---@return nil
function L.page(panel)
    local visible = panel.orderPanel == nil
    if panel.pageVisible ~= visible then
        for i = 1, #panel.headerHelp do
            local control = panel.headerHelp[i]
            if control.tooltipUI then
                control.tooltipUI:removeFromUIManager()
                control.tooltipUI = nil
            end
        end
        panel.pageVisible = visible
    end
    panel.body:setVisible(visible)
    panel.nameEntry:setVisible(visible)
    if panel.sourceButton then
        panel.sourceButton:setVisible(visible)
        panel.setAimButton:setVisible(visible)
    end
    panel.rangeSlider:setVisible(visible)
    panel.fireButton:setVisible(visible)
    panel.priorityButton:setVisible(visible)
    panel.targetingButton:setVisible(visible)
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
    Theme.title(panel, "UI_OMHTT_TurretTitle")
    if panel.orderPanel then return end
    panel:drawTextRight(panel.weightLabel or "", panel.width - 12, panel.titleHeight + 10, .75, .75, .75, 1, UIFont.Small)
    panel:drawText(getText("UI_OMHTT_EngagementRange", T.state(panel.object).engagementRange and string.format("%.1f", panel.engagementRange) or getText("UI_OMHTT_RangeMax")), 12, panel.rangeY + 4, 1, 1, 1, 1, UIFont.Small)
    require("OMHTT/TurretManageExtras").draw(panel)
    panel:setStencilRect(12, panel.feedbackY, panel.width - 24, panel.lineHeight * 2)
    local status = getText("UI_OMHTT_Manage" .. panel.status) .. " | " .. panel.powerLabel
    local feedback = panel.reason ~= "" and panel.reason or panel.result
    panel:drawText(panel.compactFooter and feedback ~= "" and feedback or status, 12, panel.feedbackY, .85, .85, .85, 1, UIFont.Small)
    if not panel.compactFooter then
        panel:drawText(feedback, 12, panel.feedbackY + panel.lineHeight, .95, .85, .65, 1, UIFont.Small)
    end
    panel:clearStencilRect()
end

return L
