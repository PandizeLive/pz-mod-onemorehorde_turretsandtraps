if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISScrollingListBox")
require("ISUI/ISTextEntryBox")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local C = require("OMHTT/ControlDefinitions")
local Panel = ISPanel:derive("OMHTTControllerPanel")
local Drag = require("OMHTT/ControlWindowDrag")
local Theme = require("OMHTT/ControlTheme")
Panel.onMouseDown = Drag.start
Panel.onMouseUp = Drag.stop
Panel.onMouseUpOutside = Drag.stop
Panel.update = Drag.update
local active = {}

---@param panel ISPanel Parent
---@param x number X
---@param y number Y
---@param width number Width
---@param text string Caption
---@param callback function Handler
---@return ISButton button
local function button(panel, x, y, width, text, callback)
    local result = ISButton:new(x, y, width, 28, text, panel, callback)
    result:initialise()
    Theme.button(result)
    panel:addChild(result)
    return result
end

---@return nil
function Panel:scan()
    if not self.scanIndex then
        self.scanIndex, self.scanObjectIndex, self.scanResults, self.scanSelection = 0, 0, {}, {}
    end
    local square, deadline = self.object:getSquare(), getTimestampMs() + 2
    if not square then return end
    for step = 1, 64 do
        local index = self.scanIndex
        if index >= 1681 then
            self.devices.items, self.devices.count = self.scanResults, #self.scanResults
            self.devices.itemheightoverride = {}
            self.devices.selected = self.scanSelection[self.selected] or 1
            self.devices:setScrollHeight(#self.scanResults * self.devices.itemheight)
            self.scanIndex, self.scanResults, self.scanSelection, self.scanObjectIndex = nil, nil, nil, nil
            self.scanDue = getTimestampMs() + 5000
            return
        end
        local dx, dy = math.floor(index / 41) - 20, index % 41 - 20
        local objects
        if dx * dx + dy * dy <= 400 then
            local tile = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
            objects = tile and tile:getObjects()
        end
        if objects and self.scanObjectIndex < objects:size() then
            local object = objects:get(self.scanObjectIndex)
            self.scanObjectIndex = self.scanObjectIndex + 1
            if object:getObjectIndex() >= 0 and A.state(object) and not self.scanSelection[object] then
                local row = #self.scanResults + 1
                self.scanResults[row] = {text = U.name(object), item = object, itemindex = row, height = self.devices.itemheight}
                self.scanSelection[object] = row
            end
        else
            self.scanIndex, self.scanObjectIndex = index + 1, 0
        end
        if getTimestampMs() >= deadline then return end
    end
end

---@return nil
function Panel:select()
    local row = self.devices.items[self.devices.selected]
    local object = row and row.item
    if object == self.selected then return end
    self.selected = object
    self.renewDue = 0
    self.nameEntry:select(object)
    if object and object ~= self.object then
        U.remote(self.player, self.object, object)
    end
end

---@return nil
function Panel:close()
    self.closed = true
    if self.cursor and getCell():getDrag(self.player:getPlayerNum()) == self.cursor then
        getCell():setDrag(nil, self.player:getPlayerNum())
    end
    self.nameEntry:commit()
    if self.stockWing then
        self.stockWing:close()
    end
    if self.batterySlot then
        self.batterySlot:cleanup()
    end
    require("OMHTT/ControlOverlay").panels[self] = nil
    if self.marker then
        self.marker:remove()
        self.marker = nil
    end
    Drag.stop(self)
    if active[self.player:getPlayerNum()] == self then
        active[self.player:getPlayerNum()] = nil
    end
    self:removeFromUIManager()
end

---@return nil
function Panel:prerender()
    if not A.state(self.object) or not A.near(self.player, self.object) then
        self:close(); return
    end
    ISPanel.prerender(self)
    local now = getTimestampMs()
    if self.scanIndex or now >= self.scanDue then
        self:scan()
    end
    self:select()
    if self.linkSource and (self.linkSource:getObjectIndex() < 0 or not A.state(self.linkSource)) then
        self.linkSource = nil
    end
    local host = A.state(self.object)
    local state = A.state(self.selected)
    if now >= (self.renewDue or 0) or self.renewTarget ~= self.selected
        or self.renewController ~= (state and state.controller) or self.renewPowered ~= host.powered then
        self.renewDue = now + 5000
        self.renewTarget, self.renewController, self.renewPowered = self.selected, state and state.controller, host.powered
        if state and self.selected ~= self.object then
            U.remote(self.player, self.object, self.selected)
        end
        if self.linkSource and self.linkSource ~= self.selected then
            U.remote(self.player, self.object, self.linkSource)
        end
        require("OMHTT/ControlPanelLayout").snapshot(self)
    end
    require("OMHTT/ControlPanelLayout").refresh(self, state)
    self.inputs:refresh()
    self.inputs:setVisible(state ~= nil and state.kind == "Turret")
    require("OMHTT/ControlPanelLayout").draw(self, host, state)
    local writable = state and A.authorized(self.player, self.selected)
    local linkable = state and A.write(self.player, state) and self.linkSource
        and A.authorized(self.player, self.linkSource) and A.range(self.linkSource, self.selected)
    self.nameEntry:refresh()
    self.nameEntry:setVisible(state ~= nil and state.kind ~= "Controller")
    self.policy:setEnable(writable and A.write(self.player, state, true) or false)
    self.manage:setEnable(state ~= nil and state.kind == "Turret"
        and (A.near(self.player, self.selected) or (host.powered == true and state.controller == host.id)))
    self.assign:setEnable(state ~= nil and self.selected ~= self.object and host.kind == "Controller"
        and host.powered == true and A.write(self.player, host) and A.write(self.player, state))
    self.link:setEnable(linkable == true)
    self.setFacing:setEnable(state ~= nil and state.kind == "Turret"
        and A.write(self.player, host) and A.write(self.player, state)
        and require("OMHTT/ControlRemote").valid(self.player, self.object, self.selected))
    self.link:setTitle(getText(C.linked(A.state(self.linkSource), state)
        and "UI_OMHTT_DisconnectInput" or "UI_OMHTT_ConnectInput"))
    self.source:setTitle(getText(self.linkSource == self.selected and "UI_OMHTT_InputSelected" or "UI_OMHTT_SelectInput"))
    self.source:setEnable(writable == true and (state.kind == "Plate" or state.kind == "Button"))
    self.trigger:setEnable(writable == true and state.kind == "Plate")
    self.clearInputs:setEnable(writable == true and state.kind == "Turret")
    self.trigger:setTitle(state and state.kind == "Plate" and "Trigger: " .. (state.trigger or "Both") or "Trigger: —")
    self.source:setVisible(state ~= nil and (state.kind == "Plate" or state.kind == "Button"))
    self.trigger:setVisible(state ~= nil and state.kind == "Plate")
    self.clearInputs:setVisible(state ~= nil and state.kind == "Turret")
    self.manage:setVisible(state ~= nil and state.kind == "Turret")
    self.assign:setVisible(state ~= nil and self.selected ~= self.object and host.kind == "Controller")
    self.link:setVisible(state ~= nil and state.kind == "Turret" and self.linkSource ~= nil)
    self.setFacing:setVisible(state ~= nil and state.kind == "Turret" and host.kind == "Controller")
    local remoteReason
    if host.powered ~= true then
        remoteReason = getText("UI_OMHTT_ControllerPowerNeeded")
    elseif not A.write(self.player, host) or (state and not A.write(self.player, state)) then
        remoteReason = getText("UI_OMHTT_ControllerAccessNeeded")
    elseif state and state.controller ~= host.id then
        remoteReason = getText("UI_OMHTT_ControllerAssignNeeded")
    else
        remoteReason = getText("UI_OMHTT_ControllerSessionPending")
    end
    self.manage.tooltip = getText("UI_OMHTT_OpenManageHelp")
    if not self.manage.enable then
        self.manage.tooltip = remoteReason
    end
    self.assign.tooltip = getText(state and state.controller == host.id and "UI_OMHTT_UnassignHelp" or "UI_OMHTT_AssignHelp")
    if not self.assign.enable then
        self.assign.tooltip = host.powered ~= true and getText("UI_OMHTT_ControllerPowerNeeded")
            or getText("UI_OMHTT_ControllerAccessNeeded")
    end
    self.policy.tooltip = getText("UI_OMHTT_AccessHelp")
    if not self.policy.enable then
        self.policy.tooltip = A.write(self.player, state, true) and remoteReason or getText("UI_OMHTT_ControllerAccessNeeded")
    end
    self.clearInputs.tooltip = self.clearInputs.enable and getText("UI_OMHTT_ClearInputsHelp") or remoteReason
    self.source.tooltip = remoteReason
    self.link.tooltip = self.source.tooltip
    self.trigger.tooltip = self.trigger.enable and getText("UI_OMHTT_TriggerHelp") or remoteReason
    self.setFacing.tooltip = self.setFacing.enable and getText("UI_OMHTT_SetFacingTooltip") or remoteReason
    if self.link.enable then
        self.link.tooltip = getText("UI_OMHTT_LinkPowerHint")
    end
    if self.source.enable then
        self.source.tooltip = getText("UI_OMHTT_SelectReceiverHint")
    end
    self.policy:setTitle(getText("UI_OMHTT_Access", state and state.access or "—"))
    self.assign:setTitle(getText(state and state.controller == host.id and "UI_OMHTT_Unassign" or "UI_OMHTT_Assign"))

end

---@param object IsoObject? Stockpile controller
---@return nil
function Panel:stockpile(object)
    require("OMHTT/ControlInventory").open(self, object or self.object)
end

---@param player IsoPlayer Operator
---@param object IsoObject Controller or local device
---@return ISPanel? panel
function Panel.open(player, object)
    local state = A.state(object)
    if not state or state.kind ~= "Controller" or not A.near(player, object) then return nil end
    local old = active[player:getPlayerNum()]
    if old then old:close() end
    local pn = player:getPlayerNum()
    local panel = Panel:new(getPlayerScreenLeft(pn) + 12, getPlayerScreenTop(pn) + 12,
        math.min(A.state(object).kind == "Controller" and 1220 or 860, getPlayerScreenWidth(pn) - 24), math.min(720, getPlayerScreenHeight(pn) - 24))
    panel.player, panel.object, panel.scanDue = player, object, 0
    panel.backgroundColor = {r = .04, g = .04, b = .04, a = .97}
    panel:initialise()
    panel.moveWithMouse = true
    panel.devices = ISScrollingListBox:new(12, 76, 236, 400)
    panel.devices:initialise()
    panel.devices.itemheight = 30
    panel.devices.selectionColor = Theme.hover
    panel:addChild(panel.devices)
    panel.nameEntry = require("OMHTT/ControlNameEntry").create(panel, nil, 274, 90, 366, 28)
    panel.manage = button(panel, 274, 246, 246, getText("UI_OMHTT_OpenManage"), function(self)
        local requested = U.remote(self.player, self.object, self.selected)
        if A.near(self.player, self.selected) or requested then
            local host = A.state(self.object)
            require("OMHTT/TurretManage")(self.selected, self.player, host.kind == "Controller" and self.object or nil)
        end
    end)
    panel.assign = button(panel, 532, 246, 258, getText("UI_OMHTT_Assign"), function(self)
        local state = A.state(self.selected)
        if state then
            U.command(self.player, self.object, "Assign", state.controller ~= A.state(self.object).id, self.selected)
        end
        self.scanDue = 0
    end)
    panel.setFacing = button(panel, 274, 282, 246, getText("UI_OMHTT_SetFacing"), function(self)
        require("OMHTT/TurretFacingCursor").start(self)
    end)
    panel.source = button(panel, 274, 292, 166, getText("UI_OMHTT_SelectInput"), function(self)
        self.linkSource = self.selected
        U.remote(self.player, self.object, self.linkSource)
    end)
    panel.link = button(panel, 450, 292, 166, getText("UI_OMHTT_ConnectInput"), function(self)
        if self.linkSource and self.selected then
            U.remote(self.player, self.object, self.linkSource)
            local linked = C.linked(A.state(self.linkSource), A.state(self.selected))
            U.command(self.player, self.linkSource, "Link", not linked, self.selected)
        end
    end)
    panel.policy = button(panel, 274, 386, 246, "Private / Faction / Public", function(self)
        local state = A.state(self.selected)
        if state then
            local modes = {Private = "Faction", Faction = "Public", Public = "Private"}
            local mode = modes[state.access]
            if mode == "Faction" and not Faction.getPlayerFaction(self.player) then
                mode = "Public"
            end
            U.command(self.player, self.selected, "Access", mode)
        end
    end)
    local stock = button(panel, 532, 386, 258, getText("UI_OMHTT_OpenStockpile"), function(self) self:showStockpile(not self.stockPage) end)
    panel.stockButton = stock
    stock:setEnable(A.state(object).kind == "Controller")
    panel.clearInputs = button(panel, 274, 430, 246, getText("UI_OMHTT_ClearInputs"), function(self)
        if self.selected then
            U.command(self.player, self.selected, "ClearInputs")
        end
    end)
    panel.trigger = button(panel, 532, 430, 258, "Trigger: Both", function(self)
        local state = A.state(self.selected)
        if not state then return end
        local modes = {Both = "Players", Players = "Zombies", Zombies = "Both"}
        U.command(self.player, self.selected, "Trigger", modes[state.trigger or "Both"])
    end)
    panel.closeButton = button(panel, panel.width - 40, 6, 28, "X", Panel.close)
    require("OMHTT/ControlPanelLayout").create(panel)
    if A.state(object).kind == "Controller" then
        local top = panel.equipmentY + panel.lineHeight + 12
        panel.batterySlot = require("OMHTT/ControlBatterySlot").create(panel, 22, top,
            math.floor(panel.controlWidth / 2) - 30, panel.lineHeight * 2 + 20)
        panel.stockWing = require("OMHTT/ControlStockpilePane").create(panel,
            panel.stockCompact and 12 or panel.controlWidth + 8,
            panel.titleHeight + 10, panel.stockCompact and panel.width - 24 or panel.width - panel.controlWidth - 20,
            panel.height - panel.titleHeight - (panel.stockCompact and 58 or 24))
        panel.stockWing:setVisible(not panel.stockCompact)
    end
    panel.devices:addItem(U.name(object), object)
    panel.devices.selected = 1
    panel:scan()
    if A.state(object).kind == "Controller" then
        panel.marker = getWorldMarkers():addGridSquareMarker(object:getSquare(), Theme.accent.r, Theme.accent.g, Theme.accent.b, false, 40)
        panel.marker:setScaleCircleTexture(true)
    end
    panel:addToUIManager()
    active[player:getPlayerNum()] = panel
    require("OMHTT/ControlOverlay").panels[panel] = true
    return panel
end

---@param visible boolean? Show compact stockpile page
---@return nil
function Panel:showStockpile(visible)
    if not self.stockWing then return end
    self:bringToTop()
    if not self.stockCompact then return end
    self.stockPage = visible ~= false
    self.stockWing:setVisible(self.stockPage)
    self.detailBody:setVisible(not self.stockPage)
    self.devices:setVisible(not self.stockPage)
    self.batterySlot:setVisible(not self.stockPage)
    self.stockButton:setTitle(getText(self.stockPage and "UI_OMHTT_StockpileBack" or "UI_OMHTT_OpenStockpile"))
    self.stockButton:setY(self.stockPage and self.height - 42 or self.stockButtonY)
    self.stockButton:setX(self.stockPage and 12 or self.controlWidth / 2 + 10)
    self.stockButton:setWidth(self.stockPage and self.width - 24 or self.controlWidth / 2 - 34)
    if not self.stockPage then
        self.stockWing.inventoryPane:cleanup()
    end
end

---@param player IsoPlayer Operator
---@param object IsoObject Controller
---@return ISPanel? panel
function Panel.show(player, object)
    local panel = active[player:getPlayerNum()]
    if panel and panel.object == object then
        panel:bringToTop()
        return panel
    end
    return Panel.open(player, object)
end

return Panel
