if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local L = {}
local Theme = require("OMHTT/ControlTheme")
local U = require("OMHTT/ControlClient")
local A = require("OMHTT/ControlAccess")
local Details = ISPanel:derive("OMHTTControllerDetails")
local HostDetails = require("OMHTT/ControlHostDetails")

---@param delta number Wheel movement
---@return boolean handled
function Details:onMouseWheel(delta)
    self:setYScroll(math.max(math.min(0, self.height - self.contentHeight), math.min(0, self:getYScroll() - delta * 36)))
    return true
end

---@return nil
function Details:prerender()
    self:drawRectStatic(0, 0, self.width, self.height, .12, .045, .045, .045)
    self:setStencilRect(0, 0, self.width, self.height)
    L.drawDetails(self.owner, A.state(self.owner.object), A.state(self.owner.selected))
end

---@return nil
function Details:render()
    self:clearStencilRect()
end

---@param control ISUIElement Control
---@param x number Left
---@param y number Top
---@param width number Width
---@return nil
local function place(control, x, y, width)
    control:setX(x)
    control:setY(y)
    control:setWidth(width)
end

---@param panel ISPanel Controller window
---@return nil
function L.create(panel)
    local h = getTextManager():getFontHeight(UIFont.Small) + 4
    panel.lineHeight = h
    panel.titleHeight = math.max(16, getTextManager():getFontHeight(UIFont.Small) + 1)
    panel.devices:setFont(UIFont.Small, 8)
    panel.devices.itemheight = h + 10
    panel.detailBody = Details:new(12, 180, 400, 300)
    local body = panel.detailBody
    body.owner = panel
    body:initialise()
    body.background = false
    panel:addChild(body)
    body:setScrollChildren(true)
    body:addScrollBars(false)
    Theme.scrollbar(body)
    local controls = {panel.nameEntry, panel.manage, panel.assign, panel.policy, panel.trigger, panel.targeting}
    for i = 1, #controls do
        local control = controls[i]
        panel:removeChild(control)
        control:setX(control.x - body.x)
        control:setY(control.y - body.y)
        body:addChild(control)
    end
    panel.hostBody = HostDetails.create(panel)
    panel.settingsTab = "Device"
    panel.deviceTab = ISButton:new(0, 0, 120, h + 10, getText("UI_OMHTT_DeviceSettings"), panel, function(owner)
        L.tab(owner, "Device")
    end)
    panel.controllerTab = ISButton:new(0, 0, 120, h + 10, getText("UI_OMHTT_ControllerSettings"), panel, function(owner)
        L.tab(owner, "Controller")
    end)
    panel.deviceTab:initialise()
    panel.controllerTab:initialise()
    Theme.button(panel.deviceTab)
    Theme.button(panel.controllerTab)
    panel:addChild(panel.deviceTab)
    panel:addChild(panel.controllerTab)
    panel.graph = require("OMHTT/ControlGraph").create(panel)
    panel.mapView = require("OMHTT/ControlMap").create(panel)
    panel.devices:setVisible(false)
    L.arrange(panel)
    L.refresh(panel, A.state(panel.object))
end

