if isClient() or isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
require("ISUI/ISToolTipInv")
require("ISUI/ISToolTip")
local T = require("OMHTT/Turret")
local Slot = ISPanel:derive("OMHTTTurretSlot")

---@return nil
function Slot:hideTooltip()
    if self.tooltip then self.tooltip:removeFromUIManager(); self.tooltip = nil end
end

---@return nil
function Slot:clearDrag()
    if ISMouseDrag.draggingFocus == self then
        ISMouseDrag.dragging, ISMouseDrag.draggingFocus = nil, nil
    end
end

---@param x number Local mouse X
---@param y number Local mouse Y
---@return boolean handled
function Slot:onMouseDown(x, y)
    if self.kind == "magazine" then
        if #self.items > 0 then self.owner:feedback(0, "EjectMagazine") end
        return true
    end
    if #self.items == 0 then return true end
    if not T.canRemove(self.owner.object:getContainer(), self.items[1]) then
        self.owner:feedback(0, self.kind == "capacity" and "CapacityFull" or "Servicing")
        return true
    end
    self:hideTooltip()
    ISMouseDrag.dragging = self.items
    ISMouseDrag.draggingFocus = self
    return true
end

---@param x number Local mouse X
---@param y number Local mouse Y
---@return boolean handled
function Slot:onMouseUp(x, y)
    if ISMouseDrag.dragging and ISMouseDrag.draggingFocus ~= self then
        local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        if self.disabled then
            self.owner:feedback(0, "TransferFull")
        elseif self.kind == "magazine" then
            self.owner:magazine(items[1])
        else
            self.owner:transfer(items, true, self.kind)
        end
        local focus = ISMouseDrag.draggingFocus
        if focus then focus:onMouseUp(0, 0) end
        ISMouseDrag.dragging, ISMouseDrag.draggingFocus = nil, nil
    else
        self:clearDrag()
    end
    return true
end

---@param x number Local mouse X
---@param y number Local mouse Y
---@return boolean handled
function Slot:onRightMouseUp(x, y)
    if self.kind == "magazine" then
        self.owner:magazine(nil)
    else
        self.owner:transfer(self.items, false, self.kind)
    end
    self:clearDrag()
    return true
end

---@return nil
function Slot:update()
    if ISMouseDrag.draggingFocus == self and not isMouseButtonDown(0) then self:clearDrag() end
    local item = self.items[1]
    if self:isMouseOver() and not ISMouseDrag.dragging and self.detailText then
        if not self.tooltip then
            self.tooltip = ISToolTip:new()
            self.tooltip:initialise()
            self.tooltip:addToUIManager()
            self.tooltip:setOwner(self)
            self.tooltip.maxLineWidth = 360
        end
        self.tooltip:setName(item and item:getDisplayName() or getText("UI_OMHTT_BatteryEstimate"))
        self.tooltip.description = self.detailText
        self.tooltip:setVisible(true)
    elseif self:isMouseOver() and item and not ISMouseDrag.dragging then
        if not self.tooltip then
            self.tooltip = ISToolTipInv:new(item)
            self.tooltip:initialise()
            self.tooltip:addToUIManager()
            self.tooltip:setOwner(self)
            self.tooltip:setCharacter(self.owner.player)
        end
        self.tooltip:setItem(item)
        self.tooltip:setVisible(true)
    else
        self:hideTooltip()
    end
end

---@return nil
function Slot:prerender()
    ISPanel.prerender(self)
    local h = self.owner.lineHeight
    local red, green = self.missing and 1 or 0.8, self.missing and 0.3 or 0.8
    self:drawText(self.label, 8, 4, red, green, green, 1, UIFont.Small)
    if self.missing then self:drawRectBorder(0, 0, self.width, self.height, 1, 1, 0.3, 0.3) end
    local item = self.items[1]
    local name = self.emptyText or getText("UI_OMHTT_ManageDrop")
    if item then
        if self.kind == "module" then
            ISInventoryItem.renderItemIcon(self, item, self.width / 2 - 8, h + 2, 1, 16, 16)
        else
            ISInventoryItem.renderItemIcon(self, item, 8, h + 8, 1, 32, 32)
        end
        name = item:getDisplayName()
        if self.kind == "module" or self.kind == "capacity" then
            local key = T.component(item:getFullType())
            if key then name = getText("UI_OMHTT_Module" .. key) end
        end
        if #self.items > 1 then name = tostring(#self.items) .. " x " .. name end
    end
    local textX, textY = 44, h + 8
    if self.kind == "module" then textX, textY = 4, math.min(h + 20, self.height - h - 2) end
    self:setStencilRect(textX, textY, self.width - textX - 4, h + 4)
    self:drawText(name, textX, textY, 1, 1, 1, 1, UIFont.Small)
    self:clearStencilRect()
    if self.disabled then self:drawRect(0, 0, self.width, self.height, 0.4, 0, 0, 0) end
    if self:isMouseOver() and ISMouseDrag.dragging and ISMouseDrag.draggingFocus ~= self then
        self:drawRectBorder(0, 0, self.width, self.height, 1, 0.8, 0.8, 0.8)
    end
end

---@param delta number Wheel direction
---@return boolean handled
function Slot:onMouseWheel(delta)
    if self.kind == "module" then return self.owner:scrollModules(delta) end
    return false
end

---@return nil
function Slot:render()
    if ISMouseDrag.draggingFocus == self and self.items[1] then
        ISInventoryItem.renderItemIcon(self, self.items[1], getMouseX() - self:getAbsoluteX() + 12,
            getMouseY() - self:getAbsoluteY() + 12, 1, 32, 32)
    end
end

---@param owner ISPanel Turret window
---@param kind string Accepted type
---@param label string Slot label
---@param x number Local X
---@param y number Local Y
---@param width number Width
---@param height number Height
---@return table slot
function Slot:new(owner, kind, label, x, y, width, height)
    local slot = ISPanel.new(self, x, y, width, height)
    slot.owner, slot.kind, slot.label, slot.items = owner, kind, label, {}
    slot.backgroundColor = {r = 0.08, g = 0.08, b = 0.08, a = 1}
    return slot
end

return Slot
