if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISContextMenu")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local C = require("OMHTT/ControlDefinitions")
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
    local y = (index - 1) * graph.rowHeight
    graph:setYScroll(math.max(math.min(0, graph.height - graph:getScrollHeight()), math.min(0, -y)))
end

---@param panel ISPanel Controller
---@param source IsoObject Input
---@param target IsoObject Receiver
---@param enabled boolean? Add unless false
---@return nil
function Graph.connect(panel, source, target, enabled)
    local input, output = A.state(source), A.state(target)
    if not input or not output or output.kind ~= "Turret" or (input.kind ~= "Plate" and input.kind ~= "Button") then return end
    enabled = enabled ~= false
    panel.linkSource = nil
    Graph.select(panel, target)
    if C.linked(input, output) == enabled then return end
    if not A.write(panel.player, input) or not A.write(panel.player, output) or not A.range(source, target) then return end
    U.remote(panel.player, panel.object, source)
    U.remote(panel.player, panel.object, target)
    panel.pendingGraphLink = {source = source, target = target, enabled = enabled, expires = getTimestampMs() + 5000}
end

---@param panel ISPanel Controller
---@param source IsoObject Input
---@param target IsoObject Receiver
---@return nil
function Graph.disconnect(panel, source, target)
    Graph.connect(panel, source, target, false)
end

