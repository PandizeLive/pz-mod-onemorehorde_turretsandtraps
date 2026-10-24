if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISScrollingListBox")
require("ISUI/ISTextEntryBox")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local Panel = ISPanel:derive("OMHTTControllerPanel")
local Drag = require("OMHTT/ControlWindowDrag")
local Theme = require("OMHTT/ControlTheme")
Panel.onMouseDown = Drag.start
Panel.onMouseUp = Drag.stop
Panel.onMouseUpOutside = Drag.stop
Panel.update = Drag.update
local active = {}
local Discovery = require("OMHTT/ControlDiscovery")

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
        Discovery.add(self.object)
        self.scanIndex, self.scanObjectIndex, self.scanResults, self.scanSelection = 0, 0, {}, {}
        self.scanRadius = A.radius(self.object)
        self.checking = {}
        self.scanResults[1] = {text = U.name(self.object), item = self.object, itemindex = 1, height = self.devices.itemheight}
        self.scanSelection[self.object] = 1
        if self.marker and self.markerRadius ~= self.scanRadius then
            self.marker:remove()
            self.marker = getWorldMarkers():addGridSquareMarker(self.object:getSquare(), Theme.accent.r, Theme.accent.g, Theme.accent.b, false, self.scanRadius)
            self.marker:setScaleCircleTexture(true)
            self.markerRadius = self.scanRadius
        end
        self.cacheIndex = 1
        self.devices.items, self.devices.count = self.scanResults, #self.scanResults
        self.devices.itemheightoverride = {}
        self.devices.selected = self.scanSelection[self.selected] or 0
    end
    if self.cacheIndex then
        local deadline = getTimestampMs() + 2
        for step = 1, 64 do
            if self.cacheIndex > Discovery.listSize then
                self.cacheIndex = nil
                break
            end
            local object = Discovery.list[self.cacheIndex]
            if not object then
                Discovery.drop(self.cacheIndex)
            else
                self.cacheIndex = self.cacheIndex + 1
                local state = A.state(object)
                local within = object:getObjectIndex() >= 0 and A.range(self.object, object)
                local assigned = state and state.controller == A.state(self.object).id
                if object ~= self.object and not self.scanSelection[object] and object:getObjectIndex() >= 0 and (within or assigned) then
                    local row = #self.scanResults + 1
                    self.scanResults[row] = {text = U.name(object), item = object, itemindex = row, height = self.devices.itemheight}
                    self.scanSelection[object], self.checking[object] = row, within or nil
                end
            end
            if getTimestampMs() >= deadline then break end
        end
        self.devices.count = #self.scanResults
        self.devices.selected = self.scanSelection[self.selected] or self.devices.selected
        return
    end
    local radius = self.scanRadius
    local diameter = radius * 2 + 1
    local square, deadline = self.object:getSquare(), getTimestampMs() + 2
    if not square then return end
    for step = 1, 64 do
        local index = self.scanIndex
        if index >= diameter * diameter then
            for i = #self.scanResults, 1, -1 do
                if self.checking[self.scanResults[i].item] then table.remove(self.scanResults, i) end
            end
            self.checking = {}
            self.devices.items, self.devices.count = self.scanResults, #self.scanResults
            self.devices.itemheightoverride = {}
            self.devices.selected = 1
            for i = 1, #self.scanResults do
                self.scanResults[i].itemindex = i
                if self.scanResults[i].item == self.selected then self.devices.selected = i end
            end
            self.devices:setScrollHeight(#self.scanResults * self.devices.itemheight)
            self.scanIndex, self.scanResults, self.scanSelection, self.scanObjectIndex = nil, nil, nil, nil
            self.scanDue = getTimestampMs() + 5000
            return
        end
        local dx, dy = math.floor(index / diameter) - radius, index % diameter - radius
        local objects
        if dx * dx + dy * dy <= radius * radius then
            local tile = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
            objects = tile and tile:getObjects()
        end
        if objects and self.scanObjectIndex < objects:size() then
            local object = objects:get(self.scanObjectIndex)
            self.scanObjectIndex = self.scanObjectIndex + 1
            if object:getObjectIndex() >= 0 and A.state(object) then
                self.checking[object] = nil
                Discovery.add(object)
            end
            if object:getObjectIndex() >= 0 and A.state(object) and not self.scanSelection[object] then
                local row = #self.scanResults + 1
                self.scanResults[row] = {text = U.name(object), item = object, itemindex = row, height = self.devices.itemheight}
                self.scanSelection[object] = row
                if object == self.selected then
                    self.devices.selected = row
                end
                self.devices.count = #self.scanResults
            end
        else
            self.scanIndex, self.scanObjectIndex = index + 1, 0
        end
        if getTimestampMs() >= deadline then return end
    end
end

---@return nil
function Panel:select()
    if self.scanIndex and self.devices.selected == 0 then
        return
    end
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
    require("OMHTT/WindowGeometry").close(self)
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
    if self.expansionSlot then
        self.expansionSlot:cleanup()
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
    if not A.state(self.object) or self.object:getObjectIndex() < 0 or (not A.near(self.player, self.object)) then
        self:close(); return
    end
    ISPanel.prerender(self)
    require("OMHTT/ControlPanelLayout").arrange(self)
    local now = getTimestampMs()
    if self.scanIndex or now >= self.scanDue then
        self:scan()
    end
    self:select()
    require("OMHTT/ControlGraph").refreshForPanel(self)
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
    require("OMHTT/ControlPanelLayout").draw(self, host, state)
    local writable = state and A.authorized(self.player, self.selected)
    self.nameEntry:refresh()
    self.nameEntry:setVisible(state ~= nil and state.kind ~= "Controller")
    require("OMHTT/ControlTargetingUI").refresh(self.targeting, self.player, self.selected)
    self.policy:setEnable(writable and A.write(self.player, state, true) or false)
    self.manage:setEnable(state ~= nil and require("OMHTT/ControlDefinitions").defense(state.kind)
        and (A.near(self.player, self.selected) or (host.powered == true and state.controller == host.id)))
    self.assign:setEnable(state ~= nil and self.selected ~= self.object and host.kind == "Controller"
        and (state.controller == host.id or (host.powered == true and A.range(self.object, self.selected)))
        and A.write(self.player, host) and A.write(self.player, state))

    local input = state and require("OMHTT/ControlDefinitions").inputs[state.kind]
    self.trigger:setEnable(writable == true and input == true)
    local caption = "UI_OMHTT_ControlPress"
    if state and state.kind == "Plate" then caption = "UI_OMHTT_TriggerMode"
    elseif state and state.kind == "Lever" then caption = state.latched and "UI_OMHTT_LeverOff" or "UI_OMHTT_LeverOn"
    elseif state and state.kind == "Laser" then caption = "UI_OMHTT_BeamRange" end
    self.trigger:setTitle(getText(caption, state and (state.kind == "Laser" and A.laserRange() or (state.trigger or "Both"))))
    self.trigger:setVisible(input == true and state.kind ~= "Laser")
    self.manage:setVisible(state ~= nil and require("OMHTT/ControlDefinitions").defense(state.kind))
    self.assign:setVisible(state ~= nil and self.selected ~= self.object and host.kind == "Controller")

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
    if state and state.kind == "Laser" then self.trigger:setEnable(false) end
    self.trigger.tooltip = input and require("OMHTT/ControlConsumption").description(state.kind, true) or remoteReason
    if input and state.powered ~= true then self.trigger.tooltip = self.trigger.tooltip .. " <LINE> " .. getText("UI_OMHTT_TriggerUnpowered") end

    self.policy:setVisible(state ~= nil and self.selected ~= self.object)
    if self.selected == self.object then
        self.targeting:setVisible(false)
    end
    self.policy:setTitle(getText("UI_OMHTT_Access", state and state.access or "-"))
    self.assign:setTitle(getText(state and state.controller == host.id and "UI_OMHTT_Unassign" or "UI_OMHTT_Assign"))
    if not A.near(self.player, self.object) then
        self.manage:setEnable(false)
        self.assign:setEnable(false)
        self.targeting:setEnable(false)
        self.policy:setEnable(false)
        self.trigger:setEnable(false)
    end

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
        math.min(A.state(object).kind == "Controller" and 1220 or 860, getPlayerScreenWidth(pn) - 24), math.min(1000, getPlayerScreenHeight(pn) - 24))
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
            if A.state(self.selected).kind == "Tether" then
                require("OMHTT/ControlTetherMenu").open(self.player, self.selected)
            elseif A.state(self.selected).kind == "Poke" then
                require("OMHTT/ControlPokeMenu").open(self.player, self.selected)
            else
                require("OMHTT/TurretManage")(self.selected, self.player, host.kind == "Controller" and self.object or nil)
            end
        end
    end)
    panel.assign = button(panel, 532, 246, 258, getText("UI_OMHTT_Assign"), function(self)
        local state = A.state(self.selected)
        if state then
            U.command(self.player, self.object, "Assign", state.controller ~= A.state(self.object).id, self.selected)
        end
        self.scanDue = 0
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
    panel.trigger = button(panel, 532, 430, 258, "Trigger: Both", function(self)
        local state = A.state(self.selected)
        if not state then return end
        require("OMHTT/ControlTriggerUI").activate(self.player, self.selected)
    end)
    panel.targeting = button(panel, 274, 300, 246, "", function(self)
        require("OMHTT/ControlTargetingUI").open(self.player, self.selected)
    end)
    panel.closeButton = button(panel, panel.width - 40, 6, 28, "X", Panel.close)
    require("OMHTT/ControlPanelLayout").create(panel)
    if A.state(object).kind == "Controller" then
        local top = panel.equipmentY + panel.lineHeight + 12
        panel.batterySlot = require("OMHTT/ControlBatterySlot").create(panel, 22, top,
            math.floor(panel.controlWidth / 2) - 30, panel.lineHeight * 2 + 20)
        panel.expansionSlot = require("OMHTT/ControlExpansionSlot").create(panel)
        panel.stockWing = require("OMHTT/ControlStockpilePane").create(panel,
            panel.stockCompact and 12 or panel.controlWidth + 8,
            panel.titleHeight + 10, panel.stockCompact and panel.width - 24 or panel.width - panel.controlWidth - 20,
            panel.height - panel.titleHeight - (panel.stockCompact and 58 or 24))
        panel.stockWing:setVisible(not panel.stockCompact)
    end
    panel.devices:addItem(U.name(object), object)
    panel.devices.selected = 1
    panel:scan()
    panel.geometryWidth = nil
    require("OMHTT/ControlPanelLayout").arrange(panel)
    require("OMHTT/WindowGeometry").install(panel, "Controller", math.max(840, panel.lineHeight * 42), 620,
        require("OMHTT/ControlPanelLayout").arrange)
    if A.state(object).kind == "Controller" then
        panel.marker = getWorldMarkers():addGridSquareMarker(object:getSquare(), Theme.accent.r, Theme.accent.g, Theme.accent.b, false, A.radius(object))
        panel.marker:setScaleCircleTexture(true)
        panel.markerRadius = A.radius(object)
    end
    require("OMHTT/ControlWindowChrome").install(panel)
    panel:addToUIManager()
    active[player:getPlayerNum()] = panel
    require("OMHTT/ControlOverlay").panels[panel] = true
    return panel
end

---@param visible boolean? Show compact stockpile page
---@return nil
function Panel:showStockpile(visible)
    if not self.stockWing then return end
    if not self.stockCompact then return end
    self.stockPage = visible ~= false
    self.stockWing:setVisible(self.stockPage)
    self.detailBody:setVisible(not self.stockPage)
    self.devices:setVisible(false)
    self.graph:setVisible(not self.stockPage)
    self.mapView:setVisible(not self.stockPage)
    self.hostBody:setVisible(not self.stockPage)
    self.batterySlot:setVisible(not self.stockPage)
    if self.expansionSlot then self.expansionSlot:setVisible(not self.stockPage) end
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
