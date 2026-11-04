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
    local header = self:isMouseOver() and self:getMouseY() < self.lineHeight
    if not row and not header then self:hideTooltip(); return end
    if not self.tooltip then
        self.tooltip = ISToolTip:new()
        self.tooltip:initialise()
        self.tooltip:addToUIManager()
        self.tooltip:setOwner(self)
        self.tooltip.maxLineWidth = 10000
    end
    self.tooltip:setName(header and getText("UI_OMHTT_InstalledModules") or row.title)
    self.tooltip.description = header and getText("UI_OMHTT_ModuleStatsHelp") or row.details
    self.tooltip:setVisible(true)
end

---@return nil
function List:prerender()
    self:drawRect(0, 0, self.width, self.height, .85, .015, .015, .015)
    self:drawRectBorder(0, 0, self.width, self.height, .8, .3, .3, .3)
    self:drawRect(0, 0, self.width, self.lineHeight, .9, .12, .12, .12)
    self.offset = math.min(self.offset, math.max(0, #self.rows - self.visibleRows))
    self:drawText(self.title or getText("UI_OMHTT_InstalledModules"), 4, 0, 1, 1, 1, 1, UIFont.Small)
    for i = 1, self.visibleRows do
        local row = self.rows[self.offset + i]
        if not row then break end
        local y = i * self.lineHeight
        local shade = row.inactive and .5 or .85
        local color = row.color
        local effectWidth = getTextManager():MeasureStringX(UIFont.Small, row.effect)
        if color then self:drawRect(1, y, self.width - 2, self.lineHeight, .14, color.r, color.g, color.b) end
        local clipX, clipY, clipW, clipH = self:clampStencilRectToParent(4, y, math.max(0, self.width - effectWidth - 16), self.lineHeight)
        self:drawText(row.title, 4, y, color and color.tr or shade, color and color.tg or shade, color and color.tb or shade, row.inactive and .5 or 1, UIFont.Small)
        self:clearStencilRect()
        self:repaintStencilRect(clipX, clipY, clipW, clipH)
        self:drawTextRight(row.effect, self.width - 6, y, shade, shade, shade, 1, UIFont.Small)
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
