if isServer() then return end
require("ISUI/ISPanel")
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
    self:drawRectStatic(0, 0, self.width, self.height, .95, .045, .04, .035)
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
    local stock = A.state(panel.object).kind == "Controller"
    panel.stockCompact = stock and panel.width < 980
    panel.controlWidth = stock and not panel.stockCompact and math.floor(panel.width * .62) or panel.width
    panel.equipmentY = panel.titleHeight + 10
    panel.devicesY = panel.equipmentY + h * 5 + 34
    panel.detailX = math.floor(panel.controlWidth * .29)
    local x, y, width = panel.detailX + 10, panel.devicesY, panel.controlWidth - panel.detailX - 24
    local half = (width - 8) / 2
    place(panel.devices, 12, y, panel.detailX - 24)
    panel.devices:setHeight(panel.height - y - 14)
    panel.devices:setFont(UIFont.Small, 8)
    panel.devices.itemheight = h + 10
    place(panel.nameEntry, x, y + 8, width)
    panel.infoY = y + 46
    panel.actionY = panel.infoY + h * 4 + 8
    place(panel.manage, x, panel.actionY, half)
    place(panel.assign, x + half + 8, panel.actionY, half)
    panel.accessY = panel.actionY + 40
    place(panel.policy, x, panel.accessY + h, width)
    panel.connectionY = panel.accessY + h * 2 + 42
    place(panel.source, x, panel.connectionY + h * 3, half)
    place(panel.trigger, x + half + 8, panel.connectionY + h * 3, half)
    place(panel.link, x, panel.connectionY + h * 3, half)
    place(panel.unlink, x + half + 8, panel.connectionY + h * 3, half)
    place(panel.clearInputs, x, panel.connectionY + h * 3 + 36, width)
    place(panel.stockButton, panel.controlWidth / 2 + 10, panel.equipmentY + h * 3 + 12, panel.controlWidth / 2 - 34)
    panel.manage:setTitle(getText("UI_OMHTT_OpenManage"))
    panel.source:setTitle(getText("UI_OMHTT_SelectInput"))
    panel.link:setTitle(getText("UI_OMHTT_LinkInput"))
    panel.unlink:setTitle(getText("UI_OMHTT_UnlinkInput"))
    panel.clearInputs:setTitle(getText("UI_OMHTT_ClearInputs"))
    Theme.button(panel.manage)
    panel.stockButtonY = panel.stockButton.y
    panel.stockButton:setVisible(panel.stockCompact == true)
    panel.detailBody = Details:new(panel.detailX, y, panel.controlWidth - panel.detailX - 12, panel.height - y - 14)
    local body = panel.detailBody
    body.owner = panel
    body:initialise()
    body.background = false
    panel:addChild(body)
    body:setScrollChildren(true)
    body:addScrollBars(false)
    local controls = {panel.nameEntry, panel.manage, panel.assign, panel.policy, panel.source, panel.trigger, panel.link, panel.unlink, panel.clearInputs}
    for i = 1, #controls do
        local control = controls[i]
        panel:removeChild(control)
        control:setX(control.x - body.x)
        control:setY(control.y - body.y)
        body:addChild(control)
    end
    body.contentHeight = panel.clearInputs.y + panel.clearInputs.height + 12
    body:setScrollHeight(body.contentHeight)
    L.refresh(panel, A.state(panel.object))
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
    local info = kind == "Controller" and 10 or row + 18
    panel.infoY = body.y + info
    local actionY = info + h * 4 + 8
    place(panel.manage, x, actionY, half)
    place(panel.assign, x + half + 8, actionY, half)
    local access = actionY + ((kind == "Turret" or assigned) and row + 12 or 0)
    panel.accessY = body.y + access
    place(panel.policy, x, access + h + 8, width)
    panel.policy:setHeight(row)
    panel.ownerY = access + h + row + 14
    local connection = panel.ownerY + h + 14
    panel.connectionY = body.y + connection
    local controlsY = connection + h * 3 + 12
    place(panel.source, x, controlsY, half)
    place(panel.trigger, x + half + 8, controlsY, half)
    place(panel.link, x, controlsY, half)
    place(panel.unlink, x + half + 8, controlsY, half)
    place(panel.clearInputs, x, controlsY + row + 8, width)
    local controls = {panel.manage, panel.assign, panel.source, panel.trigger, panel.link, panel.unlink, panel.clearInputs}
    for i = 1, #controls do
        controls[i]:setHeight(row)
    end
    body.contentHeight = panel.clearInputs.y + row + 12
    body:setScrollHeight(kind == "Controller" and controlsY + 8 or body.contentHeight)
    body.contentHeight = kind == "Controller" and controlsY + 8 or body.contentHeight
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
        local contents = require("OMHTT/Turret").contents(panel.selected:getContainer())
        panel.ammoSummary = getText("UI_OMHTT_ControllerAmmo", contents.reserveAll, contents.virtualAmmo)
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
        h * 4 + 22, h + 8, getText("UI_OMHTT_Equipment"))
    local power = host.powered and "UI_OMHTT_ControllerPowerReady" or "UI_OMHTT_ControllerPowerEmpty"
    local textX = panel.controlWidth / 2 + 10
    panel:setStencilRect(textX, panel.equipmentY + h + 10, panel.controlWidth / 2 - 32, h * 3 + 8)
    panel:drawText(getText(power), textX, panel.equipmentY + h + 10, .85, .85, .85, 1, UIFont.Small)
    panel:drawText(getText("UI_OMHTT_ControllerRange"), textX, panel.equipmentY + h * 2 + 12, .7, .7, .7, 1, UIFont.Small)
    panel:clearStencilRect()
    panel:drawText(getText("UI_OMHTT_Devices"), 12, panel.devicesY - h - 2, .9, .75, .6, 1, UIFont.Small)
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
    body:section(accessY, connectionY - 10, getText("UI_OMHTT_AccessTitle"))
    body:section(connectionY, body.contentHeight - 4, getText("UI_OMHTT_Connections"))
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
    body:setStencilRect(x, connectionY + h + 8 + scroll, width, h * 2)
    local hint = getText("UI_OMHTT_SelectInputHint")
    if state.kind == "Controller" then
        hint = getText("UI_OMHTT_ControllerRange")
    elseif panel.linkSource then
        hint = getText("UI_OMHTT_SelectedInput", U.name(panel.linkSource))
    end
    body:drawText(hint, x, connectionY + h + 8, .8, .8, .8, 1, UIFont.Small)
    local count = getText("UI_OMHTT_OutputCount", #state.links)
    if state.kind == "Turret" then
        count = getText("UI_OMHTT_ReceiverHint")
    end
    if state.kind == "Controller" then
        count = getText("UI_OMHTT_ControllerLimits")
    end
    body:drawText(count, x, connectionY + h * 2 + 8, .7, .7, .7, 1, UIFont.Small)
    body:clearStencilRect()
    body:repaintStencilRect(0, 0, body.width, body.height)
end

return L
