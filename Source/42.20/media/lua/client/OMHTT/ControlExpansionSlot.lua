if isServer() then return end
require('ISUI/ISPanel')
require('ISUI/ISInventoryPane')
require('ISUI/ISInventoryItem')
require('TimedActions/ISTimedActionQueue')
local E = require('OMHTT/ControlExpansion')
local Action = require('OMHTT/ControlExpansionAction')
local Slot = ISPanel:derive('OMHTTControlExpansionSlot')

---@param item InventoryItem? Replacement
---@return nil
function Slot:change(item)
    local action = Action:new(self.owner.player, self.owner.object, item)
    if action:isValid() then ISTimedActionQueue.add(action) end
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Slot:onMouseUp(x, y)
    if ISMouseDrag.dragging then
        local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        for i = 1, #items do
            if E.tier(items[i]) > 0 then self:change(items[i]); break end
        end
        ISMouseDrag.dragging, ISMouseDrag.draggingFocus = nil, nil
    end
    return true
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Slot:onRightMouseUp(x, y)
    self:change(nil)
    return true
end

---@return nil
function Slot:prerender()
    local item = E.item(self.owner.object)
    self:drawRect(0, 0, self.width, self.height, .8, .025, .025, .025)
    self:drawRectBorder(0, 0, self.width, self.height, .6, .4, .4, .4)
    self:setStencilRect(3, 3, self.width - 6, self.height - 6)
    self:drawText(getText('UI_OMHTT_ControlExpansion'), 5, 3, .8, .8, .8, 1, UIFont.Small)
    local h = getTextManager():getFontHeight(UIFont.Small)
    if item then
        ISInventoryItem.renderItemIcon(self, item, 5, h + 7, 1, 32, 32)
        self:drawText(item:getDisplayName(), 42, h + 12, .9, .9, .9, 1, UIFont.Small)
    else
        self:drawText('+', 12, h + 8, .7, .7, .7, 1, UIFont.Medium)
    end
    self:clearStencilRect()
end

---@param owner ISPanel Controller
---@return ISPanel slot
function Slot.create(owner)
    local slot = Slot:new(0, 0, 180, owner.lineHeight * 2 + 20)
    slot.owner = owner
    slot:initialise()
    slot.tooltip = getText('UI_OMHTT_ControllerKitHint')
    owner:addChild(slot)
    return slot
end
return Slot
