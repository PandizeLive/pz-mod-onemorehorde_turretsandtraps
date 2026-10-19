if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local L = {}
local Theme = require("OMHTT/ControlTheme")
local U = require("OMHTT/ControlClient")
local A = require("OMHTT/ControlAccess")
local Details = ISPanel:derive("OMHTTControllerDetails")

---@param delta number Wheel movement
---@return boolean handled
function Details:onMouseWheel(delta)
    self:setYScroll(math.max(math.min(0, self.height - self.contentHeight), math.min(0, self:getYScroll() - delta * 36)))
    return true
end

---@return nil
function Details:prerender()
    self:drawRectStatic(0, 0, self.width, self.height, .95, .045, .045, .045)
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
    panel.titleHeight = getTextManager():getFontHeight(UIFont.Medium) + 16
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
    local controls = {panel.nameEntry, panel.manage, panel.assign, panel.policy, panel.trigger}
    for i = 1, #controls do
        local control = controls[i]
        panel:removeChild(control)
        control:setX(control.x - body.x)
        control:setY(control.y - body.y)
        body:addChild(control)
    end
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
    local y, bottom = panel.devicesY, panel.height - 24
    local graphWidth = math.max(260, math.floor((panel.controlWidth - 24) * .40))
    panel.detailX = 12 + graphWidth + 8
    local centerWidth = panel.controlWidth - panel.detailX - 8
    place(panel.graph, 12, y, graphWidth)
    panel.graph:setHeight(bottom - y)
    Theme.scrollbar(panel.graph)
    local toolbar = h + 10
    local detailHeight = math.min(h * 15 + 158, math.max(100, bottom - y - toolbar - 100))
    local mapHeight = math.max(64, bottom - y - toolbar - detailHeight - 8)
    panel.mapY = y
    local mapTop = y + toolbar
    place(panel.mapView, panel.detailX, mapTop, centerWidth)
    panel.mapView:setHeight(mapHeight)
    local detailsY = mapTop + mapHeight + 8
    place(panel.detailBody, panel.detailX, detailsY, centerWidth)
    panel.detailBody:setHeight(math.max(80, bottom - detailsY))
    Theme.scrollbar(panel.detailBody)
    panel.layoutKind = nil
    panel.closeButton:setX(panel.width - 40)
    panel.stockButtonY = panel.equipmentY + h * 3 + 12
    place(panel.stockButton, panel.controlWidth / 2 + 10, panel.stockButtonY, panel.controlWidth / 2 - 34)
    panel.stockButton:setVisible(panel.stockCompact)
    if panel.batterySlot then
        place(panel.batterySlot, 22, panel.equipmentY + h + 12, math.floor(panel.controlWidth / 2) - 30)
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
        panel.detailBody:setVisible(true)
        if panel.batterySlot then
            panel.batterySlot:setVisible(true)
        end
    end
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
    place(panel.nameEntry, x, h + 14, width)
    panel.nameEntry:setHeight(row)
    local info = kind == "Controller" and h + 14 or h + row + 24
    panel.infoY = body.y + info
    panel.controlsY = info + h * 4 + 8
    local actionY = panel.controlsY + h + 12
    place(panel.manage, x, actionY, width)
    local connection = actionY + (kind == "Turret" and row + 14 or 0)
    panel.connectionY = body.y + connection
    local controlsY = connection + h * 3 + 16
    place(panel.trigger, x, controlsY, width)
    local bottom = controlsY + (kind == "Plate" and row + 12 or 6)
    panel.accessY = body.y + bottom
    place(panel.policy, x, bottom + h + 12, assigned and half or width)
    place(panel.assign, x + half + 8, bottom + h + 12, half)
    panel.ownerY = bottom + h + row + 20
    local controls = {panel.policy, panel.manage, panel.assign, panel.trigger}
    for i = 1, #controls do
        controls[i]:setHeight(row)
    end
    body.contentHeight = panel.ownerY + h + 14
    local height = math.min(body.contentHeight, math.max(100, panel.height - 24 - panel.mapView.y - 108))
    local y = panel.height - 24 - height
    local delta = y - body.y
    panel.infoY, panel.connectionY, panel.accessY = panel.infoY + delta, panel.connectionY + delta, panel.accessY + delta
    body:setY(y)
    body:setHeight(height)
    panel.mapView:setHeight(math.max(64, y - panel.mapView.y - 8))
    Theme.scrollbar(body)
    body:setScrollHeight(body.contentHeight)
    body:setYScroll(math.max(math.min(0, body.height - body.contentHeight), body:getYScroll()))
end

