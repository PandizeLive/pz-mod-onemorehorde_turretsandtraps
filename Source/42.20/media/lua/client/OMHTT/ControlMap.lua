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

---@param enabled boolean Native map background
---@return nil
function Map:setNative(enabled)
    if enabled and (not SandboxVars.Map or SandboxVars.Map.AllowWorldMap ~= true) then
        self.owner.nativeMapButton.tooltip = getText("UI_OMHTT_MapUnavailable")
        return
    end
    if enabled and not self.nativeMap then
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
            self.owner.nativeMapButton:setEnable(false)
            self.owner.nativeMapButton.tooltip = getText("UI_OMHTT_MapUnavailable")
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
    end
    self.nativeMode = enabled
    if self.nativeMap then
        self.nativeMap:setVisible(enabled)
    end
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
    if not self.nativeMode then
        local scale = math.min(self.width, self.height) / self.span
        local startX, startY = self:point(math.floor(self.centerX - self.span), math.floor(self.centerY - self.span))
        for i = 0, math.ceil(self.span * 2) do
            local x, y = startX + i * scale, startY + i * scale
            self:drawLine2(x, 0, x, self.height, .3, .35, .35, .35)
            self:drawLine2(0, y, self.width, y, .3, .35, .35, .35)
        end
    end
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
        self:drawLine2(previousX, previousY, x, y, .65, .65, .7, .65)
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
            self:drawLine2(x1, y1, x2, y2, selected and 1 or .5, active and .4 or .7, active and .9 or .7, active and .4 or .7)
        end
    end
    if self.dragObject then
        local x, y = self:point(self.dragObject:getX() + .5, self.dragObject:getY() + .5)
        self:drawLine2(x, y, self:getMouseX(), self:getMouseY(), .9, .8, .9, .8)
    end
    for i = 1, #graph.markers do
        local marker = graph.markers[i]
        local object = marker.object
        local state = A.state(object)
        if state then
            local x, y = marker.x, marker.y
            local selected = self.owner.selected == object
            local half = marker.halfWidth
            self:drawRect(x - half, y - 11, half * 2, 22, 1, selected and .35 or .12, selected and .35 or .12, selected and .35 or .12)
            self:drawRectBorder(x - half, y - 11, half * 2, 22, 1, .85, .85, .85)
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
    return map
end

return Map
