if isServer() then return end
require("ISUI/ISResizeWidget")
require("ISUI/ISLayoutManager")
local G = {}
local saved = {}
local Grip = ISResizeWidget:derive("OMHTTResizeGrip")

---@param x number Local X
---@param y number Local Y
---@return boolean handled
function Grip:onMouseDown(x, y)
    self.startX, self.startY = getMouseX(), getMouseY()
    self.startWidth, self.startHeight = self.target.width, self.target.height
    self.target.moving = false
    if ISMouseDrag.dragView == self.target then
        ISMouseDrag.dragView = nil
    end
    self.target:setCapture(false)
    self.resizing = true
    self:setCapture(true)
    return true
end

---@param dx number Mouse delta X
---@param dy number Mouse delta Y
---@return boolean handled
function Grip:onMouseMove(dx, dy)
    if self.resizing then
        G.resize(self.target, self.startWidth + getMouseX() - self.startX, self.startHeight + getMouseY() - self.startY)
    end
    return true
end
Grip.onMouseMoveOutside = Grip.onMouseMove

---@return nil
function Grip:render()
    self:drawTextureScaled(self.resizeimage, 0, 0, 18, 18, 1, 1, 1, 1)
end

---@param panel ISPanel Window
---@return nil
function G.checkViewport(panel)
    if not panel.geometryKey then return end
    local pn = panel.player:getPlayerNum()
    local left, top = getPlayerScreenLeft(pn), getPlayerScreenTop(pn)
    local width, height = getPlayerScreenWidth(pn), getPlayerScreenHeight(pn)
    if panel.viewportLeft == left and panel.viewportTop == top
        and panel.viewportWidth == width and panel.viewportHeight == height then return end
    panel.viewportLeft, panel.viewportTop = left, top
    panel.viewportWidth, panel.viewportHeight = width, height
    G.resize(panel, panel.width, panel.height)
end

---@param panel ISPanel Window
---@param width number Requested width
---@param height number Requested height
---@return nil
function G.resize(panel, width, height)
    local pn = panel.player:getPlayerNum()
    local left, top = getPlayerScreenLeft(pn) + 8, getPlayerScreenTop(pn) + 8
    local sw, sh = getPlayerScreenWidth(pn) - 16, getPlayerScreenHeight(pn) - 16
    if panel.resizeGrip.resizing then
        sw = sw - math.max(0, panel.x - left)
        sh = sh - math.max(0, panel.y - top)
    end
    width = math.min(sw, math.max(panel.minimumWidth, width))
    height = math.min(sh, math.max(panel.minimumHeight, height))
    if not panel.resizeGrip.resizing then
        panel:setX(math.max(left, math.min(panel.x, left + sw - width)))
        panel:setY(math.max(top, math.min(panel.y, top + sh - height)))
    end
    if panel.width == width and panel.height == height then return end
    panel:setWidth(width)
    panel:setHeight(height)
    panel.userSized = true
    panel.geometryWidth, panel.geometryHeight = nil, nil
    panel.resizeGrip:setX(width - 18)
    panel.resizeGrip:setY(height - 18)
    panel.reflow(panel)
    require("OMHTT/ControlWindowChrome").arrange(panel)
end

---@param panel ISPanel Window
---@param name string Window key
---@param data table Geometry
---@return nil
function G.save(panel, name, data)
    data.x, data.y, data.width, data.height = panel.x, panel.y, panel.width, panel.height
    data.layout = 1
end

---@param panel ISPanel Window
---@param name string Window key
---@param data table Geometry
---@return nil
function G.restore(panel, name, data)
    local x, y, width, height = tonumber(data.x), tonumber(data.y), tonumber(data.width), tonumber(data.height)
    if not x or not y or not width or not height then return end
    if string.find(name, "OMHTT_Controller_", 1, true) and tonumber(data.layout) ~= 1 then
        height = math.max(height, panel.height)
    end
    panel:setX(x)
    panel:setY(y)
    G.resize(panel, width, height)
end

---@param panel ISPanel Window
---@return nil
function G.close(panel)
    if not panel.geometryKey then return end
    local data = {}
    G.save(panel, panel.geometryKey, data)
    saved[panel.geometryKey] = data
    panel.resizeGrip.resizing = false
    panel.resizeGrip:setCapture(false)
    if panel.graph then
        panel.graph.dragSource = nil
        panel.graph:setCapture(false)
        panel.mapView:onMouseUpOutside()
    end
    ISLayoutManager.windows[panel.geometryKey] = {target = data, funcs = {
        SaveLayout = function(value, name, layout)
            layout.x, layout.y, layout.width, layout.height = value.x, value.y, value.width, value.height
            layout.layout = value.layout
        end,
    }}
    ISLayoutManager.OnPostSave()
end

---@param panel ISPanel Window
---@param key string Window family
---@param minWidth number Smallest usable width
---@param minHeight number Smallest usable height
---@param reflow function Geometry callback
---@return nil
function G.install(panel, key, minWidth, minHeight, reflow)
    panel.minimumWidth, panel.minimumHeight = minWidth, minHeight
    panel.reflow = reflow
    panel.geometryKey = "OMHTT_" .. key .. "_" .. panel.player:getPlayerNum()
    local pn = panel.player:getPlayerNum()
    panel.viewportLeft, panel.viewportTop = getPlayerScreenLeft(pn), getPlayerScreenTop(pn)
    panel.viewportWidth, panel.viewportHeight = getPlayerScreenWidth(pn), getPlayerScreenHeight(pn)
    local grip = Grip:new(panel.width - 18, panel.height - 18, 18, 18, panel)
    grip.resizeFunction = G.resize
    grip.resizeimage = getTexture("media/ui/ResizeIcon.png")
    grip:initialise()
    grip:setAnchorRight(false)
    grip:setAnchorBottom(false)
    panel.resizeGrip = grip
    panel:addChild(grip)
    ISLayoutManager.RegisterWindow(panel.geometryKey, {SaveLayout = G.save, RestoreLayout = G.restore}, panel)
    local data = saved[panel.geometryKey]
    if data then
        G.restore(panel, panel.geometryKey, data)
    end
end

return G
