if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISUIElement")
local Graph = require("OMHTT/ControlGraph")
local A = require("OMHTT/ControlAccess")
local Map = ISPanel:derive("OMHTTControlMap")
local Native = ISUIElement:derive("OMHTTControlNativeMap")

---@return nil
function Native:instantiate()
    self.javaObject = UIWorldMap.new(self)
    self.mapAPI = self.javaObject:getAPIv3()
    self.javaObject:setX(self.x)
    self.javaObject:setY(self.y)
    self.javaObject:setWidth(self.width)
    self.javaObject:setHeight(self.height)
    self.javaObject:setConsumeMouseEvents(false)
    self:createChildren()
end

-- Consume the native child event before it reaches the world menu.
---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Native:onRightMouseDown(x, y)
    return self.parent:onRightMouseDown(x + self.x, y + self.y)
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Native:onRightMouseUp(x, y)
    return self.parent:onRightMouseUp(x + self.x, y + self.y)
end

---@return nil
function Map:loadNative()
    if self.mapAttempted then return end
    self.mapAttempted = true
    self.tooltip = getText("UI_OMHTT_MapUnavailable")
    if not SandboxVars.Map or SandboxVars.Map.AllowWorldMap ~= true then return end
    if not self.nativeMap then
        require("ISUI/Maps/ISMapDefinitions")
        local map = Native:new(0, 0, self.width, self.height)
        map:initialise()
        map:instantiate()
        local api = map.mapAPI
        api:setMapItem(MapItem.getSingleton())
        local dirs = getLotDirectories()
        for i = 0, dirs:size() - 1 do
            local path = "media/maps/" .. dirs:get(i)
            if fileExists(path .. "/worldmap.xml") then
                api:addData(path .. "/worldmap.xml")
            end
            api:endDirectoryData()
            api:addImages(path)
        end
        if api:getDataCount() == 0 and api:getImagesCount() == 0 then
            return
        end
        api:setBoundsFromWorld()
        api:setMaxZoom(22)
        api:setZoom(20)
        api:setBoolean("Isometric", false)
        api:setBoolean("HideUnvisited", true)
        api:setBoolean("Players", false)
        api:setBoolean("RemotePlayers", false)
        api:setBoolean("Symbols", false)
        api:setBoolean("ImagePyramid", false)
        MapUtils.initDefaultStyleV1(map)
        api:centerOn(self.centerX, self.centerY)
        self:addChild(map)
        self.nativeMap = map
        self.tooltip = getText("UI_OMHTT_MapNativeTip")
    end
    self.nativeMode = true
end

---@param object IsoObject Focus
---@return nil
function Map:focus(object)
    self.centerX, self.centerY = object:getX() + .5, object:getY() + .5
    if self.nativeMap then
        self.nativeMap.mapAPI:centerOn(self.centerX, self.centerY)
    end
end

---@param x number World X
---@param y number World Y
---@return number x
---@return number y
function Map:point(x, y)
    if self.nativeMode then
        return self.nativeMap.mapAPI:worldToUIX(x, y), self.nativeMap.mapAPI:worldToUIY(x, y)
    end
    local scale = math.min(self.width, self.height) / self.span
    return self.width / 2 + (x - self.centerX) * scale, self.height / 2 + (y - self.centerY) * scale
end

---@param x number Local X
---@param y number Local Y
---@return IsoObject? object
function Map:hit(x, y)
    if x < 0 or x >= self.width or y < 0 or y >= self.height then return nil end
    local nearest, distance
    for i = 1, #self.owner.graph.markers do
        local marker = self.owner.graph.markers[i]
        local object = marker.object
        local px, py = self:point(object:getX() + .5, object:getY() + .5)
        local d = (x - px) ^ 2 + (y - py) ^ 2
        if math.abs(x - px) <= marker.halfWidth and math.abs(y - py) <= 12 and (not distance or d < distance) then
            nearest, distance = object, d
        end
    end
    return nearest
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Map:onMouseDown(x, y)
    self.downX, self.downY = x, y
    self.startX, self.startY = self.centerX, self.centerY
    self.dragObject = self:hit(x, y)
    self.panning = self.dragObject == nil
    self:setCapture(true)
    return true
end

---@param dx number Mouse movement X
---@param dy number Mouse movement Y
---@return boolean handled
function Map:onMouseMove(dx, dy)
    self.hoverObject = self:hit(self:getMouseX(), self:getMouseY())
    if self.panning then
        local x, y = self:getMouseX(), self:getMouseY()
        if self.nativeMode then
            local api = self.nativeMap.mapAPI
            local wx, wy = api:uiToWorldX(x, y), api:uiToWorldY(x, y)
            local sx, sy = api:uiToWorldX(self.downX, self.downY), api:uiToWorldY(self.downX, self.downY)
            self.centerX, self.centerY = self.centerX + sx - wx, self.centerY + sy - wy
            self.downX, self.downY = x, y
            api:centerOn(self.centerX, self.centerY)
        else
            local scale = math.min(self.width, self.height) / self.span
            self.centerX, self.centerY = self.startX - (x - self.downX) / scale, self.startY - (y - self.downY) / scale
        end
    end
    return true
