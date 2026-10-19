if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
require("ISUI/ISToolTipInv")
require("ISUI/ISToolTip")
local T = require("OMHTT/Turret")
local Hint = require("OMHTT/SlotHint")
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
    if self.kind == "void" then self.owner:inspectVoid(); return true end
    if self.owner.readOnly then return false end
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
    if self.owner.readOnly then return false end
    if ISMouseDrag.dragging and ISMouseDrag.draggingFocus ~= self then
        local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        if self.disabled then
            self.owner:feedback(0, "TransferFull")
        elseif self.kind == "void" then
            self.owner:storeVoid(items)
        elseif self.kind == "magazine" then
            self.owner:magazine(items[1])
        else
            self.owner:transfer(items, true, self.kind, self.kind == "module" and self.items[1] or nil)
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
    if self.owner.readOnly then return false end
    if self.kind == "void" then require("OMHTT/TurretUtilities").menu(self.owner, "void"); return true end
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
    if ISMouseDrag.draggingFocus == self and not isMouseButtonDown(0) then
        self.owner:feedback(0, "TransferDestination")
        self:clearDrag()
    end
    local item = self.items[1]
    if self.kind == "module" or self.kind == "capacity" then
        local name = item and T.component(item:getFullType())
        self.detailText = name and require("OMHTT/TurretDescriptions").get(name, true) or nil
        if name == "Void" then self.detailText = self.detailText .. " <LINE> " .. require("OMHTT/TurretVoid").description(item, nil, true) end
    end
    if self.detailProvider and self:isMouseOver() and not ISMouseDrag.dragging then self.detailText = self.detailProvider() end
    if self:isMouseOver() and not ISMouseDrag.dragging and self.detailText then
        if not self.tooltip then
            self.tooltip = ISToolTip:new()
            self.tooltip:initialise()
            self.tooltip:addToUIManager()
            self.tooltip:setOwner(self)
            self.tooltip.maxLineWidth = 10000
        end
        self.tooltip:setName(self.detailTitle or (item and item:getDisplayName()) or self.label)
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
    if self.kind == "module" and self.disabled and not self.items[1] then
        self:drawTextCentre(getText("UI_OMHTT_ManageLocked"), self.width / 2, (self.height - h) / 2, .5, .5, .5, 1, UIFont.Small)
        return
    end
    local color = self.rarity
    if color then self:drawRect(1, 1, self.width - 2, self.height - 2, .18, color.r, color.g, color.b) end
    local red, green = self.missing and 1 or 0.8, self.missing and 0.3 or 0.8
    local narrowModule = self.kind == "module" and self.height < h * 2 + 8
    if not narrowModule then
        self:drawText(self.label, 8, 4, red, green, green, 1, UIFont.Small)
    end
    if self.meter then
        local labelWidth = getTextManager():MeasureStringX(UIFont.Small, self.label)
        local start = 16 + labelWidth
        if self.width - start > 14 then
            self:drawProgressBar(start, 7, self.width - start - 6, 7, self.meter, require("OMHTT/ControlTheme").accent)
        end
    end
    if self.missing then self:drawRectBorder(0, 0, self.width, self.height, 1, 1, 0.3, 0.3) end
    if self.summary then
        local right = self.textInsetRight or 0
        if self.hintTexture and not self.disabled then
            Hint.draw(self, self.width - right - 36, h + 6, 28)
            right = right + 36
        end
        local clipX, clipY, clipW, clipH = self:clampStencilRectToParent(8, h + 3, self.width - 16 - right, self.height - h - 5)
        self:drawText(self.summary, 8, h + 4, 1, 1, 1, 1, UIFont.Small)
        if self.subtext then
            self:drawText(self.subtext, 8, h * 2 + 4, .75, .75, .75, 1, UIFont.Small)
        end
        self:clearStencilRect()
        self:repaintStencilRect(clipX, clipY, clipW, clipH)
        if self.disabled and self.kind ~= "magazine" then
            self:drawRect(0, 0, self.width, self.height, .4, 0, 0, 0)
        end
        if self:isMouseOver() and ISMouseDrag.dragging and ISMouseDrag.draggingFocus ~= self then
            self:drawRectBorder(0, 0, self.width, self.height, 1, .8, .8, .8)
        end
        return
    end
    local item = self.items[1]
    local name = self.emptyText or getText("UI_OMHTT_ManageDrop")
    if self.kind == "module" and not item then
        name = self.disabled and getText("UI_OMHTT_ManageLocked") or "+"
    end
    if item then
        if self.kind == "module" then
            ISInventoryItem.renderItemIcon(self, item, narrowModule and 4 or self.width / 2 - 8, narrowModule and 5 or (self.compact and 6 or h + 2), 1, 16, 16)
        else
            ISInventoryItem.renderItemIcon(self, item, 8, h + 8, 1, 32, 32)
        end
        name = item:getDisplayName()
        if self.kind == "module" or self.kind == "capacity" then
            local key = T.component(item:getFullType())
            if key then name = getText("UI_OMHTT_Module" .. key) end
        end
        if #self.items > 1 then name = tostring(#self.items) .. " x " .. name end
    elseif not self.disabled then
        if self.kind == "module" then
            Hint.draw(self, narrowModule and 4 or self.width / 2 - 8, narrowModule and 5 or (self.compact and 6 or h + 2), 16)
        else
            Hint.draw(self, 8, h + 8, 32)
        end
    end
    local textX, textY = self.kind == "void" and 8 or 44, h + 8
    if self.kind == "module" then textX, textY = 4, math.min(h + 20, self.height - h - 2) end
    if narrowModule then
        textX, textY = 24, 4
    end
    local clipX, clipY, clipW, clipH = self:clampStencilRectToParent(textX, textY, self.width - textX - 4, h + 4)
    self:drawText(name, textX, textY, color and color.tr or 1, color and color.tg or 1, color and color.tb or 1, 1, UIFont.Small)
    self:clearStencilRect()
    self:repaintStencilRect(clipX, clipY, clipW, clipH)
    if self.disabled then self:drawRect(0, 0, self.width, self.height, 0.4, 0, 0, 0) end
    if self:isMouseOver() and ISMouseDrag.dragging and ISMouseDrag.draggingFocus ~= self then
        self:drawRectBorder(0, 0, self.width, self.height, 1, 0.8, 0.8, 0.8)
    end
end

---@param delta number Wheel direction
---@return boolean handled
function Slot:onMouseWheel(delta)
    if self.kind == "module" and self.owner.rows > 4 then return self.owner:scrollModules(delta) end
    return self.owner:onMouseWheel(delta)
end

---@return nil
function Slot:render()
    if self.pulseUntil then
        local remaining = self.pulseUntil - getTimestampMs()
        if remaining > 0 then
            self:drawRectBorder(0, 0, self.width, self.height, remaining / 250, .85, .95, 1)
        else
            self.pulseUntil = nil
        end
    end
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
    slot.borderColor = {r = .22, g = .22, b = .22, a = .5}
    slot.backgroundColor = {r = 0.08, g = 0.08, b = 0.08, a = 1}
    if kind == "head" then
        Hint.set(slot, T.HEAD)
    elseif kind == "battery" then
        Hint.set(slot, "Base.CarBattery1")
    elseif kind == "capacity" then
        Hint.set(slot, T.TYPES.CapacitySmall)
    elseif kind == "module" then
        Hint.set(slot, T.TYPES.Firing)
    end
    return slot
end

return Slot
