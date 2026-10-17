if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
require("ISUI/ISToolTipInv")
require("TimedActions/ISTimedActionQueue")
local A = require("OMHTT/ControlAccess")
local Transfer = require("OMHTT/ControlTransferAction")
local Theme = require("OMHTT/ControlTheme")
local Slot = ISPanel:derive("OMHTTControlBatterySlot")

---@return nil
function Slot:cleanup()
    if self.tooltip then
        self.tooltip:removeFromUIManager()
        self.tooltip = nil
    end
    if ISMouseDrag.draggingFocus == self then
        ISMouseDrag.draggingFocus, ISMouseDrag.dragging = nil, nil
    end
end

---@return nil
function Slot:update()
    local state = A.state(self.owner.object)
    if not state then self:cleanup(); return end
    local id = state.batteryId
    local now = getTimestampMs()
    if self.batteryId ~= id or (id and not self.item and now >= (self.lookupDue or 0))
        or (self.item and self.item:getContainer() ~= self.owner.object:getContainer()) then
        self.lookupDue, self.batteryId = now + 1000, id
        self.item = id and self.owner.object:getContainer():getItemWithID(id) or nil
    end
    if ISMouseDrag.draggingFocus == self and not isMouseButtonDown(0) then
        ISMouseDrag.draggingFocus, ISMouseDrag.dragging = nil, nil
    end
    if self:isMouseOver() and self.item and not ISMouseDrag.dragging then
        if not self.tooltip then
            self.tooltip = ISToolTipInv:new(self.item)
            self.tooltip:initialise()
            self.tooltip:addToUIManager()
            self.tooltip:setOwner(self)
            self.tooltip:setCharacter(self.owner.player)
        end
        self.tooltip:setItem(self.item)
        self.tooltip:setVisible(true)
    elseif self.tooltip then
        self.tooltip:removeFromUIManager()
        self.tooltip = nil
    end
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Slot:onMouseDown(x, y)
    if not self.item or not A.write(self.owner.player, A.state(self.owner.object)) then return true end
    self:cleanup()
    ISMouseDrag.dragging, ISMouseDrag.draggingFocus = {self.item}, self
    return true
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Slot:onMouseUp(x, y)
    local focus = ISMouseDrag.draggingFocus
    if focus and focus ~= self and ISMouseDrag.dragging then
        local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        for i = 1, #items do
            local item = items[i]
            if item:getFullType() == "Base.Battery" then
                local stored = item:getContainer() == self.owner.object:getContainer()
                local action = Transfer:new(self.owner.player, self.owner.object, item, true, nil, nil, stored)
                if action:isValid() then
                    ISTimedActionQueue.add(action)
                    break
                end
            end
        end
        focus:onMouseUp(0, 0)
    end
    ISMouseDrag.dragging, ISMouseDrag.draggingFocus = nil, nil
    return true
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Slot:onRightMouseUp(x, y)
    if not self.item then return true end
    local action = Transfer:new(self.owner.player, self.owner.object, self.item, false)
    if action:isValid() then
        ISTimedActionQueue.add(action)
    end
    return true
end

---@return nil
function Slot:prerender()
    ISPanel.prerender(self)
    local h = self.owner.lineHeight
    local label = getText("UI_OMHTT_ControllerBattery")
    self:drawText(label, 8, 4, .85, .85, .85, 1, UIFont.Small)
    local start = 16 + getTextManager():MeasureStringX(UIFont.Small, label)
    local charge = self.item and require("OMHTT/TurretBattery").charge(self.item) or 0
    if self.width - start > 20 then
        self:drawProgressBar(start, 8, self.width - start - 8, 7, charge, Theme.accent)
    end
    local name = getText("UI_OMHTT_ControllerBatteryDrop")
    if self.item then
        ISInventoryItem.renderItemIcon(self, self.item, 8, h + 6, 1, 28, 28)
        name = self.item:getDisplayName() .. " " .. tostring(math.floor(charge * 100)) .. "%"
    end
    self:setStencilRect(40, h + 6, self.width - 48, h + 4)
    self:drawText(name, 40, h + 6, 1, 1, 1, 1, UIFont.Small)
    self:clearStencilRect()
end

---@param owner ISPanel Controller window
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@return ISPanel slot
function Slot.create(owner, x, y, width, height)
    local slot = Slot:new(x, y, width, height)
    slot.owner = owner
    slot.backgroundColor = {r = .06, g = .06, b = .06, a = 1}
    slot.borderColor = {r = .3, g = .25, b = .2, a = .6}
    slot:initialise()
    owner:addChild(slot)
    return slot
end

return Slot