end
Map.onMouseMoveOutside = Map.onMouseMove

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Map:onMouseUp(x, y)
    local target, source = self:hit(x, y), self.dragObject
    self.dragObject, self.panning = nil, false
    self:setCapture(false)
    if source and target and source ~= target then
        Graph.connect(self.owner, source, target)
    elseif target then
        getSoundManager():playUISound("UIActivateButton")
        Graph.select(self.owner, target)
    end
    return true
end

---@return boolean handled
function Map:onMouseUpOutside()
    self.dragObject, self.panning = nil, false
    self:setCapture(false)
    return true
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Map:onRightMouseDown(x, y)
    self:onMouseUpOutside()
    return true
end

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Map:onRightMouseUp(x, y)
    local object = self:hit(x, y)
    if object then
        Graph.menu(self.owner, object)
    end
    return true
end

---@param delta number Wheel delta
---@return boolean handled
function Map:onMouseWheel(delta)
    if self.nativeMode then
        self.nativeMap.mapAPI:zoomAt(self.width / 2, self.height / 2, delta)
    else
        self.span = math.max(12, math.min(100, self.span + delta * 4))
    end
    return true
end

---@return nil
function Map:prerender()
    self:drawRect(0, 0, self.width, self.height, 1, .07, .075, .07)
    if self.nativeMap and (self.nativeMap.width ~= self.width or self.nativeMap.height ~= self.height) then
        self.nativeMap:setWidth(self.width)
        self.nativeMap:setHeight(self.height)
    end
    self:setStencilRect(0, 0, self.width, self.height)
end

---@return nil
function Map:render()
    self:repaintStencilRect(0, 0, self.width, self.height)
    local controller = self.owner.object
    local cx, cy = controller:getX() + .5, controller:getY() + .5
    local previousX, previousY = self:point(cx + 20, cy)
    for i = 1, 64 do
        local angle = i * math.pi / 32
        local x, y = self:point(cx + math.cos(angle) * 20, cy + math.sin(angle) * 20)
        self:drawLine(nil, previousX, previousY, x, y, 1, .65, .65, .7, .65)
        previousX, previousY = x, y
    end
    local graph = self.owner.graph
    for i = 1, #graph.markers do
        local marker = graph.markers[i]
        marker.x, marker.y = self:point(marker.object:getX() + .5, marker.object:getY() + .5)
    end
    for i = 1, #graph.edges do
        local edge = graph.edges[i]
        local source, target = graph.triggers[edge.input], graph.defenses[edge.output]
        if source and target then
            local first, second = graph.markerByObject[source.object], graph.markerByObject[target.object]
            local x1, y1, x2, y2 = first.x, first.y, second.x, second.y
            local selected = source.object == self.owner.selected or target.object == self.owner.selected
            local state = A.state(source.object)
            local active = state and state.active == true
            self:drawLine(nil, x1, y1, x2, y2, 2, selected and 1 or .5, active and .4 or .7, active and .9 or .7, active and .4 or .7)
        end
    end
    if self.dragObject then
        local x, y = self:point(self.dragObject:getX() + .5, self.dragObject:getY() + .5)
        self:drawLine(nil, x, y, self:getMouseX(), self:getMouseY(), 2, .9, .8, .9, .8)
    end
    for i = 1, #graph.markers do
        local marker = graph.markers[i]
        local object = marker.object
        local state = A.state(object)
        if state then
            local x, y = marker.x, marker.y
            local selected = self.owner.selected == object or self.hoverObject == object
            local half = marker.halfWidth
            local shade = selected and .35 or .12
            if state.kind == "Turret" then
                self:drawRect(x - half, y - 11, half * 2, 22, 1, shade, shade, shade)
                self:drawRectBorder(x - half, y - 11, half * 2, 22, 1, .85, .85, .85)
            else
                for scan = -11, 11 do
                    local fraction = math.abs(scan) / 12
                    local width = half * (state.kind == "Controller" and (1 - fraction) or math.sqrt(1 - fraction * fraction))
                    self:drawRect(x - width, y + scan, width * 2, 1, 1, shade, shade, shade)
                end
                local segments = state.kind == "Controller" and 4 or 16
                local px, py = x + half, y
                for j = 1, segments do
                    local angle = j * math.pi * 2 / segments
                    local nx, ny = x + math.cos(angle) * half, y + math.sin(angle) * 12
                    self:drawLine(nil, px, py, nx, ny, 2, 1, .85, .85, .85)
                    px, py = nx, ny
                end
            end
            self:drawTextCentre(marker.label, x, y - 8, 1, 1, 1, 1, UIFont.Small)
        end
    end
    self:clearStencilRect()
end

---@param owner ISPanel Controller
---@return ISPanel map
function Map.create(owner)
    local map = Map:new(0, 0, 300, 230)
    map.owner, map.span = owner, 48
    map:initialise()
    map:focus(owner.object)
    owner:addChild(map)
    map:loadNative()
    return map
end

return Map