---@param panel ISPanel Controller
---@param target IsoObject Receiver
---@return nil
function Graph.outputPort(panel, target)
    if panel.linkSource then
        Graph.connect(panel, panel.linkSource, target)
        return
    end
    local incoming = {}
    local state = A.state(target)
    for i = 1, #panel.graph.triggers do
        local source = panel.graph.triggers[i].object
        if C.linked(A.state(source), state) then
            incoming[#incoming + 1] = source
        end
    end
    if #incoming == 1 then
        Graph.disconnect(panel, incoming[1], target)
    elseif #incoming > 1 then
        local menu = ISContextMenu.get(panel.player:getPlayerNum(), getMouseX(), getMouseY())
        for i = 1, #incoming do
            menu:addOption(getText("UI_OMHTT_DisconnectNamed", U.name(incoming[i])), panel, Graph.disconnect, incoming[i], target)
        end
    end
end

---@param panel ISPanel Controller
---@return nil
function Graph.refreshForPanel(panel)
    local pending = panel.pendingGraphLink
    if pending then
        local source, target = A.state(pending.source), A.state(pending.target)
        if getTimestampMs() > pending.expires or not source or not target or C.linked(source, target) == pending.enabled then
            panel.pendingGraphLink = nil
        elseif A.authorized(panel.player, pending.source) and A.authorized(panel.player, pending.target) then
            panel.pendingGraphLink = nil
            U.command(panel.player, pending.source, "Link", pending.enabled, pending.target)
            panel.graph.refreshDue = 0
        end
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
            local width = (graph.width - 40) / 2 - 29
            row.lines = string.split(getTextManager():WrapText(UIFont.Small, row.title, width), "\n")
            row.detail = row.subtitle and string.split(getTextManager():WrapText(UIFont.Small, row.subtitle, width), "\n") or {}
            graph.rowHeight = math.max(graph.rowHeight, (#row.lines + #row.detail + 1) * panel.lineHeight + 26)
            rows[#rows + 1] = row
            graph.positions[state.id] = #rows
        end
    end
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
    graph:setScrollHeight(math.max(#graph.triggers, #graph.defenses) * graph.rowHeight + graph.headerHeight + 8)
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
    local index = math.floor((y - self:getYScroll() - self.headerHeight) / self.rowHeight) + 1
    local half = (self.width - 40) / 2
    local rows, port
    if x >= 4 and x < half then
        rows, port = self.triggers, x >= half - 26
    elseif x >= half + 26 and x < self.width - 18 then
        rows, port = self.defenses, x < half + 50
    else
        return nil, false
    end
    return rows[index], port
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Graph:onMouseDown(x, y)
    local row, port = self:hit(x, y)
    if not row then return true end
    Graph.select(self.owner, row.object)
    if row.state.kind ~= "Turret" then
        self.dragSource, self.downPort = row.object, port
        self:setCapture(true)
    elseif port then
        Graph.outputPort(self.owner, row.object)
    end
    return true
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Graph:onMouseUp(x, y)
    local row = self:hit(x, y)
    if self.dragSource and row and row.state.kind == "Turret" then
        Graph.connect(self.owner, self.dragSource, row.object)
    elseif self.downPort and row and row.object == self.dragSource then
        self.owner.linkSource = self.owner.linkSource ~= row.object and row.object or nil
    end
    self.dragSource, self.downPort = nil, nil
    self:setCapture(false)
    return true
end
Graph.onMouseUpOutside = Graph.onMouseUp

---@return nil
function Graph:prerender()
    local header, rowHeight = self.headerHeight, self.rowHeight
    self:setStencilRect(0, header, self.width - 12, math.max(0, self.height - header))
    self:drawRectStatic(0, header, self.width, self.height - header, 1, .055, .055, .055)
    local half = (self.width - 40) / 2
    for side = 1, 2 do
        local rows = side == 1 and self.triggers or self.defenses
        local x = side == 1 and 4 or half + 26
        local first = math.max(1, math.floor(-self:getYScroll() / rowHeight) + 1)
        local last = math.min(#rows, math.ceil((self.height - header - self:getYScroll()) / rowHeight))
        for i = first, last do
            local row, y = rows[i], header + (i - 1) * rowHeight
            if y + self:getYScroll() + rowHeight > header and y + self:getYScroll() < self.height then
                local selected = row.object == self.owner.selected
                self:drawRect(x, y + 3, half - 4, rowHeight - 6, 1, selected and .11 or .025, selected and .11 or .025, selected and .11 or .025)
                self:drawRectBorder(x, y + 3, half - 4, rowHeight - 6, 1, selected and .65 or .25, selected and .65 or .25, selected and .65 or .25)
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
    for i = 1, #self.edges do
        local edge = self.edges[i]
        local y1, y2 = header + (edge.input - .5) * rowHeight, header + (edge.output - .5) * rowHeight
        local source, target = self.triggers[edge.input], self.defenses[edge.output]
        local selected = source.object == self.owner.selected or target.object == self.owner.selected
        local state = A.state(source.object)
        local active = state and state.active == true
        local scroll = self:getYScroll()
        if math.max(y1, y2) + scroll >= header and math.min(y1, y2) + scroll < self.height then
            self:drawLine(nil, half - 3, y1, half + 28, y2, selected and 2 or 1, selected and 1 or .65,
                active and .4 or .75, active and .9 or .75, active and .4 or .75)
        end
    end
    if self.dragSource then
        local state = A.state(self.dragSource)
        local index = state and self.positions[state.id]
        if index then
            self:drawLine(nil, half - 3, header + (index - .5) * rowHeight, self:getMouseX(),
                self:getMouseY() - self:getYScroll(), 2, .9, .8, .9, .8)
        end
    end
    self:clearStencilRect()
    local scroll = self:getYScroll()
    Theme.section(self, 0, -scroll, self.width, header, header, getText("UI_OMHTT_Connections"))
    self:drawText(getText("UI_OMHTT_Triggers"), 8, self.owner.lineHeight + 10 - scroll, .75, .75, .75, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_Defenses"), half + 30, self.owner.lineHeight + 10 - scroll, .75, .75, .75, 1, UIFont.Small)
end

---@param owner ISPanel Controller
---@return ISPanel graph
function Graph.create(owner)
    local graph = Graph:new(12, 180, 300, 400)
    graph.owner, graph.refreshDue = owner, 0
    graph.triggers, graph.defenses, graph.positions, graph.edges = {}, {}, {}, {}
    graph.markers = {}
    graph.markerByObject = {}
    graph.stats = setmetatable({}, {__mode = "k"})
    graph.statsIndex, graph.statsDue = 1, 0
    graph.tooltip = getText("UI_OMHTT_GraphLinkHelp")
    graph.headerHeight, graph.rowHeight = owner.lineHeight * 2 + 16, owner.lineHeight * 3 + 12
    graph:initialise()
    graph:setScrollChildren(false)
    graph:addScrollBars(false)
    Theme.scrollbar(graph)
    owner:addChild(graph)
    return graph
end

return Graph
