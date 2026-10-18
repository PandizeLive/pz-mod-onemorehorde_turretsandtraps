if isServer() then return end
require("ISUI/ISPanel")
local Drag = {}

---@param panel ISPanel Window
---@param x number Local mouse X
---@param y number Local mouse Y
---@return boolean handled
function Drag.start(panel, x, y)
    if y >= 0 and y < panel.titleHeight then
        ISPanel.onMouseDown(panel, x, y)
        if panel.moving then
            panel:setCapture(true)
        end
    end
    return true
end

---@param panel ISPanel Window
---@return boolean handled
function Drag.stop(panel)
    panel.moving = false
    panel:setCapture(false)
    if ISMouseDrag.dragView == panel then
        ISMouseDrag.dragView = nil
    end
    return true
end

---@param panel ISPanel Window
---@return nil
function Drag.update(panel)
    require("OMHTT/WindowGeometry").checkViewport(panel)
    if panel.moving and not isMouseButtonDown(0) then
        Drag.stop(panel)
    end
    if not isMouseButtonDown(0) then
        if not panel.releaseDue then
            panel.releaseDue = getTimestampMs() + 100
        end
        if getTimestampMs() < panel.releaseDue then return end
        if panel.resizeGrip and panel.resizeGrip.resizing then
            panel.resizeGrip.resizing = false
            panel.resizeGrip:setCapture(false)
        end
        if panel.graph and panel.graph.dragSource then
            panel.graph.dragSource = nil
            panel.graph:setCapture(false)
        end
        if panel.mapView and (panel.mapView.panning or panel.mapView.dragObject) then
            panel.mapView:onMouseUpOutside()
        end
    else
        panel.releaseDue = nil
    end
end

return Drag
