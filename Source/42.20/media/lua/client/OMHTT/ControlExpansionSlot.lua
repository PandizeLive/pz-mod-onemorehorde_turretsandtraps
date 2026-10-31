if isServer() then return end
require('ISUI/ISPanel')
require('ISUI/ISInventoryPane')
require('ISUI/ISInventoryItem')
require('ISUI/ISToolTip')
require('TimedActions/ISTimedActionQueue')
local E = require('OMHTT/ControlExpansion')
local Action = require('OMHTT/ControlExpansionAction')
local Hint = require("OMHTT/SlotHint")
local Access = require("OMHTT/ControlAccess")
local Slot = ISPanel:derive('OMHTTControlExpansionSlot')

---@return nil
function Slot:cleanup()
    if not self.tooltip then return end
    self.tooltip:removeFromUIManager()
    self.tooltip = nil
end

---@return nil
function Slot:update()
    local item = E.item(self.owner.object)
    if not self.owner:isVisible() or not self:isVisible() or not self:isMouseOver() or ISMouseDrag.dragging then
        self:cleanup()
        return
    end
    if not self.tooltip then
        self.tooltip = ISToolTip:new()
        self.tooltip:initialise()
        self.tooltip:addToUIManager()
        self.tooltip:setOwner(self)
        self.tooltip.maxLineWidth = 350
    end
    self.tooltip:setName(item and item:getDisplayName() or getText('UI_OMHTT_ControlExpansion'))
    self.tooltip.description = item and require('OMHTT/ControlItemDescription').get(item) or getText('UI_OMHTT_ControllerKitHint')
    self.tooltip:setVisible(true)
end

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
    if self:isMouseOver() then
        self:drawRectBorder(0, 0, self.width, self.height, 1, .8, .8, .8)
    end
    self:setStencilRect(3, 3, self.width - 6, self.height - 6)
    self:drawText(getText('UI_OMHTT_ControlExpansion'), 5, 3, .8, .8, .8, 1, UIFont.Small)
    local h = getTextManager():getFontHeight(UIFont.Small)
    if item then
        ISInventoryItem.renderItemIcon(self, item, 5, h + 7, 1, 32, 32)
        self:drawText(item:getDisplayName(), 42, h + 12, .9, .9, .9, 1, UIFont.Small)
    else
        Hint.set(self, "Base.OMHTTModuleExpansionSmall")
        Hint.draw(self, 5, h + 7, 32)
        self:drawText(getText("UI_OMHTT_ManageDrop"), 42, h + 12, .7, .7, .7, 1, UIFont.Small)
    end
    self:clearStencilRect()
    if not Access.near(self.owner.player, self.owner.object) or not Access.write(self.owner.player, Access.state(self.owner.object)) then
        self:drawRect(0, 0, self.width, self.height, .35, 0, 0, 0)
    end
end

---@param owner ISPanel Controller
---@return ISPanel slot
function Slot.create(owner)
    local slot = Slot:new(0, 0, 180, owner.lineHeight * 2 + 20)
    slot.owner = owner
    slot:initialise()
    owner:addChild(slot)
    return slot
end
return Slot