---@param panel ISPanel Controller window
---@return nil
function L.arrange(panel)
    if panel.geometryWidth == panel.width and panel.geometryHeight == panel.height then return end
    panel.geometryWidth, panel.geometryHeight = panel.width, panel.height
    local h = panel.lineHeight
    local stock = math.max(320, math.floor(panel.width * .28))
    panel.stockCompact = panel.width < 1160
    panel.controlWidth = panel.stockCompact and panel.width or panel.width - stock - 8
    panel.equipmentY = panel.titleHeight + 8
    panel.devicesY = panel.equipmentY + h * (panel.stockCompact and 5 or 4) + 34
    local y, bottom = panel.devicesY, panel.height - (panel.footerHeight or 14) - 6
    local graphWidth = math.max(260, math.floor((panel.controlWidth - 24) * .40))
    panel.detailX = 12 + graphWidth + 8
    local centerWidth = panel.controlWidth - panel.detailX - 8
    place(panel.graph, 12, y, graphWidth)
    panel.graph:setHeight(bottom - y)
    Theme.scrollbar(panel.graph)
    local toolbar = h + 10
    local detailHeight = math.max(80, math.floor((bottom - y - toolbar - 8) / 3))
    local mapHeight = math.max(64, bottom - y - toolbar - detailHeight - 8)
    panel.mapY = y
    local mapTop = y + toolbar
    place(panel.mapView, panel.detailX, mapTop, centerWidth)
    panel.mapView:setHeight(mapHeight)
    local detailsY = mapTop + mapHeight + 8
    local tabHeight = h + 10
    place(panel.deviceTab, panel.detailX, detailsY, math.floor(centerWidth / 2))
    place(panel.controllerTab, panel.detailX + math.floor(centerWidth / 2), detailsY, centerWidth - math.floor(centerWidth / 2))
    detailsY = detailsY + tabHeight + 4
    place(panel.detailBody, panel.detailX, detailsY, centerWidth)
    place(panel.hostBody, panel.detailX, detailsY, centerWidth)
    panel.hostBody:setHeight(math.max(40, bottom - detailsY))
    panel.hostBody:arrange()
    panel.detailBody:setHeight(math.max(40, bottom - detailsY))
    Theme.scrollbar(panel.detailBody)
    panel.layoutKind = nil
    panel.stockButtonY = panel.equipmentY + h * 3 + 12
    place(panel.stockButton, panel.controlWidth / 2 + 10, panel.stockButtonY, panel.controlWidth / 2 - 34)
    panel.stockButton:setVisible(panel.stockCompact)
    local slotWidth = math.floor((math.floor(panel.controlWidth / 2) - 38) / 2)
    if panel.batterySlot then
        place(panel.batterySlot, 22, panel.equipmentY + h + 12, slotWidth)
    end
    if panel.expansionSlot then
        place(panel.expansionSlot, 30 + slotWidth, panel.equipmentY + h + 12, slotWidth)
    end
    if panel.stockWing then
        local wing = panel.stockWing
        place(wing, panel.stockCompact and 12 or panel.controlWidth + 8,
            panel.stockCompact and panel.titleHeight + 10 or panel.equipmentY,
            panel.stockCompact and panel.width - 24 or stock - 20)
        wing:setHeight(panel.stockCompact and panel.height - wing.y - 54 or bottom - wing.y)
        local pane = wing.inventoryPane
        pane:setWidth(wing.width - 12)
        pane:setHeight(wing.height - pane.y - 6)
        Theme.scrollbar(pane)
        wing:setVisible(not panel.stockCompact)
        if pane.nameHeader then
            pane.column3 = math.max(pane.column2 + 60, pane.width - 90)
            pane.nameHeader:setWidth(pane.column3 - pane.column2)
            pane.typeHeader:setX(pane.column3 - 1)
            pane.typeHeader:setWidth(pane.width - 18 - pane.typeHeader.x)
            pane.column4 = pane.width - 18
        end
    end
    panel.devices:setVisible(false)
    L.refresh(panel, A.state(panel.selected))
    if panel.stockCompact then
        panel:showStockpile(panel.stockPage == true)
    else
        panel.stockPage = false
        panel.graph:setVisible(true)
        panel.mapView:setVisible(true)
        L.tab(panel, panel.settingsTab)
        if panel.batterySlot then
            panel.batterySlot:setVisible(true)
        end
        if panel.expansionSlot then panel.expansionSlot:setVisible(true) end
    end
end

