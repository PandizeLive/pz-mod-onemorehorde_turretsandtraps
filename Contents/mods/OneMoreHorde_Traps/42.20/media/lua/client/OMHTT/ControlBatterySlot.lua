if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
require("ISUI/ISInventoryItem")
require("ISUI/ISToolTipInv")
require("TimedActions/ISTimedActionQueue")
local A = require("OMHTT/ControlAccess")
local Transfer = require("OMHTT/ControlTransferAction")
local Theme = require("OMHTT/ControlTheme")
local Battery = require("OMHTT/TurretBattery")
local Hint = require("OMHTT/SlotHint")
local Slot = ISPanel:derive("OMHTTControlBatterySlot")

---@return nil
function Slot:cleanup()
    self.pendingItems, self.pendingIndex, self.pendingAction = nil, nil, nil
    if self.tooltip then
        self.tooltip:removeFromUIManager()
        self.tooltip = nil
    end
    if ISMouseDrag.draggingFocus == self then
        ISMouseDrag.draggingFocus, ISMouseDrag.dragging = nil, nil
    end
end

---@return nil
function Slot:refreshCount()
    local items = self.owner.object:getContainer():getItems()
    local size = items:size()
    if self.countSize ~= size then
        self.countDirty = true
    end
    if self.countDirty then
        self.countDirty, self.countSize = false, size
        self.countIndex, self.countFound = 0, 0
    end
    if not self.countIndex then return end
    local stop = math.min(size, self.countIndex + 64)
    for index = self.countIndex, stop - 1 do
        if Battery.car(items:get(index)) then
            self.countFound = self.countFound + 1
        end
    end
    self.countIndex = stop
    if stop >= size then
        self.storedCount, self.countIndex = self.countFound, nil
    end
end

---@param action OMHTTControlTransferAction Replicated completed transfer
---@return nil
function Slot:transferred(action)
    self.countDirty = true
    if self.pendingAction == action then
        self.pendingAction = nil
    end
end

---@return nil
function Slot:transferNext()
    if not self.pendingItems then return end
    if not A.near(self.owner.player, self.owner.object) or not A.write(self.owner.player, A.state(self.owner.object))
        or (self.pendingAction and self.pendingAction.cancelled) then
        self.pendingItems, self.pendingIndex, self.pendingAction = nil, nil, nil
        return
    end
    if self.pendingAction then
        if not self.pendingAction.done then return end
        self.pendingAction = nil
        self.countDirty = true
    end
    local items = self.pendingItems
    for step = 1, 16 do
        local item = items[self.pendingIndex]
        if not item then
            self.pendingItems, self.pendingIndex = nil, nil
            return
        end
        self.pendingIndex = self.pendingIndex + 1
        if Battery.car(item) then
            local stored = item:getContainer() == self.owner.object:getContainer()
            local action = Transfer:new(self.owner.player, self.owner.object, item, true, nil, nil, stored)
            if action:isValid() then
                self.pendingAction = action
                action:setOnComplete(Slot.transferred, self, action)
                ISTimedActionQueue.add(action)
                if stored then
                    self.pendingItems, self.pendingIndex = nil, nil
                end
                return
            end
        end
    end
end

---@return nil
function Slot:update()
    local state = A.state(self.owner.object)
    if not state then self:cleanup(); return end
    self:refreshCount()
    self:transferNext()
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
        self.pendingItems = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        self.pendingIndex, self.pendingAction = 1, nil
        self:transferNext()
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
    local label = getText("UI_OMHTT_ControllerBatteries", self.storedCount and tostring(self.storedCount) or "...")
    self:setStencilRect(4, 3, self.width - 8, h + 4)
    self:drawText(label, 8, 4, .85, .85, .85, 1, UIFont.Small)
    self:clearStencilRect()
    local start = 16 + getTextManager():MeasureStringX(UIFont.Small, label)
    local charge = self.item and Battery.charge(self.item) or 0
    if self.width - start > 20 then
        self:drawProgressBar(start, 8, self.width - start - 8, 7, charge, Theme.accent)
    end
    local name = getText("UI_OMHTT_ControllerBatteryDrop")
    if self.item then
        ISInventoryItem.renderItemIcon(self, self.item, 8, h + 6, 1, 28, 28)
        name = self.item:getDisplayName() .. " " .. tostring(math.floor(charge * 100)) .. "%"
    else
        Hint.draw(self, 8, h + 6, 28)
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
    Hint.set(slot, "Base.CarBattery1")
    slot.countDirty = true
    slot.backgroundColor = {r = .06, g = .06, b = .06, a = 1}
    slot.borderColor = {r = .3, g = .3, b = .3, a = .6}
    slot:initialise()
    owner:addChild(slot)
    return slot
end

return Slot
