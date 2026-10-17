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
    if panel.moving and not isMouseButtonDown(0) then
        Drag.stop(panel)
    end
end

return Drag