---@param panel ISPanel Controller window
---@param tab string Device or Controller
---@return nil
function L.tab(panel, tab)
    panel.settingsTab = tab
    local visible = panel.stockPage ~= true
    panel.detailBody:setVisible(visible and tab == "Device")
    panel.hostBody:setVisible(visible and tab == "Controller")
    panel.deviceTab:setVisible(visible)
    panel.controllerTab:setVisible(visible)
    panel.deviceTab:setEnable(tab ~= "Device")
    panel.controllerTab:setEnable(tab ~= "Controller")
end

---@param panel ISPanel Controller window
---@param state table? Selected device
---@return nil
function L.refresh(panel, state)
    local kind = state and state.kind or "Controller"
    local assigned = panel.selected ~= panel.object and kind ~= "Controller"
    if panel.layoutKind == kind and panel.layoutAssigned == assigned then return end
    panel.layoutKind, panel.layoutAssigned = kind, assigned
    local body, h = panel.detailBody, panel.lineHeight
    local x, width = 10, body.width - 36
    local half = (width - 8) / 2
    local row = math.max(28, h + 6)
    place(panel.nameEntry, x, 8, width)
    panel.nameEntry:setHeight(row)
    local info = row + 16
    panel.infoY = body.y + info
    panel.controlsY = info + h * 2 + 8
    local actionY = panel.controlsY
    place(panel.manage, x, actionY, half)
    place(panel.assign, x + half + 8, actionY, half)
    local policyY = actionY + row + 8
    place(panel.targeting, x, policyY, half)
    place(panel.policy, x + half + 8, policyY, half)
    panel.targeting:setHeight(row)
    local bottom = policyY + row + 8
    place(panel.trigger, x, bottom, width)
    if kind == "Plate" or kind == "Lever" or kind == "Button" then
        bottom = bottom + row + 8
    end
    panel.accessY = body.y + policyY
    panel.connectionY = body.y + bottom
    panel.ownerY = bottom + h * 2 + 6
    local controls = {panel.policy, panel.manage, panel.assign, panel.trigger}
    for i = 1, #controls do
        controls[i]:setHeight(row)
    end
    body.contentHeight = assigned and panel.ownerY + h + 10 or body.height
    Theme.scrollbar(body)
    body:setScrollHeight(body.contentHeight)
    body:setYScroll(math.max(math.min(0, body.height - body.contentHeight), body:getYScroll()))
end

---@param y number Content top
---@param bottom number Content bottom
---@param title string Section label
---@return nil
function Details:section(y, bottom, title)
    local width = self.width
    Theme.section(self, 0, y, width, bottom - y, self.owner.lineHeight + 6, title)
end

---@param panel ISPanel Controller window
---@return nil
function L.snapshot(panel)
    local container = panel.object:getContainer()
    panel.stockWeight = container and container:getCapacityWeight() or 0
    panel.ammoSummary = nil
    local state = A.state(panel.selected)
    if state and state.kind == "Turret" then
        local stats = panel.graph.stats[panel.selected]
        panel.ammoSummary = stats and stats.label or getText("UI_OMHTT_GraphAmmoPending")
    end
end

---@param panel ISPanel Controller window
---@param host table Host state
---@param state table? Selection state
---@return nil
function L.draw(panel, host, state)
    local h, x, width = panel.lineHeight, panel.detailX + 10, panel.controlWidth - panel.detailX - 24
    Theme.title(panel, "UI_OMHTT_ControllerTitle")
    if panel.stockPage then return end
    Theme.section(panel, 12, panel.equipmentY, panel.controlWidth - 24,
        panel.devicesY - panel.equipmentY - 10, h + 8, getText("UI_OMHTT_Equipment"))
    local power = host.powered and "UI_OMHTT_ControllerPowerReady" or "UI_OMHTT_ControllerPowerEmpty"
    local textX = panel.controlWidth / 2 + 10
    panel:setStencilRect(textX, panel.equipmentY + h + 10, panel.controlWidth / 2 - 32, h * 3 + 8)
    panel:drawText(getText(power), textX, panel.equipmentY + h + 10, .85, .85, .85, 1, UIFont.Small)
    panel:drawText(getText("UI_OMHTT_ControllerRange", A.radius(panel.object)), textX, panel.equipmentY + h * 2 + 12, .7, .7, .7, 1, UIFont.Small)
    panel:clearStencilRect()
    Theme.section(panel, panel.detailX, panel.mapY, panel.mapView.width,
        panel.mapView.y + panel.mapView.height - panel.mapY, h + 8, getText("UI_OMHTT_Map"))