---@param y number Content top
---@param bottom number Content bottom
---@param title string Section label
---@return nil
function Details:section(y, bottom, title)
    local width = self.width - 24
    Theme.section(self, 4, y, width, bottom - y, self.owner.lineHeight + 6, title)
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
    panel:drawText(getText("UI_OMHTT_ControllerRange"), textX, panel.equipmentY + h * 2 + 12, .7, .7, .7, 1, UIFont.Small)
    panel:clearStencilRect()
    Theme.section(panel, panel.detailX, panel.mapY, panel.mapView.width,
        panel.mapView.y + panel.mapView.height - panel.mapY, h + 8, getText("UI_OMHTT_Map"))
end

---@param panel ISPanel Controller window
---@param host table? Host state
---@param state table? Selection state
---@return nil
function L.drawDetails(panel, host, state)
    if not host or not state then return end
    local body, h, x = panel.detailBody, panel.lineHeight, 10
    local width = body.width - 36
    local infoY, accessY, connectionY = panel.infoY - body.y, panel.accessY - body.y, panel.connectionY - body.y
    body:section(4, panel.controlsY - 4, getText("UI_OMHTT_SelectedDevice"))
    if state.kind == "Turret" then
        body:section(panel.controlsY, connectionY - 8, getText("UI_OMHTT_Controls"))
    end
    body:section(accessY, body.contentHeight - 4, getText("UI_OMHTT_AccessAssignment"))
    body:section(connectionY, accessY - 10, getText("UI_OMHTT_Connections"))
    local scroll = body:getYScroll()
    body:setStencilRect(x, infoY + scroll, width, h * 4)
    local dx, dy = panel.selected:getX() - panel.object:getX(), panel.selected:getY() - panel.object:getY()
    body:drawText(getText("UI_OMHTT_DeviceDistance", string.format("%.1f", math.sqrt(dx * dx + dy * dy))), x, infoY, .75, .75, .75, 1, UIFont.Small)
    local status = state.active and "UI_OMHTT_InputOn" or "UI_OMHTT_InputOff"
    if state.kind == "Turret" then
        local T = require("OMHTT/Turret")
        status = T.isOn(T.state(panel.selected)) and "UI_OMHTT_PowerOn" or "UI_OMHTT_PowerOff"
    elseif state.kind == "Controller" then
        status = state.powered and "UI_OMHTT_PowerOn" or "UI_OMHTT_PowerOff"
    end
    body:drawText(getText(status), x, infoY + h, .85, .85, .85, 1, UIFont.Small)
    local assigned = state.controller == host.id and "UI_OMHTT_DeviceAssigned" or "UI_OMHTT_DeviceUnassigned"
    if panel.selected == panel.object then
        assigned = "UI_OMHTT_ControlController"
    end
    local info = getText("UI_OMHTT_DeviceCondition", panel.selected:getHealth(), panel.selected:getMaxHealth())
    body:drawText(panel.ammoSummary or info, x, infoY + h * 2, .75, .75, .75, 1, UIFont.Small)
    body:drawText(panel.ammoSummary and info or getText(assigned), x, infoY + h * 3, .75, .75, .75, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
    body:setStencilRect(x, panel.ownerY + scroll, width, h)
    body:drawText(getText("UI_OMHTT_ControlOwner", state.owner), x, panel.ownerY, .65, .65, .65, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
    local hintY = connectionY + h + 8
    body:setStencilRect(x, hintY + scroll, width, h * 2)
    local hint = getText(panel.graph.notice or "UI_OMHTT_GraphConnectHint")
    if not panel.graph.notice and state.kind == "Controller" then
        hint = getText("UI_OMHTT_ControllerRange")
    elseif panel.linkSource then
        hint = getText("UI_OMHTT_SelectedInput", U.name(panel.linkSource))
    end
    body:drawText(hint, x, hintY, .8, .8, .8, 1, UIFont.Small)
    local count = getText("UI_OMHTT_OutputCount", #state.links)
    if state.kind == "Turret" then
        local source = A.state(panel.linkSource)
        count = getText(source and (require("OMHTT/ControlDefinitions").linked(source, state)
            and "UI_OMHTT_InputConnected" or "UI_OMHTT_InputNotConnected") or "UI_OMHTT_GraphDisconnectHint")
    end
    if panel.linkSource == panel.selected and state.kind ~= "Turret" then
        count = getText("UI_OMHTT_SelectReceiverHint")
    end
    if state.kind == "Controller" then
        count = getText("UI_OMHTT_ControllerLimits")
    end
    body:drawText(count, x, hintY + h, .7, .7, .7, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
end

return L
