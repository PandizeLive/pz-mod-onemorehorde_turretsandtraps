if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISInventoryPane")
require("ISUI/PlayerData/ISPlayerData")
local A = require("OMHTT/ControlAccess")
local Theme = require("OMHTT/ControlTheme")
local Pane = ISInventoryPane:derive("OMHTTStockpilePane")
local Wing = ISPanel:derive("OMHTTStockpileWing")
local active = setmetatable({}, {__mode = "k"})

---@return nil
function Pane:createChildren()
    ISInventoryPane.createChildren(self)
    Theme.scrollbar(self)
end

---@return nil
function Pane:onResize()
    ISInventoryPane.onResize(self)
    Theme.scrollbar(self)
end

---@return boolean down
function Wing:isCycleContainerKeyDown()
    return false
end

---@return nil
function Wing:prerender()
    self:setStencilRect(0, 0, self.width, self.height)
    Theme.section(self, 0, 0, self.width, self.height, self.owner.lineHeight + 8, getText("UI_OMHTT_StockpileTitle"))
    local weight = self.inventory:getCapacityWeight()
    local capacity = require("OMHTT/ControlExpansion").capacity(self.owner.object)
    local used = math.max(0, weight)
    self:drawText(getText("UI_OMHTT_StockUsage", string.format("%.1f", used), capacity), 10, self.owner.lineHeight + 14, .8, .8, .8, 1, UIFont.Small)
    Theme.meter(self, 10, self.owner.lineHeight * 2 + 18, self.width - 20, 7, used / math.max(1, capacity), true)
end

---@return nil
function Wing:render()
    self:clearStencilRect()
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
    if self.stockDirty and self:isReallyVisible() then
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
    local top = owner.lineHeight * 2 + 34
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

---@param inventory ItemContainer? Changed container, nil for a native global notification
---@param refreshed ISInventoryPane? View already current
---@return nil
local function invalidate(inventory, refreshed)
    for pane in pairs(active) do
        if not inventory or pane.inventory == inventory then
            if pane ~= refreshed then pane.stockDirty = true end
            local slot = pane.inventoryPage.owner.batterySlot
            if slot then slot.countDirty = true end
        end
    end
end

local nativeRefresh = ISInventoryPane.refreshContainer
---@return nil
function ISInventoryPane:refreshContainer()
    local inventory = self.inventory
    local changed = inventory and inventory:isDrawDirty()
    nativeRefresh(self)
    if active[self] then self.stockDirty = false end
    if changed or not active[self] then invalidate(inventory, self) end
    if active[self] and changed then
        for i = 0, getNumActivePlayers() - 1 do
            local data = getPlayerData(i)
            if data then
                local carried, loot = data.playerInventory, data.lootInventory
                if carried and carried.inventoryPane and carried.inventoryPane.inventory == inventory then
                    nativeRefresh(carried.inventoryPane)
                end
                if loot and loot.inventoryPane and loot.inventoryPane.inventory == inventory then
                    nativeRefresh(loot.inventoryPane)
                end
            end
        end
    end
end

Events.OnContainerUpdate.Add(function() invalidate() end)
return Wing