end

---@param panel ISPanel Controller window
---@param host table? Host state
---@param state table? Selection state
---@return nil
function L.drawDetails(panel, host, state)
    if not host then return end
    local body, h, x = panel.detailBody, panel.lineHeight, 10
    local width, scroll = body.width - 36, body:getYScroll()
    if not state or panel.selected == panel.object then
        body:drawText(getText("UI_OMHTT_SelectDevice"), x, 10, .8, .8, .8, 1, UIFont.Small)
        return
    end
    local infoY = panel.infoY - body.y
    local half = (width - 8) / 2
    local dx, dy = panel.selected:getX() - panel.object:getX(), panel.selected:getY() - panel.object:getY()
    local status = state.active and "UI_OMHTT_InputOn" or "UI_OMHTT_InputOff"
    if state.kind == "Turret" then
        local T = require("OMHTT/Turret")
        status = T.isOn(T.state(panel.selected)) and "UI_OMHTT_PowerOn" or "UI_OMHTT_PowerOff"
    elseif state.kind == "Tether" then
        status = "UI_OMHTT_TetherStats"
    elseif state.kind == "Poke" then
        status = "UI_OMHTT_PokeContact"
    elseif require("OMHTT/ControlDefinitions").inputs[state.kind] and state.powered ~= true then
        status = "UI_OMHTT_TriggerUnpowered"
    end
    body:setStencilRect(x, infoY + scroll, half, h * 2)
    body:drawText(getText(status), x, infoY, .85, .85, .85, 1, UIFont.Small)
    body:drawText(getText("UI_OMHTT_DeviceCondition", panel.selected:getHealth(), panel.selected:getMaxHealth()), x, infoY + h, .75, .75, .75, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
    body:setStencilRect(x + half + 8, infoY + scroll, half, h * 2)
    body:drawText(getText("UI_OMHTT_DeviceDistance", string.format("%.1f", math.sqrt(dx * dx + dy * dy))), x + half + 8, infoY, .75, .75, .75, 1, UIFont.Small)
    body:drawText(panel.ammoSummary or getText(state.controller == host.id and "UI_OMHTT_DeviceAssigned" or "UI_OMHTT_DeviceUnassigned"), x + half + 8, infoY + h, .75, .75, .75, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
    local hint = panel.graph.batchNotice or getText(panel.graph.notice or "UI_OMHTT_GraphConnectHint")
    if panel.linkSource then
        hint = getText("UI_OMHTT_SelectedInput", U.name(panel.linkSource))
    elseif state.kind == "Poke" and not panel.graph.notice and not panel.graph.batchNotice then
        hint = getText("UI_OMHTT_PokeNoInputs")
    end
    body.tooltip = hint
    local key = hint .. tostring(width)
    if body.connectionKey ~= key then
        body.connectionKey = key
        body.hintLines = string.split(getTextManager():WrapText(UIFont.Small, hint, width), "\n")
    end
    local hintY = panel.connectionY - body.y
    body:setStencilRect(x, hintY + scroll, width, h * 2)
    for i = 1, math.min(2, #body.hintLines) do
        body:drawText(body.hintLines[i], x, hintY + (i - 1) * h, .8, .8, .8, 1, UIFont.Small)
    end
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
    body:setStencilRect(x, panel.ownerY + scroll, width, h)
    body:drawText(getText("UI_OMHTT_ControlOwner", state.owner), x, panel.ownerY, .7, .7, .7, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
end

return L
