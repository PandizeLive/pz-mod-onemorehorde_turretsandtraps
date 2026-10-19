if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISContextMenu")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local C = require("OMHTT/ControlDefinitions")
local Groups = require("OMHTT/ControlGroupUI")
local Theme = require("OMHTT/ControlTheme")
local Graph = ISPanel:derive("OMHTTControlGraph")
local conditionColor = {r = .45, g = .7, b = .45, a = 1}

---@param panel ISPanel Controller
---@param object IsoObject Selected device
---@return nil
function Graph.select(panel, object)
    for i = 1, #panel.devices.items do
        if panel.devices.items[i].item == object then
            panel.devices.selected = i
            panel:select()
            if panel.mapView then
                panel.mapView:focus(object)
            end
            return
        end
    end
end

---@param panel ISPanel Controller
---@return nil
function Graph.focus(panel)
    local graph, state = panel.graph, A.state(panel.selected)
    local index = state and graph.positions[state.id]
    if not index then return end
    local rows = state.kind == "Turret" and graph.defenses or graph.triggers
    local y = rows[index].y
    graph:setYScroll(math.max(math.min(0, graph.height - graph:getScrollHeight()), math.min(0, -y)))
end

---@param panel ISPanel Controller
---@param source IsoObject Input
---@param target IsoObject Receiver
---@param enabled boolean? Add unless false
---@return boolean? queued
function Graph.connect(panel, source, target, enabled)
    if panel.pendingGraphLink then return end
    local input, output = A.state(source), A.state(target)
    if not input or not output or output.kind ~= "Turret" or (input.kind ~= "Plate" and input.kind ~= "Button") then return end
    enabled = enabled ~= false
    panel.linkSource = nil
    getSoundManager():playUISound("UIActivateButton")
    Graph.select(panel, target)
    if C.linked(input, output) == enabled then return true end
    if not A.write(panel.player, input) or not A.write(panel.player, output) or not A.range(source, target) then return end
    U.remote(panel.player, panel.object, source)
    U.remote(panel.player, panel.object, target)
    panel.graph.notice = "UI_OMHTT_ChangePending"
    panel.pendingGraphLink = {source = source, target = target, enabled = enabled, expires = getTimestampMs() + 5000}
    return true
end

---@param panel ISPanel Controller
---@param source IsoObject Input
---@param target IsoObject Receiver
---@return boolean? queued
function Graph.disconnect(panel, source, target)
    return Graph.connect(panel, source, target, false)
end

---@param panel ISPanel Controller
---@param target IsoObject Receiver
---@return nil
function Graph.outputPort(panel, target)
    if panel.linkSource then
        Graph.connect(panel, panel.linkSource, target)
        return
    end
    Graph.menu(panel, target, true)
end

