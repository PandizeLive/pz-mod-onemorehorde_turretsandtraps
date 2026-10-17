if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
local A = require("OMHTT/ControlAccess")
local Theme = require("OMHTT/ControlTheme")
local Pane = ISInventoryPane:derive("OMHTTStockpilePane")
local Wing = ISPanel:derive("OMHTTStockpileWing")
local active = setmetatable({}, {__mode = "k"})

---@return boolean down
function Wing:isCycleContainerKeyDown()
    return false
end

---@return nil
function Wing:prerender()
    Theme.section(self, 0, 0, self.width, self.height, self.owner.lineHeight + 8, getText("UI_OMHTT_StockpileTitle"))
    local weight = self.inventory:getCapacityWeight()
    self:drawText(getText("UI_OMHTT_StockWeight", string.format("%.1f", weight)), 10, self.owner.lineHeight + 14, .8, .8, .8, 1, UIFont.Small)
end

---@return boolean writable
function Pane:writable()
    local owner = self.inventoryPage.owner
    return A.near(owner.player, owner.object) and A.write(owner.player, A.state(owner.object))
end

---@return nil
function Pane:cleanup()
    if self.toolRender then
        self.toolRender:removeFromUIManager()
        self.toolRender = nil
    end
    if ISMouseDrag.draggingFocus == self then
        ISMouseDrag.dragging, ISMouseDrag.draggingFocus = nil, nil
    end
    self.dragging, self.draggingMarquis = nil, false
    self.draggedItems:reset()
    self:hideButtons()
end

---@return nil
function Pane:update()
    local writable = self:writable()
    if self.wasWritable ~= writable then
        self.wasWritable = writable
        if not writable then
            self:cleanup()
        end
    end
    if self.stockDirty then
        self.stockDirty = false
        self:refreshContainer()
    end
    ISInventoryPane.update(self)
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean? handled
function Pane:onMouseDown(x, y)
    local result = ISInventoryPane.onMouseDown(self, x, y)
    if not self:writable() then
        self.dragging = nil
    end
    return result
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean handled
function Pane:onMouseUp(x, y)
    if ISMouseDrag.draggingFocus ~= self and ISMouseDrag.dragging and not self:writable() then return true end
    return ISInventoryPane.onMouseUp(self, x, y)
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean? handled
function Pane:onMouseDoubleClick(x, y)
    if not self:writable() then return true end
    return ISInventoryPane.onMouseDoubleClick(self, x, y)
end

---@param x number Mouse X
---@param y number Mouse Y
---@return boolean? handled
function Pane:onRightMouseUp(x, y)
    if not self:writable() then return true end
    return ISInventoryPane.onRightMouseUp(self, x, y)
end

---@param y number Row top
---@return nil
function Pane:doButtons(y)
    if not self:writable() then self:hideButtons(); return end
    ISInventoryPane.doButtons(self, y)
end

---@param button ISButton Native item action
---@return nil
function Pane:onContext(button)
    if not self:writable() then return end
    ISInventoryPane.onContext(self, button)
end

---@param owner ISPanel Controller
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@return ISPanel wing
function Wing.create(owner, x, y, width, height)
    local wing = Wing:new(x, y, width, height)
    wing.owner, wing.inventory, wing.onCharacter = owner, owner.object:getContainer(), false
    wing.isCollapsed, wing.render3DItems = false, {}
    wing:initialise()
    owner:addChild(wing)
    local top = owner.lineHeight * 2 + 24
    local pane = Pane:new(6, top, width - 12, height - top - 6, wing.inventory, 1)
    pane.player, pane.inventoryPage = owner.player:getPlayerNum(), wing
    pane.stockDirty = true
    pane:initialise()
    wing.inventoryPane = pane
    wing:addChild(pane)
    active[pane] = true
    if isClient() then
        wing.inventory:requestSync()
    end
    return wing
end

---@return nil
function Wing:close()
    active[self.inventoryPane] = nil
    self.inventoryPane:cleanup()
    self:setVisible(false)
end

local nativeDrop = ISInventoryPaneDraggedItems.getDropContainer
---@return ItemContainer? container
---@return string? kind
function ISInventoryPaneDraggedItems:getDropContainer()
    for pane in pairs(active) do
        if pane:isReallyVisible() and pane:isMouseOver() then
            return pane.inventory, "loot"
        end
    end
    return nativeDrop(self)
end

---@return nil
local function dirty()
    for pane in pairs(active) do
        pane.stockDirty = true
    end
end

Events.OnContainerUpdate.Add(dirty)
return Wing
