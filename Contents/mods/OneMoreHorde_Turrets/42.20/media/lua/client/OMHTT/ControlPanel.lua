if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISScrollingListBox")
require("ISUI/ISTextEntryBox")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local Panel = ISPanel:derive("OMHTTControllerPanel")
local Drag = require("OMHTT/ControlWindowDrag")
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
    panel:addChild(result)
    return result
end

---@return nil
function Panel:scan()
    if not self.scanIndex then
        self.scanIndex, self.scanResults = 0, {}
    end
    local square, deadline = self.object:getSquare(), getTimestampMs() + 2
    for step = 1, 64 do
        local index = self.scanIndex
        if index >= 1681 then
            self.devices:clear()
            local host = A.state(self.object)
            for i = 1, #self.scanResults do
                local object = self.scanResults[i]
                local state = A.state(object)
                if state then
                    self.devices:addItem(U.name(object), object)
                    if object == self.selected then
                        self.devices.selected = #self.devices.items
                    end
                end
            end
            self.scanIndex, self.scanResults = nil, nil
            self.scanDue = getTimestampMs() + 5000
            return
        end
        local dx, dy = math.floor(index / 41) - 20, index % 41 - 20
        self.scanIndex = index + 1
        if dx * dx + dy * dy <= 400 then
            local tile = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
            local objects = tile and tile:getObjects()
            if objects then
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    if A.state(object) then
                        self.scanResults[#self.scanResults + 1] = object
                    end
                end
            end
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
    self.nameEntry:setText(object and U.name(object) or "")
    if object and object ~= self.object then
        U.remote(self.player, self.object, object)
    end
end

---@return nil
function Panel:close()
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
    if now >= (self.renewDue or 0) then
        self.renewDue = now + 5000
        if state and self.selected ~= self.object then
            U.remote(self.player, self.object, self.selected)
        end
        require("OMHTT/ControlPanelLayout").snapshot(self)
    end
    require("OMHTT/ControlPanelLayout").refresh(self, state)
    require("OMHTT/ControlPanelLayout").draw(self, host, state)
    local writable = state and A.authorized(self.player, self.selected)
    local linkable = state and A.write(self.player, state) and self.linkSource
        and A.authorized(self.player, self.linkSource) and A.range(self.linkSource, self.selected)
    self.save:setEnable(writable == true)
    self.policy:setEnable(writable and A.write(self.player, state, true) or false)
    self.manage:setEnable(state ~= nil and state.kind == "Turret" and host.powered == true and state.controller == host.id)
    self.assign:setEnable(state ~= nil and self.selected ~= self.object and host.kind == "Controller"
        and host.powered == true and A.write(self.player, host) and A.write(self.player, state))
    self.link:setEnable(linkable == true)
    self.unlink:setEnable(linkable == true)
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
    self.unlink:setVisible(state ~= nil and state.kind == "Turret" and self.linkSource ~= nil)
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
    if not A.near(player, object) then return nil end
    local old = active[player:getPlayerNum()]
    if old then old:close() end
    local pn = player:getPlayerNum()
    local panel = Panel:new(getPlayerScreenLeft(pn) + 12, getPlayerScreenTop(pn) + 12,
        math.min(860, getPlayerScreenWidth(pn) - 24), math.min(680, getPlayerScreenHeight(pn) - 24))
    panel.player, panel.object, panel.scanDue = player, object, 0
    panel.backgroundColor = {r = .04, g = .04, b = .04, a = .97}
    panel:initialise()
    panel.moveWithMouse = true
    panel.devices = ISScrollingListBox:new(12, 76, 236, 400)
    panel.devices:initialise()
    panel.devices.itemheight = 30
    panel:addChild(panel.devices)
    panel.nameEntry = ISTextEntryBox:new("", 274, 90, 366, 28)
    panel.nameEntry:initialise()
    panel:addChild(panel.nameEntry)
    panel.save = button(panel, 650, 90, 140, "Save name", function(self)
        if self.selected then
            U.command(self.player, self.selected, "Name", self.nameEntry:getText())
        end
    end)
    panel.manage = button(panel, 274, 246, 246, "Open full Manage", function(self)
        if U.remote(self.player, self.object, self.selected) then
            require("OMHTT/TurretManage")(self.selected, self.player, self.object)
        end
    end)
    panel.assign = button(panel, 532, 246, 258, "Assign / unassign", function(self)
        local state = A.state(self.selected)
        if state then
            U.command(self.player, self.object, "Assign", state.controller ~= A.state(self.object).id, self.selected)
        end
        self.scanDue = 0
    end)
    panel.source = button(panel, 274, 292, 166, "Use as input", function(self) self.linkSource = self.selected end)
    panel.link = button(panel, 450, 292, 166, "Link selected", function(self)
        if self.linkSource and self.selected then
            U.remote(self.player, self.object, self.linkSource)
            U.command(self.player, self.linkSource, "Link", true, self.selected)
        end
    end)
    panel.unlink = button(panel, 626, 292, 164, "Unlink selected", function(self)
        if self.linkSource and self.selected then
            U.remote(self.player, self.object, self.linkSource)
            U.command(self.player, self.linkSource, "Link", false, self.selected)
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
    local stock = button(panel, 532, 386, 258, getText("UI_OMHTT_OpenStockpile"), function(self) self:stockpile() end)
    panel.stockButton = stock
    stock:setEnable(A.state(object).kind == "Controller")
    panel.clearInputs = button(panel, 274, 430, 246, "Clear input links", function(self)
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
    panel.devices:addItem(U.name(object), object)
    panel.devices.selected = 1
    panel:scan()
    if A.state(object).kind == "Controller" then
        panel.marker = getWorldMarkers():addGridSquareMarker(object:getSquare(), .4, .75, 1, false, 40)
        panel.marker:setScaleCircleTexture(true)
    end
    panel:addToUIManager()
    active[player:getPlayerNum()] = panel
    require("OMHTT/ControlOverlay").panels[panel] = true
    return panel
end

return Panel
