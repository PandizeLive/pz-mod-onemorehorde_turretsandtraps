require("ISUI/ISPanel")
require("ISUI/ISToolTip")
local List = ISPanel:derive("OMHTTTurretBenefitList")

---@return nil
function List:hideTooltip()
    if self.tooltip then self.tooltip:removeFromUIManager(); self.tooltip = nil end
end

---@param delta number Wheel direction
---@return boolean handled
function List:onMouseWheel(delta)
    self.offset = math.max(0, math.min(math.max(0, #self.rows - self.visibleRows), self.offset + (delta > 0 and 1 or -1)))
    return true
end

---@return nil
function List:update()
    local row
    if self:isMouseOver() and self:getMouseY() >= self.lineHeight then
        row = self.rows[self.offset + math.floor((self:getMouseY() - self.lineHeight) / self.lineHeight) + 1]
    end
    if not row then self:hideTooltip(); return end
    if not self.tooltip then
        self.tooltip = ISToolTip:new()
        self.tooltip:initialise()
        self.tooltip:addToUIManager()
        self.tooltip:setOwner(self)
        self.tooltip.maxLineWidth = 360
    end
    self.tooltip:setName(row.title)
    self.tooltip.description = row.details
    self.tooltip:setVisible(true)
end

---@return nil
function List:prerender()
    self.offset = math.min(self.offset, math.max(0, #self.rows - self.visibleRows))
    self:drawText(getText("UI_OMHTT_InstalledModules"), 4, 0, 1, 1, 1, 1, UIFont.Small)
    for i = 1, self.visibleRows do
        local row = self.rows[self.offset + i]
        if not row then break end
        local y = i * self.lineHeight
        local shade = row.inactive and .5 or .85
        self:setStencilRect(4, y, self.width - 8, self.lineHeight)
        self:drawText(row.title .. "  " .. row.effect, 4, y, shade, shade, shade, 1, UIFont.Small)
        self:clearStencilRect()
    end
    if #self.rows > self.visibleRows then self:drawRect(self.width - 2, self.lineHeight, 2, self.height - self.lineHeight, .7, .5, .5, .5) end
end

---@param x number Position
---@param y number Position
---@param width number Width
---@param height number Height
---@param lineHeight number Font height plus spacing
---@return table list
function List:new(x, y, width, height, lineHeight)
    local list = ISPanel.new(self, x, y, width, height)
    list.rows, list.offset, list.lineHeight = {}, 0, lineHeight
    list.visibleRows = math.max(1, math.floor(height / lineHeight) - 1)
    return list
end

return List