---@param panel ISPanel Controller
---@param object IsoObject Clicked device
---@param direct boolean? Remove a sole connection directly
---@return nil
function Graph.menu(panel, object, direct)
    local state, links = A.state(object), {}
    if not state then return end
    for i = 1, #panel.graph.edges do
        local edge = panel.graph.edges[i]
        local source, target = panel.graph.triggers[edge.input].object, panel.graph.defenses[edge.output].object
        if source == object or target == object then
            links[#links + 1] = {source = source, target = target, other = source == object and target or source}
        end
    end
    if #links == 0 then return end
    if direct and #links == 1 then
        Graph.disconnect(panel, links[1].source, links[1].target)
        return
    end
    local menu = ISContextMenu.get(panel.player:getPlayerNum(), getMouseX(), getMouseY())
    menu:addOption(getText("UI_OMHTT_All"), panel, Graph.disconnectAll, links)
    for i = 1, #links do
        local link = links[i]
        menu:addOption(getText("UI_OMHTT_DisconnectNamed", U.name(link.other)), panel, Graph.disconnect, link.source, link.target)
    end
    menu:bringToTop()
end

---@param panel ISPanel Controller
---@param links table Selected device connections
---@return nil
function Graph.disconnectAll(panel, links)
    panel.disconnectQueue = links
    panel.disconnectFailures = 0
end

---@param panel ISPanel Controller
---@return nil
function Graph.refreshForPanel(panel)
    local groupPending, host = panel.groupPending, A.state(panel.object)
    if groupPending and host then
        if (host.organization and host.organization.revision or 0) ~= groupPending.revision then
            panel.groupPending = nil
            local applied = Groups.applied(groupPending, host.organization)
            panel.graph.notice = applied and "UI_OMHTT_ChangeApplied" or "UI_OMHTT_ChangeRejected"
            panel.graph.flashUntil = applied and getTimestampMs() + 450 or nil
            panel.graph.refreshDue = 0
        elseif getTimestampMs() > groupPending.expires then
            panel.groupPending = nil
            panel.graph.notice = "UI_OMHTT_ChangeRejected"
        end
    end
    if not panel.pendingGraphLink and panel.disconnectQueue and #panel.disconnectQueue > 0 then
        local link = table.remove(panel.disconnectQueue, 1)
        if not Graph.disconnect(panel, link.source, link.target) then
            panel.disconnectFailures = (panel.disconnectFailures or 0) + 1
        end
    end
    local pending = panel.pendingGraphLink
    if pending then
        local source, target = A.state(pending.source), A.state(pending.target)
        if source and target and C.linked(source, target) == pending.enabled then
            panel.graph.flashUntil = getTimestampMs() + 450
            panel.graph.notice = "UI_OMHTT_ChangeApplied"
            panel.pendingGraphLink = nil
        elseif getTimestampMs() > pending.expires or not source or not target then
            panel.pendingGraphLink = nil
            panel.disconnectFailures = (panel.disconnectFailures or 0) + 1
            panel.graph.notice = "UI_OMHTT_ChangeRejected"
        elseif not pending.sent and A.authorized(panel.player, pending.source) and A.authorized(panel.player, pending.target) then
            pending.sent = true
            U.command(panel.player, pending.source, "Link", pending.enabled, pending.target)
            panel.graph.refreshDue = 0
        end
    end
    if panel.disconnectQueue and #panel.disconnectQueue == 0 and not panel.pendingGraphLink then
        if (panel.disconnectFailures or 0) > 0 then
            panel.graph.notice = "UI_OMHTT_ChangesPartial"
        end
        panel.disconnectQueue = nil
    end
    local graph = panel.graph
    require("OMHTT/ControlGraphStats").step(graph)
    if getTimestampMs() < graph.refreshDue and graph.items == panel.devices.items and graph.textWidth == graph.width then return end
    graph.items, graph.refreshDue = panel.devices.items, getTimestampMs() + 500
    graph.textWidth = graph.width
    graph.triggers, graph.defenses, graph.positions, graph.edges, graph.markers = {}, {}, {}, {}, {}
    graph.markerByObject = {}
    graph.rowHeight = panel.lineHeight * 3 + 26
    for i = 1, #graph.items do
        local object = graph.items[i].item
        local state = A.state(object)
        if state then
            local prefix = state.kind == "Turret" and "T" or (state.kind == "Controller" and "C" or (state.kind == "Button" and "B" or "P"))
            local label = prefix .. (state.number or "")
            graph.markers[#graph.markers + 1] = {object = object, label = label,
                halfWidth = math.max(11, math.ceil(getTextManager():MeasureStringX(UIFont.Small, label) / 2) + 4)}
            graph.markerByObject[object] = graph.markers[#graph.markers]
        end
        if state and (state.kind == "Turret" or state.kind == "Plate" or state.kind == "Button") then
            local rows = state.kind == "Turret" and graph.defenses or graph.triggers
            local row = {object = object, state = state, title = U.name(object)}
            if state.kind == "Turret" then
                row.subtitle = state.headType and state.headType ~= "Base" and getItemNameFromFullType(state.headType) or getText("UI_OMHTT_TurretBase")
            end
            local width = (graph.width - 88) / 2 - 29
            row.lines = string.split(getTextManager():WrapText(UIFont.Small, row.title, width), "\n")
            row.detail = row.subtitle and string.split(getTextManager():WrapText(UIFont.Small, row.subtitle, width), "\n") or {}
            graph.rowHeight = math.max(graph.rowHeight, (#row.lines + #row.detail + 1) * panel.lineHeight + 26)
            rows[#rows + 1] = row
            graph.positions[state.id] = #rows
        end
    end
    Groups.layout(graph)
    for i = 1, #graph.triggers do
        local row = graph.triggers[i]
        for j = 1, #row.state.links do
            local index = graph.positions[row.state.links[j]]
            if index then
                graph.edges[#graph.edges + 1] = {input = i, output = index}
                graph.defenses[index].connected = true
            end
        end
    end
    graph:setScrollHeight(graph.contentHeight)
    graph:setYScroll(math.max(math.min(0, graph.height - graph:getScrollHeight()), graph:getYScroll()))
end

---@param delta number Wheel delta
---@return boolean handled
function Graph:onMouseWheel(delta)
    self:setYScroll(math.max(math.min(0, self.height - self:getScrollHeight()), math.min(0, self:getYScroll() - delta * self.rowHeight)))
    return true
end

---@param x number Local X
---@param y number Local Y
---@return table? row
---@return boolean port
function Graph:hit(x, y)
    if x < 0 or x >= self.width - 12 or y < self.headerHeight or y >= self.height then return nil, false end
    local half = (self.width - 88) / 2
    local rows, port
    if x >= 4 and x < half then
        rows, port = self.triggers, x >= half - 26
    elseif x >= half + 74 and x < self.width - 18 then
        rows, port = self.defenses, x < half + 98
    else
        return nil, false
    end
    for i = 1, #rows do
        local row = rows[i]
        local top = row.y + self:getYScroll()
        if not row.collapsed and y >= top and y < top + self.rowHeight then return row, port end
    end
    return nil, false
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Graph:onMouseDown(x, y)
    local row, port = self:hit(x, y)
    local group = Groups.at(self, y)
    self.downX, self.downY = x, y
    if not row then
        if group and y >= self.headerHeight then
            self.dragGroup = group
            self:setCapture(true)
        end
        return true
    end
    Graph.select(self.owner, row.object)
    getSoundManager():playUISound("UIActivateButton")
    if port then
        if row.state.kind == "Turret" then
            Graph.outputPort(self.owner, row.object)
        else
            self.owner.linkSource = self.owner.linkSource ~= row.object and row.object or nil
        end
    else
        self.dragSource = row.object
        self:setCapture(true)
    end
    return true
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Graph:onMouseUp(x, y)
    local row = self:hit(x, y)
    local group = Groups.at(self, y)
    local moved = self.downX and math.abs(x - self.downX) + math.abs(y - self.downY) > 6
    if group and self.dragSource and moved and (not row or row.object ~= self.dragSource) then
        local state = A.state(self.dragSource)
        if not row or (state.kind == "Turret") == (row.state.kind == "Turret") then
            Groups.request(self.owner, "DeviceMove", group.id, row and row.state.id, nil, self.dragSource)
        end
    elseif self.dragGroup and group then
        if moved and self.dragGroup.id ~= "" then
            Groups.request(self.owner, "GroupMove", self.dragGroup.id, group.id)
        else
            self.collapsed[group.id] = not self.collapsed[group.id]
            self.refreshDue = 0
        end
    end
    self.dragSource, self.dragGroup = nil, nil
    self:setCapture(false)
    return true
end

---@return boolean handled
function Graph:onMouseUpOutside()
    self.dragSource, self.dragGroup = nil, nil
    self:setCapture(false)
    return true
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Graph:onRightMouseUp(x, y)
    local row = self:hit(x, y)
    if row then
        Graph.menu(self.owner, row.object)
    else
        local group = Groups.at(self, y)
        if group and group.id ~= "" then
            local menu = ISContextMenu.get(self.owner.player:getPlayerNum(), getMouseX(), getMouseY())
            menu:addOption(getText("UI_OMHTT_GroupRename"), self.owner, Groups.rename, group)
            menu:addOption(getText("UI_OMHTT_GroupDelete"), self.owner, Groups.remove, group)
            menu:bringToTop()
        end
    end
    return true
end

---@return nil
function Graph:prerender()
    local header, rowHeight = self.headerHeight, self.rowHeight
    self.addGroup:setX(self.width - self.addGroup.width - 18)
    self.addGroup:setY(self.owner.lineHeight + 12 - self:getYScroll())
    self.addGroup:setEnable(A.authorized(self.owner.player, self.owner.object))
    self:setStencilRect(0, header, self.width - 12, math.max(0, self.height - header))
    self:drawRectStatic(0, header, self.width, self.height - header, 1, .055, .055, .055)
    local half = (self.width - 88) / 2
    local mouseY, now = self:getMouseY(), getTimestampMs()
    if (self.dragSource or self.dragGroup) and now >= (self.scrollAt or 0) then
        if mouseY < header + 20 then
            self:onMouseWheel(-.2)
        elseif mouseY > self.height - 20 then
            self:onMouseWheel(.2)
        end
        self.scrollAt = now + 60
    end
    local hovered = self:hit(self:getMouseX(), self:getMouseY())
    for side = 1, 2 do
        local rows = side == 1 and self.triggers or self.defenses
        local x = side == 1 and 4 or half + 74
        local first = 1
        local last = #rows
        for i = first, last do
            local row, y = rows[i], rows[i].y
            if not row.collapsed and y + self:getYScroll() + rowHeight > header and y + self:getYScroll() < self.height then
                local selected = row.object == self.owner.selected or row == hovered
                self:drawRect(x, y + 3, half - 4, rowHeight - 6, 1, selected and .11 or .025, selected and .11 or .025, selected and .11 or .025)
                self:drawRectBorder(x, y + 3, half - 4, rowHeight - 6, 1, selected and .65 or .25, selected and .65 or .25, selected and .65 or .25)
                if row == hovered and self.dragSource then
                    local moving = A.state(self.dragSource)
                    local valid = moving and (moving.kind == "Turret") == (row.state.kind == "Turret")
                    self:drawRectBorder(x, y + 3, half - 4, rowHeight - 6, 1, valid and .4 or 1, valid and .9 or .3, .3)
                end
                local textX = side == 1 and x + 5 or x + 27
                local textY = y + 6
                for line = 1, #row.lines do
                    self:drawText(row.lines[line], textX, textY, .95, .95, .95, 1, UIFont.Small)
                    textY = textY + self.owner.lineHeight
                end
                for line = 1, #row.detail do
                    self:drawText(row.detail[line], textX, textY, .7, .7, .7, 1, UIFont.Small)
                    textY = textY + self.owner.lineHeight
                end
                local portX, portY = side == 1 and half - 23 or x + 2, y + rowHeight / 2 - 10
                local armed = self.owner.linkSource == row.object
                self:drawRect(portX, portY, 20, 20, 1, armed and .2 or .08, armed and .4 or .08, armed and .2 or .08)
                self:drawRectBorder(portX, portY, 20, 20, 1, .65, .65, .65)
                self:drawTextCentre(side == 1 and ">" or (row.connected and not self.owner.linkSource and "-" or "+"), portX + 10, portY + 1, .9, .9, .9, 1, UIFont.Small)
                if side == 2 then
                    local stats = self.stats[row.object]
                    local health, maximum = row.object:getHealth(), row.object:getMaxHealth()
                    local fraction = maximum > 0 and math.max(0, math.min(1, health / maximum)) or 0
                    local barWidth = half - 37
                    self:drawProgressBar(textX, y + rowHeight - 17, barWidth, 6, fraction, conditionColor)
                    self:drawText(stats and stats.label or getText("UI_OMHTT_GraphAmmoPending"), textX,
                        y + rowHeight - self.owner.lineHeight - 21, .75, .75, .75, 1, UIFont.Small)
                end
            end
        end
    end
    for i = 1, #self.groups do
        local group = self.groups[i]
        self:drawRect(4, group.y, self.width - 22, group.header - 2, 1, .13, .13, .13)
        self:drawText((self.collapsed[group.id] and "> " or "v ") .. group.name, 9, group.y + 3, .9, .9, .9, 1, UIFont.Small)
    end
    for i = 1, #self.edges do
        local edge = self.edges[i]
        local y1 = self.triggers[edge.input].y + (self.triggers[edge.input].collapsed and 12 or rowHeight / 2)
        local y2 = self.defenses[edge.output].y + (self.defenses[edge.output].collapsed and 12 or rowHeight / 2)
        local source, target = self.triggers[edge.input], self.defenses[edge.output]
        local selected = source.object == self.owner.selected or target.object == self.owner.selected
        local state = A.state(source.object)
        local active = state and state.active == true
        local scroll = self:getYScroll()
        if math.max(y1, y2) + scroll >= header and math.min(y1, y2) + scroll < self.height then
            self:drawLine(nil, half - 3, y1, half + 76, y2, selected and 2 or 1, selected and 1 or .65,
                active and .4 or .75, active and .9 or .75, active and .4 or .75)
        end
    end
    if self.dragSource or self.dragGroup then
        local label = self.dragSource and U.name(self.dragSource) or self.dragGroup.name
        local x, y = self:getMouseX(), self:getMouseY() - self:getYScroll()
        self:drawRect(x, y, math.max(0, math.min(150, self.width - x - 14)), 26, .95, .23, .23, .23)
        self:drawText(label, x + 4, y + 4, 1, 1, 1, 1, UIFont.Small)
    end
    self:clearStencilRect()
    local scroll = self:getYScroll()
    Theme.section(self, 0, -scroll, self.width, header, header, getText("UI_OMHTT_Connections"))
    if self.flashUntil and getTimestampMs() < self.flashUntil then
        self:drawRectBorder(1, -scroll, self.width - 16, self.height, .9, .7, .95, .7)
    end
    self:drawText(getText("UI_OMHTT_Triggers"), 8, header - self.owner.lineHeight - 4 - scroll, .75, .75, .75, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_Defenses"), half + 78, header - self.owner.lineHeight - 4 - scroll, .75, .75, .75, 1, UIFont.Small)
end

---@param owner ISPanel Controller
---@return ISPanel graph
function Graph.create(owner)
    local graph = Graph:new(12, 180, 300, 400)
    graph.owner, graph.refreshDue = owner, 0
    graph.triggers, graph.defenses, graph.positions, graph.edges = {}, {}, {}, {}
    graph.groups, graph.collapsed = {}, {}
    graph.markers = {}
    graph.markerByObject = {}
    graph.stats = setmetatable({}, {__mode = "k"})
    graph.statsIndex, graph.statsDue = 1, 0
    graph.tooltip = getText("UI_OMHTT_GraphLinkHelp")
    graph.headerHeight, graph.rowHeight = owner.lineHeight * 3 + 32, owner.lineHeight * 3 + 12
    graph:initialise()
    graph:setScrollChildren(false)
    local caption = getText("UI_OMHTT_GroupAdd")
    graph.addGroup = ISButton:new(0, owner.lineHeight + 12, math.max(94, getTextManager():MeasureStringX(UIFont.Small, caption) + 20), math.max(28, owner.lineHeight + 8), caption, owner, function(panel)
        Groups.rename(panel)
    end)
    graph.addGroup:initialise()
    Theme.button(graph.addGroup)
    graph.addGroup.tooltip = getText("UI_OMHTT_GroupAddHelp")
    graph:addChild(graph.addGroup)
    graph:addScrollBars(false)
    Theme.scrollbar(graph)
    owner:addChild(graph)
    return graph
end

return Graph
